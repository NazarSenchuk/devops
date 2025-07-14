#!/bin/bash
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install nginx docker-ce docker-ce-cli  -y

sudo echo "user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 1024;  # Increased from 768
        multi_accept on;
        use epoll;
}

http {

        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;



        gzip on;
        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_min_length 256;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m inactive=60m use_temp_path=off;
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
" > /etc/nginx/nginx.conf

sudo echo "server {
  listen 80;


  location /_next/static {
    proxy_pass http://localhost:3000;
    proxy_cache my_cache;
    add_header X-Cache-Status $upstream_cache_status;
  }

  location /static {
    proxy_cache my_cache;
    proxy_cache_valid 10m;
    proxy_ignore_headers Cache-Control;
    proxy_pass http://localhost:3000;
    add_header X-Cache-Status $upstream_cache_status;
  }


  location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

  error_page 404 /404.html;
    location = /40x.html {
  }
  error_page 500 502 503 504 /50x.html;
    location = /50x.html {
  }
  location /api/v1/ {
        proxy_pass http://${backend_host}:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 75s;
        proxy_send_timeout 600s;
        proxy_read_timeout 600s;
        proxy_cache my_cache;
        proxy_cache_valid 200 301 302 307 60m; # Кешувати успішні відповіді на 60 хвилин
        proxy_cache_key "$scheme$request_method$host$request_uri"; # Ключ для кешу
        proxy_cache_use_stale error timeout updating; # Використовувати старий кеш у разі помилок
        add_header X-Cache-Status $upstream_cache_status;
}
}"  > /etc/nginx/sites-available/default

sudo systemctl restart nginx

sudo docker run --restart always -d  -p 3000:3000 ${container_name}
