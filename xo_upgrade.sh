#!/bin/bash

updateFromSource ()
{
echo Current version $(git describe --abbrev=0)
sleep 10s
git fetch origin
output=$( git rev-list HEAD...origin/master --count )
echo $output updates available

if [[ $output -ne 0 ]]; then
  echo "Updating from source..."
  n lts
  npm i -g npm
  git pull --ff-only
  npm install && \
  npm run build
  echo Updated version $(git describe --abbrev=0)
fi
}

isActive=$(systemctl is-active xo-server)
if [ "$isActive" == "active" ]; then
  systemctl stop xo-server.service
else
  pkill -f "/bin/xo-server"
fi

echo "Checking xo-server..."
cd /opt/xo-server
updateFromSource

echo "Checking xo-web..."
cd /opt/xo-web
updateFromSource

sleep 15s

systemctl start xo-server.service