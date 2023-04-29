 #!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with sudo"
  exit
fi

# Define a function to uninstall applications using Docker
uninstall_docker_app() {
  app_name="$1"
  app_container_name="$2"

  read -p "Do you want to uninstall $app_name? (y/n) " uninstall_choice
  if [[ $uninstall_choice == "y" ]] || [[ $uninstall_choice == "Y" ]]; then
    docker rm -f $app_container_name
  fi
}

# Uninstall Portainer Agent
uninstall_docker_app "Portainer Agent" "portainer_agent"

# Uninstall Portainer CE
uninstall_docker_app "Portainer CE" "portainer"

# Uninstall Caddy
uninstall_docker_app "Caddy" "caddy"

# Uninstall Traefik
uninstall_docker_app "Traefik" "traefik"

# Uninstall Nginx Proxy Manager
uninstall_docker_app "Nginx Proxy Manager" "nginx_proxy_manager"

# Stop and disable Docker
systemctl stop docker
systemctl disable docker

# Uninstall Docker Compose
rm /usr/local/bin/docker-compose

# Uninstall Docker
if [[ -f /usr/bin/docker ]]; then
  apt-get purge -y docker-ce docker-ce-cli
elif [[ -f /usr/bin/dnf ]]; then
  dnf remove -y docker-ce docker-ce-cli
elif [[ -f /usr/bin/yum ]]; then
  yum remove -y docker-ce docker-ce-cli
else
  echo "Cannot determine the package manager. Exiting."
  exit 1
fi

# Remove Docker data and configurations
rm -rf /var/lib/docker
rm -rf /etc/docker
