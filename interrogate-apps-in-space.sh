#!/bin/bash

if [ "$#" -ne 1 ];
  then 
     echo "Usage cf-download-apps-in-space.sh <space-name>" 
     exit 1
fi
echo arg count = $#


function download-cf-app() {
appname=$1
#echo appname = $appname

# 1. get auth token
cftoken=$(cf oauth-token)
#echo cftoken = $cftoken

# 2. get app guid
appguid=$(cf app $appname --guid)
#echo appguid = $appguid

# 3. get current droplet guid
currentdropletguid=$(cf curl /v3/apps/$appguid/droplets/current | jq -r .guid)
#echo current droplet guid = $currentdropletguid

#4. get cf api endpoint
cfapiendpoint=$(cf api | grep "API endpoint" | awk '{print $3}')
#echo cfapiendpoint = $cfapiendpoint

# 5. download droplet
#echo curl -L $cfapiendpoint/v3/droplets/$currentdropletguid/download -H "Authorization: $cftoken" -o $appname.tar
curl -s -L -o $appname.tar $cfapiendpoint/v3/droplets/$currentdropletguid/download -H "Authorization: $cftoken" 

}

spacename=$1
cf target -s $spacename > /dev/null

bootmanifest='app/META-INF/MANIFEST.MF'

echo "Spring App Interrogator"
echo "========================"
cf target
echo "========================"
echo "AppName, SpringBoot Version, JDK Version"

#echo -n '{"orgs":["org-name":"DemoOrg","spaces": [{"space-name":'
#echo "\"$spacename\",\"apps\":["
for app in $(cf apps | awk '{print $1}' | tail -n +4 )
do
  #echo "{\"app-name\": \"$app\","
  download-cf-app $app
  appfile=$app.tar
  if tar tf $appfile | grep -q $bootmanifest;
  then
    springbootversion=$(tar xvf $appfile -O $bootmanifest 2>/dev/null | grep 'Spring-Boot-Version' | awk '{print $2}' | tr -d '\r')
    jdkversion=$(tar xvf $appfile -O $bootmanifest 2>/dev/null | grep 'Build-Jdk-Spec' | awk '{print $2}' | tr -d '\r')
    echo "$app,$springbootversion,$jdkversion"
  else
    #echo "\"app-name\": \"$app\","
    echo "$app"
  fi
  rm $appfile
done
echo '}]]}'

