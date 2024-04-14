# Keycloak Documentation

## Local dev

```bash
# Step 1: Build Docker Image
docker build . -t aniphoto-oauth-server

# Step 2: Start to run container
docker run --name aniphoto-oauth-server -p 8443:8443 -d \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=Password@123 -e KEYCLOAK_FRONTEND_URL="https://vohuynh19.info/auth" \
        aniphoto-oauth-server \
        start --optimized
```

Keycloak starts in production mode, using only secured HTTPS communication, and is available on <https://localhost:8443>.
Health check endpoints are available at <https://localhost:8443/health>, <https://localhost:8443/health/ready> and <https://localhost:8443/health/live>.
Opening up <https://localhost:8443/metrics> leads to a page containing operational metrics that could be used by your monitoring solution.

## Deployment and SSL reverse proxy setup

### update and upgrade

```bash
sudo apt update
sudo apt upgrade
```

### Set up the base path for bash

```bash
echo 'PATH=/usr/sbin/:$PATH' >> ~/.profile
source ~/.profile
```

### Install nginx

```bash
sudo apt install nginx
nginx -v
sudo systemctl status nginx
```

### Install ufw firewall

```bash
# Install ufw firewall
sudo apt install ufw
sudo ufw status

# Activate all nginx
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw allow 22/tcp

# Enable the firewall
sudo ufw enable
# Reload to apply new changes
sudo ufw reload
# Check if the firewall is enabled or not
sudo ufw status
```

### Install SSL certificate

``` bash
sudo apt install certbot python3-certbot-nginx
```

### Create an new domain (namecheap)

### Set up DNS

- Add A Record ~ keycloak ~ 149.28.132.67 (server external ip)
- Add CName Record ~ www.keycloak ~ keycloak.vohuynh19.info (register domain)

### Wait for namecheap to updates config. It takes around 1-2 minutes

```bash
# Create certificate for keycloak.vohuynh19.info
sudo certbot --nginx -d keycloak.vohuynh19.info -d www.keycloak.vohuynh19.info
# Check auto-renewal if it is activated or not
sudo certbot renew --dry-run

# Configure SSL reverse proxy with nginx
sudo unlink /etc/nginx/sites-enabled/default
cd /etc/nginx/sites-available
```

### Create config file

sudo nano keycloak.vohuynh19.conf

```text
server {
    listen 80;
    server_name keycloak.vohuynh19.info www.keycloak.vohuynh19.info;
    rewrite ^ https://keycloak.vohuynh19.info permanent;
}
server { 
    listen 443 ssl;
    server_name keycloak.vohuynh19.info www.keycloak.vohuynh19.info;

    ssl_certificate /etc/letsencrypt/live/keycloak.vohuynh19.info/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/keycloak.vohuynh19.info/privkey.pem;
    ssl_session_cache builtin:1000 shared:SSL:10m;
    ssl_protocols TLSV1 TLSV1.1 TLSV1.2 TLSV1.3;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header        Host                $host;
        proxy_set_header        X-Real-IP           $remote_addr;
        proxy_set_header        X-Forwarded-For     $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto   $scheme;
        proxy_pass http://149.28.132.67:8080;
    }
}
```

```bash
# Symbolic link to the view host
sudo ln -s /etc/nginx/sites-available/keycloak.vohuynh19.conf /etc/nginx/sites-enabled/keycloak.vohuynh19.conf
# Test config syntax
sudo nginx -t
# Restart nginx
sudo systemctl restart nginx
# Go back to root
cd
sudo apt update
```

### Install dependencies Download docker

``` bash
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl status docker.service

docker -v
docker compose version
sudo apt update
```

### Start keycloak server

```bash
sudo mkdir keycloak
cd keycloak

sudo nano Dockerfile
# Copy content from ./Dockerfile

# Build image
docker build . -t aniphoto-oauth-server

# Run instance in detach mode
docker run --name aniphoto-oauth-server -p 8080:8080 -p 8443:8443 -d -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=Password@123 -e KEYCLOAK_FRONTEND_URL="https://vohuynh19.info/auth" aniphoto-oauth-server start --optimized
```
