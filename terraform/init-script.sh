#! /bin/bash
sudo apt-get update && sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

mkdir -p ~/certificates
mkdir -p ~/nginx-config

openssl req -x509 -newkey rsa:4096 -keyout ~/certificates/nginx-selfsigned.key --nodes -out ~/certificates/nginx-selfsigned.crt -days 365 -subj "/C=NL/ST=North Holland/L=Amsterdam/O=EZBox Nginx/CN=nginx.acme"

cat <<EOF > ~/nginx-config/nginx.conf 
server {
listen 443 ssl;
server_name _;
ssl_certificate /etc/nginx/conf.d/ext/nginx-selfsigned.crt;
ssl_certificate_key /etc/nginx/conf.d/ext/nginx-selfsigned.key;
location ^~ /a {
rewrite ^/(a+)(.*)$ http://localhost$2;
}
}
EOF

sudo docker run -d -p 443:443 -p 80:80 -v ~/certificates:/etc/nginx/conf.d/ext -v ~/nginx-config/nginx.conf:/etc/nginx/conf.d/default.conf:ro -v /var/run/docker.sock:/tmp/docker.sock:ro nginx