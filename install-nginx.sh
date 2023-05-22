#!/bin/bash

sudo apt-get update -y
sudo apt-get install nginx npm git -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo npm install -g yarn 
sudo ufw allow OpenSSH
sudo git clone https://github.com/ABSQUARE1/merchstore.git merchstore

cd merchstore
yarn
# yarn run build
# sudo rm -rf /var/www/html
# sudo mkdir /var/www/html
# sudo cp build/* /var/www/html -r
# sudo systemctl restart nginx

sudo npm install -g pm2
sudo pm2 delete react-build || true
pm2 run build
pm2 serve build/ 3000 -f --name "react-build" --spa
sudo systemctl restart nginx

