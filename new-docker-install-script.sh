#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with sudo"
  exit
fi

# Get the architecture
arch=$(uname -m)

# Install Docker
echo "Installing Docker..."
if [[ $arch == "x86_64" ]] || [[ $arch == "amd64" ]] || [[ $arch == "aarch64" ]]; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
elif [[ $arch == "arm"* ]]; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
else
  echo "Unsupported architecture. Exiting."
  exit 1
fi

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Ask the user if they want to install and initiate Docker Swarm
read -p "Do you want to install and initiate Docker Swarm? (y/n) " swarm_choice
if [[ $swarm_choice == "y" ]] || [[ $swarm_choice == "Y" ]]; then
  docker swarm init
fi

# Define a function to install applications using Docker
install_docker_app() {
  app_name="$1"
  app_install_cmd="$2"

  read -p "Do you want to install $app_name? (y/n) " install_choice
  if [[ $install_choice == "y" ]] || [[ $install_choice == "Y" ]]; then
    eval "$app_install_cmd"
  fi
}

# Install Nginx Proxy Manager
install_docker_app "Nginx Proxy Manager" "docker run -d -p 80:80 -p 81:81 -p 443:443 --name nginx_proxy_manager --restart always jlesage/nginx-proxy-manager"

# Install Traefik
install_docker_app "Traefik" "docker run -d --name traefik --restart always -p 8080:8080 -p 80:80 -p 443:443 -v $PWD/traefik.yml:/etc/traefik/traefik.yml -v /var/run/docker.sock:/var/run/docker.sock traefik:v2.5"

# Install Caddy
install_docker_app "Caddy" "docker run -d --name caddy --restart always -p 80:80 -p 443:443 -v $PWD/Caddyfile:/etc/caddy/Caddyfile -v caddy_data:/data caddy:2"

# Install Portainer CE
install_docker_app "Portainer CE" "docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce"

# Install Portainer Agent
install_docker_app "Portainer Agent" "docker run -d --name portainer_agent --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes
