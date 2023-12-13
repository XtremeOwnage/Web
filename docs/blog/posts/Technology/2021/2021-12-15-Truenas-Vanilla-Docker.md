---
title: "TrueNAS Scale - Use Vanilla Docker"
date: 2021-12-15
tags:
  - TrueNAS
  - Homelab
---

# TrueNAS Scale - Use Vanilla Docker

How to enable and leverage the vanilla docker built into TrueNAS Scale.

<!-- more -->

### This article is for you IF….
1. You wish to use a normal, vanilla docker experience.
2. You do NOT like kubernetes, and wish to use normal docker, or docker swarm.
3. You are a TECHNICAL INDIVIDUAL, who is capable of troubleshooting.

### This article is NOT for you IF….
1. You wish to be supported by IX-Systems. The below steps, are completely unsupported.
2. You want to use the built-in apps interface. This will break that.
3. You want to just point and click on the GUI to install plex. This is a hands-on process, for people familiar with managing docker via the CLI, or portainer.
4. You do not know what SSH, CLI, Bridges, Bonds is.

## Steps
### Step 1. Startup scripts

To use a vanilla docker experience, we first need to create a few scripts, intended to configure your docker experience.

The first step, is to build a docker/daemon.json file. Lets store this in a persistent directory. I personally use a dataset I created at `/mnt/Flash/docker`

Make sure to update the below file with your DNS server too. Or- if you don't have a DNS server, 8.8.8.8

``` json title="~/docker_config.json"
{
        "data-root": "/mnt/Flash/docker",
        "exec-opts": ["native.cgroupdriver=cgroupfs"],
        "storage-driver": "zfs",
        "iptables": true,
        "bridge": "",
        "dns": ["10.100.4.1"]
}

```

Make sure to update the DNS IP address to your DNS server.

Lastly, set the data-root to a persistent dataset on your system. Docker will store ALL of its images, volumes, and configuration here.

Next, we need a script to start, and configure docker.

This script does three things.

1. Stops docker service if it is running.
2. Remove any docker/daemon.json if it exists.
3. Copies the daemon.json we created earlier to the proper location.
4. Starts docker via systemctl.

``` shell title="~/setup-docker"
systemctl stop docker
rm /etc/docker/daemon.json
cp docker_config.json /etc/docker/daemon.json
systemctl start docker
```

At this point, if you invoke the above script, it should startup a fresh copy of docker.

If you run `docker ps`, It should return back an empty table, with nothing running. If not, something isn’t correct. Make sure your modified `docker/daemon.json` file has a new/fresh dataset that was not in use by the built-in apps before.

### Step 2. Install Portainer

I keep a script handy for installing and upgrading portainer.

This script will stop portainer if it is running. and remove its container if it exists.

It will then install portainer, and create a docker volume named “portainer_data” if it does not exist.

!!! info
    If you use portainer enterprise edition, replace `portainer-ce`, with `portainer-ee`

If you don’t use enterprise edition, portainer IS/WAS giving out free licensees for home users.

``` bash title="~/upgradeportainer"
docker stop portainer
docker rm portainer
docker pull portainer/portainer-ce:latest
docker run -d -p 9000:9000 \
--name=portainer --restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
portainer/portainer-ce:latest
```

After you have your script saved, `chmod+x upgradeportainer` to make the script executable, and then…. execute it.

Docker will proceed to download portainer, and install/run it.

From this point…. open a web browser and navigate to…. `https://YourTrueNASHost:9000/` and you should see portainer.

### Step 3. Re-enable docker compose.

In [Scale 22.02](https://jira.ixsystems.com/browse/NAS-115010), ix-systems decided to "disable" the ability the built-in docker-compose, and a few other binary files.

You can "re-enable" docker-compose by running....

``` bash
chmod +x /usr/bin/docker-compose
chmod +x /bin/docker-compose
```


## How to undo

If you wish to revert to the built-in apps, just delete your `/etc/docker/daemon.json`, disable the startup script you created and restart the docker service.



## Changes / History

* Nov 2022 - This post was originally written Dec 15, 2021, and located on the [Wordpress Blog](https://xtremeownage.com/2021/12/15/truenas-scale-use-vanilla-docker/). It was migrated here Nov 20, 2022.
* Mar 2022 - Confirmed this does still work for 22.02 release.
    -  To note- you can leverage [Docker compose using the built-in apps now](https://www.truenas.com/community/threads/truecharts-integrates-docker-compose-with-truenas-scale.99848/)