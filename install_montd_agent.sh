#!/bin/sh
# type 0=Microservice, 1=Service
type=$1
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
tar zxvf node_exporter-*
cp node_exporter-*/node_exporter /usr/local/bin
rm -rf node_exporter-*

if [ ${type} == 1 ]
then
addgroup node_exporter
adduser --no-create-home --shell /bin/false node_exporter -G node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter
cat <<EOF >  /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
fi
