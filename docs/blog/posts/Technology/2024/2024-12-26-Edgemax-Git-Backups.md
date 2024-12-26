---
title: Edgemax - Git Backups
date: 2024-12-26
tags:
    - Homelab
    - Networking
    - Networking/Edgemax
---

# Edgemax - Auto sync configuration to git

Many years ago, I had setup a system which would automatically sync my Edgemax's configuration to a local git repo.

It worked so good, I had completely forgotten about it. During a firmware update last year, it had stopped working.

So- I went through, fixed and updated the scripts- and I am now sharing them with you.

<!-- more -->

## Before you start

!!! danger
    Take backups!!!!!

    I am not responsible for you losing your entire configuration !

    Take a backup before you touch anything. Save it somewhere AWAY from the router.

### Prerequisites

1. Have a working git repository.
2. Edgerouter/Edgemax will need internet access to download the git package.

## Details 

## What this script will do

1. Generate a hook causing a git commit to be created every time the configuration is updated.
2. System package configuration will be updated, to include archived debian squeeze. This is needed to install git.
3. Git will be installed.
4. A new ssh-key will be generated, if one does not already exist.
    - You will be presented with the public key, and prompted to add it to your git repo/server.
5. A scheduled task will be configured, which will do a periodic backup. 
    - This is to capture dhcp leases.
6. Generate a hook, which runs at system boot
    - Set expected permissions, and ownership of scripts.
    - Create sym links for ssh keys, and hooks

## What will be stored in git?

1. `/config/config.boot`
    - This is the primary configuration file.
2. `/config/*leases`
    - DHCP Leases
3. `/config/user-data`
    - Associated scripts, and any other custom user-data you have stored.
    - Note- This will include your private key. If this is not wanted, modify `/config/user-data/hooks/03-edgerouter-backup.sh` to remove this step.
4. `/config/scripts`

You can modify as you like to add, or remove any other data.

## How does the data get backed up?

After the script has been installed, a hook will be generated in `/etc/commit/post-hooks.d`

After you have executed "commit", this will invoke the script, which will create a backup.

In addition to the above hook, the backup script will also run on a periodic timer, which lives in your configuration under `System > Task Scheduler > Task > Backup Config`

Once the script has been invoked, it will copy selected files to the cloned repo, which by default is stored in `/root/backup`

Then, each of the files will be added to a new commit. The message will be automatically generated, and the changes will be pushed.

Thats, basically it.

## Installation

The entire script is [LOCATED HERE](./assets/edgemax-install-script.sh)

You will need to modify ONE line. It is at the very top of the script.

``` bash title="edgemax-install-script.sh"
# Update this to point at YOUR git server.
GIT_SERVER=gitea@gitea.yourdomain.com:youruser/yourrepo.git
```

No other changes are needed.

For a mostly scripted install...

First- this will download the script, and open in an editor.

!!! warning
    As a general warning- I do not recommend blinding downloading and running scripts from the internet.

    Please **ALWAYS** do your due diligence to validate what you are running.

    Even if you trust me- I don't control what happens between my server, and you. Always analyze scripts.

``` bash
SCRIPT_FILENAME=/tmp/setup-git-sync
curl https://static.xtremeownage.com/blog/Technology/2024/assets/edgemax-install-script.sh > $SCRIPT_FILENAME
# Open VI, so you can update the configuration. Set your git server.
vi $SCRIPT_FILENAME 
```

After you have made your required changes (update the git repo), we can add the execute flag, and run it.

``` bash
# Set script as executable.
chmod +x $SCRIPT_FILENAME

# Execute the script
$SCRIPT_FILENAME
```


### Resulting output

Since- I already had everything configured- there are not many changes. However, I did ensure the script is re-enterable. That is- running it multiple times, will not break anything.

