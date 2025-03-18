#!/bin/bash

# IP of iSCSI server. Only need ONE IP. It will auto-discover other IPs.
NAS_IP="your-nas-ip"

# List of targets to mount
TARGETS=("target-wwn")

# Multipath disk alias
ALIAS="mpath0"

# iSCSI Mount Point
MOUNT_POINT="/mnt/nas"

# MS CHAP authentication variables
USERNAME="your-username"
PASSWORD="your-password"


## Private Vars. No touchy
WWNS=()
UNIQUE_WWNS=()
WWN=""
DEVICE_FILE=""

login_portal() {
    # Discover published targets once and store in a variable
    DISCOVERED_TARGETS=$(iscsiadm -m discovery -t st -p $NAS_IP)

    # List all existing targets
    EXISTING_TARGETS=$(iscsiadm -m node | awk '{print $2}')

    # Remove targets that do not match the TARGETS array
    for existing_target in $EXISTING_TARGETS; do
        if [[ ! " ${TARGETS[@]} " =~ " ${existing_target} " ]]; then
            echo "Removing target $existing_target"
            iscsiadm -m node -T $existing_target --logout
            iscsiadm -m node -T $existing_target --op=delete
        fi
    done

    # Main script execution
    for target in "${TARGETS[@]}"; do
        # Find the IP addresses associated with the target and strip the port
        target_ips=$(echo "$DISCOVERED_TARGETS" | grep "$target" | awk -F, '{print $1}' | awk -F: '{print $1}')

        for ip in $target_ips; do
            iscsiadm -m node -T $target -p $ip --op=update -n node.session.auth.authmethod -v CHAP
            iscsiadm -m node -T $target -p $ip --op=update -n node.session.auth.username -v $USERNAME
            iscsiadm -m node -T $target -p $ip --op=update -n node.session.auth.password -v $PASSWORD
            iscsiadm -m node -T $target -p $ip --op=update -n node.startup -v automatic
            iscsiadm -m node -T $target -p $ip --login
        done
    done
}

# Function to get the WWN for each iSCSI disk
get_disk_wwn() {
    for disk in $(lsscsi -t | grep -o '/dev/sd[a-z]'); do
        WWN=$(udevadm info --query=all --name=$disk | grep 'ID_WWN_WITH_EXTENSION=0x' | awk -F= '{print $2}' | sed 's/^0x//')
        if [[ -n $WWN ]]; then
            WWNS+=("$WWN")
        fi
    done
}

# Function to check if all WWNs are the same
check_wwns() {
    UNIQUE_WWNS=($(echo "${WWNS[@]}" | tr ' ' '\n' | sort | uniq))
    if [ ${#UNIQUE_WWNS[@]} -ne 1 ]; then
        echo "Error: Not all WWNs are the same!"
        #exit 1
    fi
    WWN=${UNIQUE_WWNS[0]}
}

# Function to generate /etc/multipath.conf
generate_multipath_conf() {
    cat <<EOF > /etc/multipath.conf
defaults {
        polling_interval        2
        path_selector           "round-robin 0"
        path_grouping_policy    multibus
        uid_attribute           ID_SERIAL
        rr_min_io               100
        failback                immediate
        no_path_retry           queue
        user_friendly_names     yes
}

blacklist {
        wwid .*
}

blacklist_exceptions {
EOF

    for wwn in "${UNIQUE_WWNS[@]}"; do
        echo "  wwid $wwn" >> /etc/multipath.conf
    done

    cat <<EOF >> /etc/multipath.conf
}

multipaths {
EOF

    for wwn in "${UNIQUE_WWNS[@]}"; do
        cat <<EOF >> /etc/multipath.conf
        multipath {
                wwid "$WWN"
                alias $ALIAS
        }
EOF
    done

    cat <<EOF >> /etc/multipath.conf
}
EOF

    echo "/etc/multipath.conf generated successfully."

    for wwn in "${UNIQUE_WWNS[@]}"; do
        multipath -a $WWN
    done
}

# Function to update /etc/fstab
update_fstab() {
  local fstab_line="/dev/mapper/$DEVICE_FILE    $MOUNT_POINT    ext4    _netdev 0   2"

  # Backup /etc/fstab
  cp /etc/fstab /etc/fstab.bak

  # Remove any existing line containing the alias and echo the removed lines
  echo "Removing any existing lines containing $ALIAS from /etc/fstab:"
  grep "$ALIAS" /etc/fstab | while read -r line; do
    echo "      DEL > $line"
  done

  # Remove the lines and update the fstab file
  grep -v "$ALIAS" /etc/fstab > /etc/fstab.tmp && mv /etc/fstab.tmp /etc/fstab

  # Append the new line
  echo "$fstab_line" >> /etc/fstab

  echo "Updated /etc/fstab with the following line:"
  echo "        ADD > $fstab_line"
}

# Function to check if multipath devices are loaded correctly
check_multipath() {
    DEVICE_FILE=$(multipath -ll | awk -v wwn="$WWN" '$0 ~ wwn {print $1}')
    if [[ -n $DEVICE_FILE ]]; then
        echo "Multipath device $DEVICE_FILE is loaded successfully."
    else
        echo "Failed to load multipath device $ALIAS. Please check the configuration."
        exit 1
    fi
}

echo "Connecting to portal..."
login_portal

echo "Generating multipath configuration"
# Main script execution
get_disk_wwn
check_wwns
generate_multipath_conf

echo "Reloading multipath"
multipath -r
check_multipath

echo "Multipath Configuration"
multipath -ll

echo "Updating /etc/fstab"
update_fstab

echo "Reloading daemons"
systemctl daemon-reload

echo "Reloading mounts."
mount -a