#!/bin/bash
echo "Updating System"
sudo apt update -y
echo "Upgrading System"
sudo apt upgrade -y
echo "Installing Docker" 
sudo apt install docker.io -y
echo "Creating docker volume portainer_data"
sudo docker volume create portainer_data
echo "Installing portainer"
sudo docker run -d --network=host --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
echo "Done! Please configure portainer on https://localhost:9443"
echo "Installing Nextcloud"
sudo apt install apache2 -y 
sudo apt install php libapache2-mod-php php-imagick php-common php-mysql php-gd php-json php-curl php-zip php-xml php-mbstring php-bz2 php-intl php-bcmath php-gmp php-dom unzip -y
sudo systemctl reload apache2
sudo apt install mariadb-server -y
sudo mysql_secure_installation
echo "Please type this into the mysql cli. Make sure to change your_password to your password " 
echo "CREATE DATABASE nextcloud;
GRANT ALL ON nextcloud.* TO 'jude'@'localhost' IDENTIFIED BY 'your_password';
FLUSH PRIVILEGES;
EXIT;"
sleep 10
sudo mysql -u root -p
echo "Install Nextcloud"
wget https://download.nextcloud.com/server/releases/nextcloud-25.0.3.zip
sudo unzip nextcloud-25.0.3.zip -d /var/www/html/
sudo mkdir /var/www/html/nextcloud/data
sudo chown -R www-data:www-data /var/www/html/nextcloud/
echo "Please configure nextcloud on http://localhost/nextcloud/"
echo "Install HomeAssistant"
sudo docker volume create hass
sudo docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=New_York \
  -v hass:/config \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable
echo "Please configure home assistant at http://localhost:8123"
echo "Installing JellyFin"
curl https://repo.jellyfin.org/install-debuntu.sh | sudo bash
echo "Please configure jellyfin at http://localhost:8096"
echo "Installing Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh
echo "Installing Heimdall"
sudo docker volume create heimdall
sudo docker run -d \
  --name=heimdall \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -p 443:443 \
  -v heimdall:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/heimdall:latest
