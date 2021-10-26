#!/bin/bash -ex
#https://www.youtube.com/watch?v=edRFGms7Scs
sudo -i
sudo apt-get update -y

minikube start --vm-driver=none


#!/bin/bash 
sudo su
apt update -y
apt upgrade -y
apt install apache2 -y
ufw allow 'Apache'  
ufw enable -y
echo "Hello from $(hostname -f) User: $(whoami)" > /var/www/html/index.html

sudo su
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
#sudo echo "Hello from $(hostname -f)" > /usr/share/nginx/html/index.html

#!/bin/bash


# update the operating system and yum repository
sudo yum update -y

# install apache web server
sudo yum install httpd -y

# create an index.html file
echo "Hello, Cloud Experts<br>" > /var/www/html/index.html

# start the httpd service
sudo service httpd start

# start httpd on boot
chkconfig httpd on