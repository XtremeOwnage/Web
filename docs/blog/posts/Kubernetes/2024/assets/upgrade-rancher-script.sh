#!/bin/bash

# Display current containers
echo "Current containers:"
docker ps --format "{{.Names}}"

# Get the current container name
CURRENT_CONTAINER=$(docker ps --format "{{.Names}}")

# Display current container name
echo "Current container: $CURRENT_CONTAINER"

# Prompt for old container name
read -p "Enter the old container name (press Enter for default '$CURRENT_CONTAINER'): " OLD_CONTAINER_NAME
OLD_CONTAINER_NAME=${OLD_CONTAINER_NAME:-$CURRENT_CONTAINER}

# Prompt for new container name
while true; do
    read -p "Enter the new container name (press Enter for default 'rancher'): " NEW_CONTAINER_NAME
    NEW_CONTAINER_NAME=${NEW_CONTAINER_NAME:-rancher}

    if [ "$NEW_CONTAINER_NAME" != "$OLD_CONTAINER_NAME" ]; then
        break
    else
        echo "Error: The new container name cannot be the same as the old container name. Please enter a different name."
    fi
done

echo "Old container name: $OLD_CONTAINER_NAME"
echo "New container name: $NEW_CONTAINER_NAME"

read -p "Are you ready to proceed? (yes/no): " PROCEED
if [ "$PROCEED" != "yes" ]; then
    echo "Operation aborted by the user."
    exit 1
fi

# Stop the existing Rancher container
docker stop $OLD_CONTAINER_NAME

# Pull the latest Rancher image
docker pull rancher/rancher:latest

# Start the new Rancher container with the same name and volumes, and set to always restart
docker run -d --restart=always \
        -p 80:80 -p 443:443 \
        --name $NEW_CONTAINER_NAME \
        --volumes-from $OLD_CONTAINER_NAME \
        --privileged \
        rancher/rancher:latest

# Prompt user to confirm removing the old container
read -p "Press Enter to remove the old container '$OLD_CONTAINER_NAME'..."
echo "Removing the old container '$OLD_CONTAINER_NAME'..."

# Remove the existing Rancher container
docker rm $OLD_CONTAINER_NAME