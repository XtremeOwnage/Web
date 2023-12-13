---
title: "Static Site"
date: 2022-11-19
tags:
  - Homelab
---

# Why I am migrating away from wordpress

Why am I moving away from wordpress?

<!-- more -->

Three reasons.

1. Security
2. Performance
3. Reliability

## Security

Wordpress is not the most secure platform in the world. Over the last 15 years or so, it has had [quite a few](https://www.cvedetails.com/product/4096/Wordpress-Wordpress.html?vendor_id=2337){target=_blank} CVEs. 

I am not immune to them. One of my other sites was pwned a year or two back, due to an expoit in [a SMTP Plugin](https://blog.detectify.com/2020/12/21/how-attackers-exploit-the-wordpress-easy-wp-smtp-zero-day/){target=_blank}. Knock on wood- the damage was rather limited since I do not collect customer data, accounts- or well, anything at all useful. Restoring, was quite an easy task because I do validate my backups.

However- Its only a matter of time before it happens again, and potentially causes worse impact.

Given the scale of the wordpress ecosystem, and the number of plugins, and execuable logic hidden throughout- there are many attack surface which attacks can take advantage of.

By making the move to a 100% static website- This removes nearly all potentially expoitable methods. 

1. The web server itself, is nothing more then an **unprivileged** nginx serving http files. There is no php. No javascript. Nothing at all, besides html, css, and a few images.
2. In the event somebody did manage to exploit nginx, it runs with zero privilages. It doesn't even have the ability to update its own files.
    1. The file system is also COMPLETELY read-only.
    2. Somebody would need to exploit both a zero-day vulnerability against NGINX, as well as a zero-day privilege escalation against the underlying container, and finally, a container-escape elevation.
    3. Gaining access to the container itself, without going a container-escape, wouldn't help too much- as these containers are extremely locked down network-wise as well. They can access the internet, and they can respond to responses from the proxy server (for which you are reading this article through).
3. Lastly- since there is no database, no middletiers, etc... There is nothing to host!

## Performance

A big factor, is performance and resources in general. This entire site can be cached into less than 100Mb of ram. (currently.... before I port over a lot of the old articles...)

It requires basically no resources whatsoever to host. As such, spinning up multiple instances to load balance traffic, is effortless as well.

Finally- since all of the content is completely static, it is all cachable upstream. As such, it is likely you are reading a cached copy right now.

## Reliability

While- I have not had any notable reliability issues with [https://XtremeOwnage.com/](https://xtremeownage.com/){target=_blank}, since it currently resides on my network, on a single machine- any time I do network maintenance, or maintenance for that particular machine- my site will come offline. 

And- since wordpress is a very dynamic site, its content is not suitable for offline cache. 

However- in the future, this website can be easily hosted by either [CloudFlare Pages](https://pages.cloudflare.com/){target=_blank} or [Github Pages](https://pages.github.com/){target=_blank} for basically free.

~~Until then however- I have multiple copies distributed amongsty my Kubernetes cluster to keep everything online.~~

*Correction*- This website is hosted by [CloudFlare Pages](https://pages.cloudflare.com/){target=_blank}.

## Other reasons?

### Privacy

As my wordpress has lots of random scripts, addons, and plugins running- Privacy is a concern to me. I don't know which of the external resources may be leaking your data.

With this site- there are very, very few external resources loaded, which limits the amount of potential exposure.

### Usability

As a developer, I tend to write markdown quite frequently. Since- I can write these posts in markdown- It feels easy to me. I don't have to mess around with Wordpress's slow editor... It's basically second nature to me to create markdown.

So, for me personally, Its much easier to create content.

## Closing Notes

You can expect a lot of my old content to continue to be ported over into this new static site. 

One notable thing missing, is the ability to subscribe to new posts. If you want to be notified when a new post is available, I would recommend subscribing to this site's [RSS FEED](/feed_rss_created.xml) in your favorite feeder.


If you do find my content useful- let me know on Reddit, Discord, Facebook, etc.... Links are at the top of the page, left of the search box.