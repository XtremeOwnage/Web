#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

SSH_KEYFILE="/config/user-data/id_rsa"
GIT_SERVER=gitea@gitea.yourdomain.com:youruser/yourrepo.git
LOCAL_REPO_PATH="/root/backup"

###########################################################################
###### Title: Ensure Directories are created
###########################################################################

# List of directories to create
directories=(
    "/config/user-data"
    "/config/user-data/hooks"
    "/config/scripts"
    "/config/scripts/post-config.d"
)

# List of files we will be creating.
files=(
    "/config/backup"
    "/config/user-data/edgerouter-backup.conf"
    "/config/user-data/hooks/03-edgerouter-backup.sh"
    "/config/scripts/post-config.d/ssh_keys.sh"
)

# Create each directory if it does not exist
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    else
        echo "Directory already exists: $dir"
    fi
done

###########################################################################
###### Title: Generate new SSH Key
###### Description: Set upstream package repo. Needed to install git
###########################################################################

echo -e "\n\n\n"

# Check if the SSH key file exists
if [ ! -f $SSH_KEYFILE ]; then
    echo "SSH key not found. Generating a new SSH key..."
    ssh-keygen -t rsa -b 2048 -f $SSH_KEYFILE -N ""    
    echo "New SSH key generated at $SSH_KEYFILE"

    echo "###########################################################################"
    echo "#### PUBLIC KEY. (Make sure to add this to your github/gitea/git server/etc.)"
    echo -e "###########################################################################\n"
    cat $SSH_KEYFILE.pub
    echo -e "\n###########################################################################"
    echo "#### END PUBLIC KEY"
    echo -e "###########################################################################\n\n\n"   
else
    echo "SSH key found at $SSH_KEYFILE"
    echo "###########################################################################"
    echo "#### PUBLIC KEY. (Make sure to add this to your github/gitea/git server/etc.)"
    echo -e "###########################################################################\n"
    cat $SSH_KEYFILE.pub
    echo -e "\n###########################################################################"
    echo "#### END PUBLIC KEY"
    echo "###########################################################################"   
fi

echo -e "\n\n\n"

###########################################################################
###### Title: Prompt user to update git server security
###########################################################################

# Display the public key
echo "Please add the above public key to the security configuration for $GIT_SERVER"


# Pause and prompt the user to update their configuration
read -p "Press Enter to continue after you have added the public key to $GIT_SERVER..."

echo "Continuing with the script...\r"

###########################################################################
###### Title: Update Configuration - Set Package Repository
###### Description: Set upstream package repo. Needed to install git
###########################################################################

echo "Added system > package > repository configuration for debian stretch"

configure

# Add Debian strech repo.
set system package repository stretch components 'main'
set system package repository stretch distribution stretch
set system package repository stretch url http://archive.debian.org/debian

# Commit changes
commit

###########################################################################
###### Title: Install git
###########################################################################

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    apt-get update && apt-get install git -y
else
    echo "Git is already installed."
fi

###########################################################################
###### Title: Create /config/backup
###### Description: Helper script which kicks off a backup.
###########################################################################

cat << 'EOF' > /config/backup
#!/bin/bash
/config/user-data/hooks/03-edgerouter-backup.sh
EOF

echo "File /config/backup created successfully."

###########################################################################
###### Title: Create /config/user-data/edgerouter-backup.conf
###### Description: This creates the primary configuration file used by scripts.
###########################################################################

# This is the main configuration file used.
cat << EOF > /config/user-data/edgerouter-backup.conf
#!/bin/bash

# Default commit message
DEFAULT_COMMIT_MESSAGE="Auto commit by edgerouter-backup on \$HOSTNAME"

# Path to git repo
REPO_PATH=$LOCAL_REPO_PATH

# Names for EdgeRouter configuration backup files. If you are backing
# up multiple EdgeRouters to the same place you'll want to ensure that
# FNAME_BASE is unique to each EdgeRouter
FNAME_BASE=\$HOSTNAME

FNAME_CONFIG=\$FNAME_BASE.config.conf
FNAME_CLI=\$FNAME_BASE.commands.conf

# Base filename, no .tar.gz extension!
FNAME_BACKUP=\$FNAME_BASE.backup
EOF

echo "File /config/user-data/edgerouter-backup.conf created successfully."

###########################################################################
###### Title: Create /config/user-data/hooks/03-edgerouter-backup.sh
###### Description: The script which actually creates the git commit, and pushes.
###########################################################################

