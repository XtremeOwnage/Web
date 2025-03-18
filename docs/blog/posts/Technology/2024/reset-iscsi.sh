#!/bin/bash

# Define the mount point
MOUNTPOINT="/mnt/nas"
MULTIPATH_DEVICE="mpatha"

# Function to check if the mount point is mounted
is_mounted() {
  mountpoint -q "$1"
}

# Stop Proxmox Backup Server
echo "Stopping Proxmox Backup Server..."
systemctl stop proxmox-backup
if [ $? -ne 0 ]; then
  echo "Failed to stop Proxmox Backup Server. Please check the service status."
  exit 1
fi

# Check if the mount point is mounted
if is_mounted "$MOUNTPOINT"; then
  # Unmount the mount point
  echo "Unmounting $MOUNTPOINT..."
  umount $MOUNTPOINT
  if [ $? -ne 0 ]; then
    echo "Mount point is busy. Trying to identify and terminate processes..."
    fuser -cuk $MOUNTPOINT
    umount $MOUNTPOINT
    if [ $? -ne 0 ]; then
      echo "Forcing unmount..."
      umount -l $MOUNTPOINT
      if [ $? -ne 0 ]; then
        echo "Failed to unmount $MOUNTPOINT. Please check if the mount point is in use."
        exit 1
      fi
    fi
  fi
else
  echo "$MOUNTPOINT is not mounted."
fi

# Remove from /etc/fstab
echo "Removing from /etc/fstab"
sed -i "\|/dev/mapper/$MULTIPATH_DEVICE\s\+$MOUNTPOINT\s\+ext4\s\+_netdev\s\+0\s\+2|d" /etc/fstab

# Check if the multipath device exists
if multipath -ll | grep -q "$MULTIPATH_DEVICE"; then
  # Flush the multipath device maps
  echo "Flushing multipath device maps..."
  multipath -f $MULTIPATH_DEVICE
  if [ $? -ne 0 ]; then
    echo "Failed to flush multipath device maps. Please check if there are any active multipath devices."
    exit 1
  fi
else
  echo "$MULTIPATH_DEVICE is not recognized as a multipath device."
fi

# Log out of all iSCSI sessions
echo "Logging out of all iSCSI sessions..."
iscsiadm -m node -U all
if [ $? -ne 0 ]; then
  echo "Failed to log out of iSCSI sessions. Please check the iSCSI connections."
  exit 1
fi

# Delete all iSCSI nodes
echo "Deleting all iSCSI nodes..."
iscsiadm -m node -o delete
if [ $? -ne 0 ]; then
  echo "Failed to delete iSCSI nodes. Please check the iSCSI configuration."
  exit 1
fi

echo "Successfully unmounted, unconfigured multipath, and disconnected iSCSI."