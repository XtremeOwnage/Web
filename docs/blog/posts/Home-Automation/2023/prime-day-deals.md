---
title: "2023 Prime Day Deals"
date: 2023-07-11
categories:
    - Home-Automation
    - Technology
tags:
    - Home Assistant
    - Energy Monitoring
    - ESPHome
---

# 2023 Prime Day Deals

Interested in home automation? Here are a few of the prime day deals I would personally recommend. 

Note, this is not a kitchen-sink post full of non-relaxant links, but, rather, a list of things I have hands on experience with. 

Every single product linked below, will work with Home Assistant, 100% LOCALLY, without any required cloud services or subscriptions.

If, you need reasons as to why required cloud services are bad, see [Reasons to avoid cloud products](./../living-posts/reasons-to-avoid-cloud-products.md){target=_blank}

<!-- more -->

## Home Automation

### Smart Plugs

#### Sonoff S31

These are my absolute favorite smart plug at this point in time. I have 30 of these laying around. I use them for turning things on and off. I use them for tracking energy consumption.

Rock solid plugs.

These are flashable to tasmota / esphome. These work 100% locally. The built-in firmware will also work locally too.

Native home assistant integration.

* [Amazon](https://www.amazon.com/Sonoff-Monitoring-Compatible-Assistant-Supporting/dp/B08X2944W7?crid=S4NC9NFC660&keywords=sonoff%2BS31&psr=PDAY&qid=1689086017&s=prime-day&sprefix=sonoff%2Bs31%2Cprime-day%2C149&sr=1-1-spons&sp_csd=d2lkZ2V0TmFtZT1zcF9hdGY&m=A2QBZNDSRNO1IV&SPES=1&th=1&linkCode=sl1&tag=mobilea09d6c7-20&linkId=cf8126289ee7dd3b062607e46837ddc7&language=en_US&ref_=as_li_ss_tl){target=_blank}
* [My Review / Install / Guide (2023)](./sonoff-s31-low-cost-energy-plug.md)
* [Esphome](https://devices.esphome.io/devices/Sonoff-S31){target=_blank}

Note- 

Do NOT buy the S40s! They do not run esp chips, and cannot be flashed!!!!

#### Sonoff S31 Lite

If you don't need energy monitoring, and want to save a few bucks over the S31, you can instead opt for the S31 Lite.

Rock solid plugs.

These are flashable to tasmota / esphome. These work 100% locally. The built-in firmware will also work locally too.

Native home assistant integration.

* [Amazon](https://amzn.to/44iazDn){target=_blank}
* [Esphome](https://devices.esphome.io/devices/Sonoff-S31-lite){target=_blank}

Note- 

Do NOT buy the S40s! They do not run esp chips, and cannot be flashed!!!!

#### Kasa HS103 - Smart Plug

Generic 15 amp smart plug. No energy monitoring.

I still have 10 of these around the house, and they do work well. But, I prefer sonoff S31s flashed with esphome instead.

These do work 100% locally, but, requires a phone app for initial setup.

Native home assistant integration.

* [Amazon](https://amzn.to/46Imb4k){target=_blank}

#### Kasa KP405 - Outdoor Watertight Dimmer

These plugs are quite handy for outdoor use. I have one I use for controlling yard decorations during christmas time. 

These do work 100% locally, but, requires a phone app for initial setup.

Native home assistant integration.

* [Kasa KP405](https://amzn.to/3NNUvSZ){target=_blank}

### Powerstrips

#### Kasa HS300

6 socket, individually controllable powerstrip with per-plug energy monitoring. 

These do work 100% locally, but, requires a phone app for initial setup.

Native home assistant integration.

* [Kasa HS300 - Amazon](https://amzn.to/3DdgMoc){target=_blank}
* [My HS300 Review / Install / Guide (2022)](./../2022/kasa-powerstrip.md){target=_blank}

I have 5 of these around for various use-cases, and can say, they work pretty nicely.

### Other

#### Sonoff

All of these products can be flashed to esphome. These are also quite small, and will easily fit inside of a normal outlet box, or switch box.

I have been running the older variants for years. The new "Plus" models are based on esp32 instead of esp8266, and offer bluetooth now as well.

* [Shelly Plus 1PM](https://amzn.to/46WoyAT){target=_blank}
    * Single circuit with energy monitoring.
    * [Esphome](https://devices.esphome.io/devices/Shelly-Plus-1PM){target=_blank}
* [Shelly Plus 2PM](https://amzn.to/3O6pUl1){target=_blank}
    * two circuits with energy monitoring
    * [Esphome](https://devices.esphome.io/devices/Shelly-Plus-2PM){target=_blank}
* [Shelly 1 Plus](https://amzn.to/3XKu6tQ){target=_blank}
    * DRY CONTACT switch. (Can be used to switch low voltage DC loads, such as your garage door.)
    * [Esphome](https://devices.esphome.io/devices/Shelly-Plus-1){target=_blank}
* [Shelly EM](https://amzn.to/44ndkDC){target=_blank}
    * Supports monitoring up to two channels, 120 amps each. This is used for energy monitoring only.
    * [Esphome](https://devices.esphome.io/devices/Shelly-EM){target=_blank}
* [Shelly RGBW2](https://amzn.to/3XNr3kH){target=_blank}
    * Used to control RGB / RGBW LEDs. Does NOT control individually addressable LEDs (ie. WS2812b)
    * [Esphome](https://devices.esphome.io/devices/Shelly-RGBW2){target=_blank}
* [Shelly Dimmer 2](https://amzn.to/3O4JdLr){target=_blank}
    * Used to control up to two lighting circuits. Supports dimming.
    * [Esphome](https://esphome.io/components/light/shelly_dimmer.html){target=_blank}
* [Shelly i4](https://amzn.to/3roEs6E){target=_blank}
    * This is a pretty niche device. It has 4 inputs, and is intended to be used to trigger other actions externally.
    * [Esphome](https://devices.esphome.io/devices/Shelly-Plus-i4){target=_blank}
* [Shelly Plus Addon](https://amzn.to/46K2BVf){target=_blank}
    * You can connect sensors up to this. It doesn't control or switch loads. But- you can connect temp sensors to it.


### Light Switches

#### Kasa HS200 - Light Switch

While, all new switches I replace are generally z-wave based, or something running esphome- I do have one of these in my hallway, and it has been in place since 2020.

And- it still works exactly as well as it did three years ago. That being said, there aren't many fancy features, but, it does work.

These do work 100% locally, but, requires a phone app for initial setup. Does require neutral wire.

Native home assistant integration.

* [Amazon](https://amzn.to/3PRAk9j){target=_blank}

### Alarm Components

Do note, I am ONLY going to recommend things that will work 100% locally, with home-assistant, without a required subscription / application / etc....

So, no ring doorbells.

#### Ring Alarm - 14 piece kit

All of these components will work with a proper z-wave setup, WITHOUT having a ring/amazon account. 

These keypads, work really nicely. Please see my [write-up](./../2022/home-assistant-alarm.md){target=_blank} for details on how to make them work with home assistant very easily. 

* [Amazon](https://amzn.to/3NOcuIR){target=_blank}
* [My Post - Home Assistant Alarm](./../2022/home-assistant-alarm.md)
* [My Post - Embedded Door Sensors](./../2022/embedded-door-sensors.md)

### Kiosks

The 50$ I spent on my refurbished Fire HD10 tablet, has been well worth it. It functions as a kiosk sitting beside my desk, showing me vitals for my home, solar production, and giving quick access to common things.

Do note- if you isolate these devices from the internet (HIGHLY recommended), there are no lock screen ads.

[Xtremeownage.com - Fire Tablet as Home Assistant Kiosk](https://xtremeownage.com/2022/07/08/fire-tablet-as-home-assistant-kiosk/){target=_blank}

Having ran my fire tablet as a kiosk for over a year, I would highly recommend one. Just- make sure to keep it 100% isolated from the internet!!!!

#### Fire Tablet

* [Amazon - HD 10](https://amzn.to/3XOnVos)
* [Amazon - HD 8](https://amzn.to/44lt5en)



### Weather / Temp / Environment Monitoring

#### Acurite

Most of the acurite hardware works over 433mhz.

You WILL need a working 433mhz setup to properly integrate into home assistant.

[RTL-433 Getting Started](./../2021/2021-01-RTL_433.md){target=_blank}

* [Acurite Iris 5-in-1](https://amzn.to/43r0h2x){target=_blank}

(Sadly, I didn't find any of the other acurite hardware on sale)