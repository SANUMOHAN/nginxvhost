#!/bin/sh

echo "=========================================="
echo "  Welcome to Vhost "
echo "=========================================="
echo ""
echo -n "Site name [eg : example.com] :"
status=`echo $?`
read domain
if [ -z "$domain" ];then
    echo "Please provide a sitename to continue .."
    echo "eg : example.com"
    exit 3
fi

cd /var/www/html && mkdir $domain
cd /etc/nginx/sites-available 
echo "
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/html/$domain;
    index index.php index.html index.htm *;

    server_name $domain;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }
    location / {
            try_files \$uri /index.php\$is_args\$args;
    }
    location ~ /\.ht {
        deny all;
    }
    location /myadmin {
        root /var/www/html;
        index index.php index.html index.htm;
        location ~ ^/myadmin/(.+\.php)$ {
            try_files \$uri =404;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

        }
        location ~* ^/myadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
            root /var/www/html/;
        }
    }
}" | sudo tee -a  $domain.conf

cd /etc/nginx/sites-enabled 
echo "
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/$domain;
    index index.php index.html index.htm *;

    server_name $domain;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }
    location / {
            try_files \$uri /index.php\$is_args\$args;
    }
    location ~ /\.ht {
        deny all;
    }
    location /myadmin {
        root /var/www/html;
        index index.php index.html index.htm;
        location ~ ^/myadmin/(.+\.php)$ {
            try_files \$uri =404;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

        }
        location ~* ^/myadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
            root /var/www/html/;
        }
    }
}" | sudo tee -a  $domain.conf


sudo service nginx restart

cd /etc
echo "127.0.0.1       $domain" | sudo tee -a hosts
sudo service nginx restart


cd /var/www/html/$domain
echo "
<html>
  <head>
    <title>Welcome to $domain !</title>
  </head>
  <body>
    <h1>Success!  The $domain virtual host is working!</h1>
  </body>
</html>" | sudo tee -a  index.html


if [ $status = "0" ]; then
    echo "######################################"
    echo "  Virtualhost created "
    printf '\e]8;;http://%s\e\\%s\e]8;;\e\\\n' $domain $domain
    echo "######################################"
    exit 0
else
    echo "##################################################"
    echo "  Something went wrong Please do manually"
    echo "##################################################"
    exit 1
fi
