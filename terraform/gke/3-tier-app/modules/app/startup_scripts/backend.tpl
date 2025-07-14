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

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo docker run -p 8000:8000 \
  -e POSTGRES_USER="${postgres_user}" \
  -e POSTGRES_PASSWORD="${postgres_password}" \
  -e POSTGRES_DB="${postgres_db}" \
  -e POSTGRES_HOST="${postgres_host}" \
  -e POSTGRES_PORT=5432 \
  gcr.io/daring-chess-382110/backend:1.0