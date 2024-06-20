#!/bin/bash

if [ "$#" -ne 1 ];
  then 
     echo "Usage cf-download-apps-in-space.sh <space-name>" 
     exit 1
fi
echo arg count = $#

spacename=$1
cf target -s $spacename

for app in $(cf apps | awk '{print $1}' | tail -n +4 )
do
  echo cf-download-app.sh $app
  cf-download-app.sh $app
done
