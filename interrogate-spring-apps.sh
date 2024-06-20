#!/bin/bash

if [ "$#" -ne 1 ];
  then 
     echo "Usage interrogate-spring-apps.sh <folder>" 
     exit 1
fi
folder=$1

bootmanifest='app/META-INF/MANIFEST.MF'
echo 
echo -e "APP\t\t\t\tBootVersion\t\tJdkVersion"
echo "======================================================================"
for app in $(ls $folder | grep .tar) 
do 
    appname=$(echo $app | awk '{print substr($0,1,length($0)-4)}')
    if tar tf $folder/$app | grep -q $bootmanifest;
    then 
        springbootversion=$(tar xvf $folder/$app -O $bootmanifest 2>/dev/null | grep 'Spring-Boot-Version' | awk '{print $2}' )
        jdkversion=$(tar xvf $folder/$app -O $bootmanifest 2>/dev/null | grep 'Build-Jdk-Spec' | awk '{print $2}')
        echo -e "$appname\t\t\t$springbootversion\t\t\t\t\t\t$jdkversion"
    else
        echo -e "$appname\t\t\tN/A\t\t\t\t\tN/A"
    fi
done

