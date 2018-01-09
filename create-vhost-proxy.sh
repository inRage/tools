#!/bin/bash

serverName=$1
destination=$2
siteEnable='/etc/nginx/sites-enabled/'
siteAvailable='/etc/nginx/sites-available/'

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

while [ "$serverName" == "" ]
do
	echo -e $"Please provide domain. e.g.dev,staging"
	read serverName
done

while [ "$destination" == "" ]
do
	echo -e $"Please provide destination. e.g.10.0.0.169:8080"
	read destination
done

if [ -e $siteAvailable$serverName ]; then
    echo -e $"This domain already exists.\nPlease Try Another one"
    exit;
fi

## Create virtualhost rules filee
if ! echo "server {
  listen 80;
  server_name $serverName;

  location / {
    resolver 8.8.8.8;
    proxy_pass http://$destination;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
}" > $siteAvailable$serverName
then
    echo -e $"There is an ERROR create $serverName file"
    exit;
else
    echo -e $"\nNew Virtual Host Created\n"
fi

## Enable website
ln -s $siteAvailable$serverName $siteEnable$serverName

## Reload Nginx
#service nginx reload

echo -e $"Complete ! Yout now have a new Virtual Host\nYour new host is: http://$serverName"
exit;