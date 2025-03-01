
#!/bin/bash

# Add Docker's official GPG key:
apt-get update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

# Install Docker
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Mount and format /data
mkfs.ext4 /dev/vdb
mkdir -p /data
echo "UUID=$(blkid -s UUID -o value /dev/vdb) /data ext4 defaults 0 2" >> /etc/fstab
systemctl daemon-reload
mount -a

cat <<EOF > /root/docker-compose.yml
---
services:
  grocy:
    image: lscr.io/linuxserver/grocy:latest
    container_name: grocy
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /data:/config
    ports:
      - 80:80
    restart: unless-stopped

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_POLL_INTERVAL=3600  # Check for updates every hour
      - WATCHTOWER_LABEL_ENABLE=true  # Only update labeled containers
    restart: unless-stopped
EOF


# Run stack.
docker compose up -d

