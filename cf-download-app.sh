#!/bin/bash
# Get unstaged application bits from cloud foundry

# Expects 
# cf cli already logged in and targeting org/space of interest

# usage: cf-get-unstaged-app.sh <app-name>


if [ "$#" -ne 1 ];
  then 
     echo "Usage cf-download-app.sh <app-name>" 
     exit 1
fi
echo arg count = $#

appname=$1
echo appname = $appname

# 1. get auth token
cftoken=$(cf oauth-token)
echo cftoken = $cftoken

# 2. get app guid
appguid=$(cf app $appname --guid)
echo appguid = $appguid

# 3. get current droplet guid
currentdropletguid=$(cf curl /v3/apps/$appguid/droplets/current | jq -r .guid)
echo current droplet guid = $currentdropletguid

#4. get cf api endpoint
cfapiendpoint=$(cf api | grep "API endpoint" | awk '{print $3}')
echo cfapiendpoint = $cfapiendpoint

# 5. download droplet
echo curl -L $cfapiendpoint/v3/droplets/$currentdropletguid/download -H "Authorization: $cftoken" -o $appname.tar
curl -L -o $appname.tar $cfapiendpoint/v3/droplets/$currentdropletguid/download -H "Authorization: $cftoken" 