``` bash
Linux fw2 4.9.79-UBNT #1 SMP Thu Jun 15 11:34:57 UTC 2023 mips64
Welcome to EdgeOS
Last login: Thu Dec 26 15:39:24 2024 from 10.100.5.5
root@fw2:~# SCRIPT_FILENAME=/tmp/setup-git-sync

# Note- by the time you read this- it won't be pointing at the dev site.

root@fw2:~# curl https://dev.static.xtremeownage.com/blog/Technology/2024/assets/edgemax-install-script.sh > $SCRIPT_FILENAME
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 10219  100 10219    0     0  23401      0 --:--:-- --:--:-- --:--:-- 23438
root@fw2:~# # Open VI, so you can update the configuration. Set your git server.
root@fw2:~# vi $SCRIPT_FILENAME
root@fw2:~# # Set script as executable.
root@fw2:~# chmod +x $SCRIPT_FILENAME
root@fw2:~#
root@fw2:~# # Execute the script
root@fw2:~# $SCRIPT_FILENAME
Directory already exists: /config/user-data
Directory already exists: /config/user-data/hooks
Directory already exists: /config/scripts
Directory already exists: /config/scripts/post-config.d

SSH key found at /config/user-data/id_rsa

###########################################################################
#### PUBLIC KEY. (Make sure to add this to your github/gitea/git server/etc.)
###########################################################################

# Note, Its a public key. Its not sensitive. Hence, the name "Public" key. Don't get too excited. 

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgbzBQ5KSiOjq73noF3LFCbZFf/9JCqwIWM/uLCgtvcbLyXKoyYrkymQ2be9aRGaYMSn5gOg6WweKKwSDmZ2CA0/hj5GnyaGVp327LdF7CWOVMlJDumm/1/rhM6Jp2dr72tkI08LfJ4cWjh715Tlq6mQsiW9SqNA6LgJgzwgVd/RnM1dVX8jPuYMLFpnScrcvea6Qsfbet0JM2X1jDRfNQZOZ+BY3+aKnnk+ISzZI6AbcFnEKPEQnCc8DqNAivjdBBq0LXsOc+vBJFZ+so+RgpCBD3NWfo9RIwXRQ3R9VZgeHsySv4tL3uc7uZ4S39NxMnhzzjVH/hlI1lkEPKynzebrofT72SLP4R8drXeh3zebjpgcynaCgjqJQvXcE5MPwL6Md//sF3hWY11ep+6ssGx4iowu+FIkmTYiLXOibAMYvGL+Rktme3olkur4zeB4JveBF1KFvY4MMwLDfTjMBadaET1GoJnfFS2dUozwn46rSHW7GlDqx3162FTi51GDt2czIQYa7IGUbf2ymGZTN9/xdvxQx5fwjqcbiGfhFV8ExnuvcjQmS5BpIu5jS0gJo17aLPHbEZ0+tB7t6gNDCM8Fx/Hw39u/jRnj8bvN+40QNFGMRODm6iPVOBEU13lBVpc6Yf6x6tvao39AtfRo6JAoD/k8R0OkAVg6Cg1GK6Vw== root@fw2

###########################################################################
#### END PUBLIC KEY
###########################################################################

# Note- git address, repo, username anonymized

Please add the above public key to the security configuration for gitea@mydomain.com:myuser/myrepo.git
Press Enter to continue after you have added the public key to gitea@mydomain.com:myuser/myrepo.git...
Continuing with the script...\r # This non-interpreted carriage return will also be fixed.
Added system > package > repository configuration for debian stretch
The specified configuration node already exists
The specified configuration node already exists
The specified configuration node already exists
Git is already installed.
File /config/backup created successfully.
File /config/user-data/edgerouter-backup.conf created successfully.
File /config/user-data/hooks/03-edgerouter-backup.sh created successfully.
File /config/scripts/post-config.d/hooks.sh created successfully.
File /config/scripts/post-config.d/hooks.sh created successfully.
Setting file permissions....
fatal: destination path '/root/backup' already exists and is not an empty directory.
Repository cloned from gitea@mydomain.com:myuser/myrepo.git to /root/backup
Running init script
Setting system > task-scheduler > task > backup-config
The specified configuration node already exists
The specified configuration node already exists
Saving changes. Script execution complete.
Saving configuration to '/config/config.boot'...
Done
```


And.... history-

``` bash
root@fw2:~/backup# git log
commit ac802967acb93633a91f03f90884d8e7aea493a6
Author: root <root@fw2.xtremeownage.com>
Date:   Thu Dec 26 17:00:02 2024 -0600

    Auto commit by edgerouter-backup on fw2 | by root | via other | 2024-12-26 17:00:02

commit c886aeb3c2b23c630fed4ef320f2c95b8c29bacb
Author: root <root@fw2.xtremeownage.com>
Date:   Thu Dec 26 16:44:44 2024 -0600

    Auto commit by edgerouter-backup on fw2 | by root | via other | 2024-12-26 16:44:44

commit e4d10da5067faab3783f9a1bdabdc7df0cb4aa53
Author: root <root@fw2.xtremeownage.com>
Date:   Thu Dec 26 16:36:40 2024 -0600

    Updated scripts

commit 06bca4b198ad2d3c17d27666e78a2db81db70921
Author: root <root@fw2.mgmt.xtremeownage.com>
Date:   Thu Dec 26 16:33:02 2024 -0600

    Auto commit by edgerouter-backup on fw2 | by root | via other | 2024-12-26 16:33:02

commit 86f49d2eebfacfeecd9358620a0ffe25dcda1039
Author: root <root@Router.xtremeownage.com>
Date:   Thu Aug 19 12:34:01 2021 -0500

    Auto commit by edgerouter-backup on Router | by root | via other | 2021-08-19 12:34:01

commit 6b7b2c2878e326dce8c50c07fa2a4da5bf8047b2
Author: root <root@Router.xtremeownage.com>
Date:   Thu Aug 19 12:00:01 2021 -0500

    Auto commit by edgerouter-backup on Router | by root | via other | 2021-08-19 12:00:01

commit 89135eae5f462e4b88c2fc7a13d6cb2cc03d2168
Author: root <root@Router.xtremeownage.com>
Date:   Thu Aug 19 11:00:01 2021 -0500

    Auto commit by edgerouter-backup on Router | by root | via other | 2021-08-19 11:00:01

commit fcbba6781306b1f2547223bd59cef24de19b21bc
Author: root <root@Router.xtremeownage.com>
Date:   Thu Aug 19 09:00:02 2021 -0500

    Auto commit by edgerouter-backup on Router | by root | via other | 2021-08-19 09:00:01
```


## Summary

Thats, basically it.

You... change the configuration, it commits it to git.

Its not perfect, and I am sure there are flaws. However, it suits my needs. 

And- I am sharing it with you. 

If, you do have a good idea, or enhancement, feel free to share it, there are social links in both the header, and footer of this site.