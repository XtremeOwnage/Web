  GNU nano 7.2                                                                                                         remove-locks
#!/bin/bash

# Function to get running containers
get_containers() {
  docker ps --format "{{.Names}}"
}

# Detect running containers
containers=$(get_containers)
container_count=$(echo "$containers" | wc -l)

# Handle cases based on container count
if [ "$container_count" -eq 0 ]; then
  echo "No running containers found."
  exit 1
elif [ "$container_count" -eq 1 ]; then
  CONTAINER_NAME=$(echo "$containers" | head -n 1)
  read -p "Only one container found: $CONTAINER_NAME. Do you want to proceed? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    echo "Operation canceled."
    exit 0
  fi
else
  echo "Multiple containers found:"
  echo "$containers" | nl
  read -p "Enter the number of the container to use: " choice
  CONTAINER_NAME=$(echo "$containers" | sed -n "${choice}p")
  if [ -z "$CONTAINER_NAME" ]; then
    echo "Invalid choice. Exiting."
    exit 1
  fi
fi

# Define the root directories to search for .git directories
ROOT_DIRECTORIES=(
  "/var/lib/rancher/management-state/git-repo"
  "/var/lib/rancher-data/local-catalogs/v2"
)

# Kill all git processes inside the container
# Note... no PS inside of the rancher container.
#docker exec $CONTAINER_NAME sh -c "
#  for pid in \$(ps aux | grep '[g]it' | awk '{print \$1}'); do
#    kill -9 \$pid && echo 'Killed git process with PID: \$pid';
#  done"

# Loop through root directories to find and clean .lock files in .git directories
for root_dir in "${ROOT_DIRECTORIES[@]}"; do
  docker exec $CONTAINER_NAME sh -c "
    if [ -d $root_dir ]; then
      find $root_dir -type f -path '*/.git/*.lock' -exec rm -f {} \\; -exec echo 'Removed lock file: {}' \\;
    else
      echo 'Directory not found: $root_dir';
    fi"
done