# Create the 03-edgerouter-backup.sh file
cat << 'EOF' > /config/user-data/hooks/03-edgerouter-backup.sh
#!/bin/bash

# This script runs during the commit

source /config/user-data/edgerouter-backup.conf

# Pull commit info
COMMIT_VIA=${COMMIT_VIA:-other}
COMMIT_CMT=${COMMIT_COMMENT:-$DEFAULT_COMMIT_MESSAGE}

# If no comment, replace with default
if [ "$COMMIT_CMT" == "commit" ];
then
    COMMIT_CMT=$DEFAULT_COMMIT_MESSAGE
fi

# Check if rollback
if [ $# -eq 1 ] && [ $1 = "rollback" ];
then
    COMMIT_VIA="rollback/reboot"
fi

TIME=$(date +%Y-%m-%d" "%H:%M:%S)
USER=$(whoami)

GIT_COMMIT_MSG="$COMMIT_CMT | by $USER | via $COMMIT_VIA | $TIME"

# git commit and git push on remote host
echo "edgerouter-backup: Triggering 'git commit'"

# Set working directory
cd $REPO_PATH

# Copy files we wish to backup
cp /config/config.boot .
cp /config/*.leases .
cp -R /config/user-data .
cp -R /config/scripts .

# Git Add
git add config.boot
git add *.leases
git add user-data/*
git add scripts/*

git commit -m "$GIT_COMMIT_MSG"
git push

echo "edgerouter-backup: Complete"
EOF

echo "File /config/user-data/hooks/03-edgerouter-backup.sh created successfully."

###########################################################################
###### Title: Create /config/scripts/post-config.d/hooks.sh
###### Description: The main "init" script. Creates expected symlinks. Ensures execute flags are set.
###########################################################################

# Create post-config hooks
cat << EOF > /config/scripts/post-config.d/hooks.sh
#!/bin/bash
source /config/user-data/edgerouter-backup.conf

# Fix ownership / permissions
sudo chown -R root:vyattacfg /config/user-data
sudo chown -R root:vyattacfg /config/scripts
sudo chmod -R ug+w /config/user-data
sudo chmod -R ug+w /config/scripts
sudo chmod g-w $SSH_KEYFILE

# Ensure scripts are executable
sudo chmod +x /config/user-data/hooks/*

# Generate symlinks for sshkey
sudo ln -fs $SSH_KEYFILE /root/.ssh/id_rsa
sudo ln -fs $SSH_KEYFILE.pub /root/.ssh/id_rsa.pub

# Generate symlinks to hook script(s)
sudo ln -fs /config/user-data/hooks/* /etc/commit/post-hooks.d/

exit 0
EOF

echo "File /config/scripts/post-config.d/hooks.sh created successfully."

###########################################################################
###### Title: Create /config/scripts/post-config.d/ssh_keys.sh
###### Description: This sets the expected permissions for ssh keys.
###########################################################################

cat << 'EOF' > /config/scripts/post-config.d/ssh_keys.sh
#!/bin/bash
source /config/user-data/edgerouter-backup.conf

# This script runs at boot of the EdgeRouter

# Set ownership and permissions for root user so that ssh/scp don't complain.
sudo chown root $SSH_KEYFILE
sudo chmod 600 $SSH_KEYFILE

exit 0

EOF

echo "File /config/scripts/post-config.d/hooks.sh created successfully."

###########################################################################
###### Title: Initialize Scripts
###### Description: This ad-hoc sets the execute flag, and executes the main hooks/init script.
###########################################################################

echo "Setting file permissions...."
# Set Execute Flag on new files
for f in "${files[@]}"; do
    chmod +x $f
    chown root:vyattacfg $f
    chmod ug+w $f
done

###########################################################################
###### Title: Clone Repo
###### Description: Clone git repo to another local path.
###########################################################################

# Clone the repository
git clone $GIT_SERVER $LOCAL_REPO_PATH

echo "Repository cloned from $GIT_SERVER to $LOCAL_REPO_PATH"


# Run the init script.
echo "Running init script"

/config/scripts/post-config.d/hooks.sh

###########################################################################
###### Title: Update Configuration - Set scheduled task to execute backup
###### Description: Creates a scheduled tasks which will execute the backup script.
###########################################################################

echo "Setting system > task-scheduler > task > backup-config"

configure

# Schedule backup script.
set system task-scheduler task backup-config crontab-spec '0 * * * *'
set system task-scheduler task backup-config executable path /config/backup

commit

echo "Saving changes. Script execution complete."

save
