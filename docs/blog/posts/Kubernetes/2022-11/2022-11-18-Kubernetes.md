---
title: "Transitioning to Kubernetes"
date: 2022-11-18
tags:
  - Homelab
---

# The next homelab evolution & Static Site

## Introduction

Over the last few months, I decided to learn kubernetes. 

<!-- more -->

Now- I am a pretty technical person. I have computers and old enterprise hardware all over my house. I have been a software developer for over a decade now...

I previous had multiple docker servers running nearly 100 combined containers in my lab.

!!! warning
    **Spoiler**! There was indeed a steep learning curve associated with kubernetes.

You will often see people posting demonstrations of their setups online, posting how amazing it is, etc- but, you will hardly ever see the work which went into it, and the failures encountered.

I personally, failed quite a few times before achieving an environment for which I am happy with. I spent on and off- nearly two months finding what works, and what doesn't work.

I had to wade through depreciated software[^1]. I have encountered software which has not properly been updated[^2]. And- lots more.

### The bright side

However- after repeated efforts to build a cluster to my specifications- I was successful.

Not only successful, but, I **REALLY** like Kubernetes. There are things you can do here- which were quite a bit more difficult, or not even possible using docker.

The moral of this story- 

!!! quote
    If at First You Don't Succeed, Try, Try Again
    - Xen Cho [^3]

## A few topics I plan on addressing in the near future.

In the future- I plan on covering a few of the features I am really pleased with in more details.

1. Single Sign On, Using [Authentik](https://goauthentik.io/)
2. Backups using [Veeam/Kasten](https://www.kasten.io/product/)
3. Automated Monitoring and Data collection via [Promthesis](https://prometheus.io/) and [Grafana](https://grafana.com/) using the [Prometheus-Operator](https://github.com/prometheus-operator/prometheus-operator)
4. Automatically allocating GPUs for transcoding in Plex using [Intel Device Plugin](https://intel.github.io/intel-device-plugins-for-kubernetes/cmd/gpu_plugin/README.html) and [Node Feature Discovery](https://intel.github.io/kubernetes-docs/nfd/index.html)
5. Using [Ansible](https://www.ansible.com/) within Kubernetes to automatically provision servers, and build / push custom docker images. (This site runs on a custom container build using ansible.)
6. How to get your Coral TPU, Z-wave stick, and RTL_SDR working within a multi-node kubernetes cluster.
7. [Rook-Ceph](https://rook.io/), and why I chose to use it over [Longhorn.io](https://longhorn.io/)
8. Why and how I decided to post a static blog over using my existing [Wordpress](https://xtremeownage.com/)




[^1]: See [https://github.com/rancher/k3os/issues/846](https://github.com/rancher/k3os/issues/846). TLDR; When OpenSUSE acquired rancher- a few... support... issues arose.
[^2]: Longhorn took over a year to remove pod security policy from their helm charts, despite it being [depreciated in kubernetes v1.21.](https://kubernetes.io/blog/2021/04/08/kubernetes-1-21-release-announcement/#podsecuritypolicy-deprecation) See github issue [HERE](https://github.com/longhorn/longhorn/issues/4003). For a new-user trying to follow the setup directions on a current, up to date kubernetes cluster- this caused a lot of issues.
[^3]: [Reference](https://en.wikipedia.org/wiki/If_at_First_You_Don%27t_Succeed,_Try,_Try_Again)