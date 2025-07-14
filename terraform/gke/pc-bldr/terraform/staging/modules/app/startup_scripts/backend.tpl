#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli -y

docker run --restart always --name backend -e POSTGRES_HOST=${postgres_host} -e POSTGRES_DSN="postgresql://${postgres_user}:${postgres_password}@${postgres_host}:5432/${postgres_db}"  -e KEEPA_API_KEY=a1go3goohvl9mdqduge5g616g1ua1b7inj4snles6nasuajkb3le1c8i3irphqk1 -p  8000:8000 ${container_name}
