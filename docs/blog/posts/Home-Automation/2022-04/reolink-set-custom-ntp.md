---
title: "Reolink RLC-520 - Set Custom NTP"
date: 2022-04-24
categories:
    - Home-Automation
    - Technology
tags:
    - NVR
---

# Set Custom NTP for Reolink Cameras

I have a few Reolink cameras. Recently, I noticed the time of many of the cameras was not set correctly.

Since, I keep all of my IOT and Security devices isolated from the internet, they are not able to communicate with the pre-defined external NTP server. However, I do have a NTP server running on my opnsense firewall which they do have access to.

But, it appears the ability to set a custom NTP server no longer exists in the reolink’s configuration page.

<!-- more -->

## The Solution? A rest API.

Just a simple rest-api call. That is the only solution required here.

Just replace YOUR_CAMERAS_IP, YOUR_NTP_SERVER_IP, YOUR_USER_ID, and YOUR_PASSWORD with the proper values.

``` bash
curl -X POST -i 'http://YOUR_CAMERAS_IP/cgi-bin/api.cgi?cmd=SetNtp&user=YOUR_USER_ID&password=YOUR_PASSWORD' --data '[
{
"cmd":"SetNtp",
"param":{
"Ntp":{
"enable":1,
"server":"YOUR_NTP_SERVER_IP",
"port":123,
"interval":1440
}
}
}
]'
```

After executing the command, you will get back a response.

```
HTTP/1.1 200 OK
Date: Thu, 28 Apr 2022 15:31:56 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
[
   {
      "cmd" : "SetNtp",
      "code" : 0,
      "value" : {
         "rspCode" : 200
      }
   }
]
```

In this case, rspCode, or Response Code, 200 means, Success.

After this, you should be good to go.

Credit for this, goes to [THIS POST](https://www.reddit.com/r/reolinkcam/comments/knuffw/comment/ghscc1h/?utm_source=share&utm_medium=web2x&context=3){target=_blank} on reddit.