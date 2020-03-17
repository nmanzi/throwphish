#!/bin/bash

# Install GoPhish
sudo curl -s "https://api.github.com/repos/gophish/gophish/releases/latest" | jq -r '.assets[] | select(.name | endswith("linux-64bit.zip" )).browser_download_url' | sudo xargs curl -L -o /opt/gophish.zip --url
sudo unzip -qq /opt/gophish.zip -d /opt/gophish

# Prepare the GoPhish config file
sudo touch /opt/gophish/tmp.json
sudo mv /tmp/cert.pem /opt/gophish/cert.pem
sudo chmod 644 /opt/gophish/cert.pem
sudo mv /tmp/privkey.pem /opt/gophish/privkey.pem
sudo chmod 600 /opt/gophish/privkey.pem
sudo jq '.admin_server.listen_url ="0.0.0.0:3333"' /opt/gophish/config.json | jq '.contact_address ="support@diverse.services"' | jq '.phish_server.use_tls =true' | jq '.phish_server.listen_url ="0.0.0.0:443"' | jq '.phish_server.cert_path ="cert.pem"' | jq '.phish_server.key_path = "privkey.pem"' | sudo tee /opt/gophish/tmp.json
sudo rm /opt/gophish/config.json && sudo mv /opt/gophish/tmp.json /opt/gophish/config.json

# Make required directories and files
sudo mkdir /opt/gophish/log/
sudo touch /opt/gophish/log/gophish.log
sudo touch /opt/gophish/log/gophish.err

# Make the Static/Endpoint directory for asset uploads and apply permissions
sudo mkdir /opt/gophish/static/endpoint
sudo chown gophishadm: /opt/gophish/static/endpoint
sudo chmod 755 /opt/gophish/static/endpoint

# Install GoPhish as a service
sudo cp /tmp/gophish.service /lib/systemd/system/gophish.service
sudo cp /tmp/gophish_service.sh /opt/gophish/gophish_service.sh
sudo chmod +x /opt/gophish/gophish_service.sh
sudo systemctl daemon-reload
sudo systemctl start gophish.service