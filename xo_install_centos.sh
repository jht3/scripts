#!/bin/bash

REL=stable

cd /opt
curl -o /usr/local/bin/n https://raw.githubusercontent.com/visionmedia/n/master/bin/n
chmod +x /usr/local/bin/n
n lts
npm i -g npm
yum -y install epel-release
yum -y install nfs-utils gcc gcc-c++ automake redis libpng-devel git python
systemctl enable redis
systemctl start redis

git clone -b $REL https://github.com/vatesfr/xo-server
git clone -b $REL https://github.com/vatesfr/xo-web
cd xo-server
npm install
npm install xo-server-load-balancer
npm run build
cp sample.config.yaml .xo-server.yaml
sed -i /mounts/a\\"    '/': '/opt/xo-web/dist'" .xo-server.yaml
cat >> .xo-server.yaml <<EOF
plugins:
  xo-server-load-balancer:
EOF
cd /opt/xo-web
npm install
npm run build

cat > /etc/systemd/system/xo-server.service <<EOF
# systemd service for XO-Server.

[Unit]
Description=XO Server
After=network-online.target

[Service]
WorkingDirectory=/opt/xo-server/
ExecStart=/usr/local/bin/node ./bin/xo-server
Restart=always
SyslogIdentifier=xo-server

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/xo-server.service
systemctl enable xo-server.service
systemctl start xo-server.service
