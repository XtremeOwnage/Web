# ESPhome Common

This is a quick page detailing a few of my "Common" components I leverage for ESPhome.

Since, I am running over 30 ESPhome devices, I component-ize my configurations as much as possible to improve maintainability. 

## Directory Structure

For my esphome, to attempt to keep everything somewhat organized- I use a unique layout.

I keep configurations for commonly used sections, under a `common` folder. I also have a `devices` folder, which containers commonly reused device-specific configurations. Ie- for the 12 or so sonoff S13s I have with mostly identical configurations. 

``` bash
├── Projects Go Here!
├── common
│   ├── button-restart.yaml
│   ├── button-safemode.yaml
│   ├── common.yaml
│   ├── config-api.yaml
│   ├── config-mqtt.yaml
│   ├── config-ota.yaml
│   ├── config-time.yaml
│   ├── config-wifi.yaml
│   ├── config-wifi_no_powersave.yaml
│   ├── sensor-uptime.yaml
│   └── sensor-wifi-signal.yaml
├── devices
│   ├── sonoff-s13-reset-only.yaml
│   └── sonoff-s13.yaml
├── secrets.yaml
├── my-device.yaml

```
## Common

### common.yaml

This just references my other common configuration files. 

I do it this way, to keep everything in my device-specific configuration files very simple.

``` yaml title="common.yaml"

<<: !include config-wifi.yaml
<<: !include config-time.yaml
<<: !include config-api.yaml
<<: !include config-ota.yaml
<<: !include config-mqtt.yaml

logger:
```

## Secrets

### secrets.yaml

This is the standard Esphome Secrets file.

``` yaml title="secrets.yaml"
ota_pass: "Password for OTA updates"
fallback_pass: "Password for Fallback AP"
encryption_key: "Your ESPHome Encryption key."

wifi_ssid: "Your Wifi SSID"
wifi_pass: "Your Wifi Password"
domain: ".iot.yourdomain.com"

# NTP Server IP
## See the config-time section on this post. This is not required.
ntp_server_ip: 192.168.1.1
timezone: America/Chicago

# MQTT Server IP
# Put YOUR Mqtt information here, IF, you want to use MQTT with your esphome devices. This is not required, and only comes in handy if you want to tie in external automation using MQTT.
mqtt_ip: 192.168.1.1 
mqtt_user: ""
mqtt_pass: ""
```

## Config

### config-api

This configures the [Esphome API Component](https://esphome.io/components/api){target=_blank}. This is how esphome talks to home-assistant.

``` yaml title="config-api.yaml"
api:
  encryption:
    key: ${encryption_key}
  # password: ${api_pass}
```

### config-mqtt

This configures the [Esphome MQTT Component](https://esphome.io/components/mqtt){target=_blank}. Note- this component is NOT required.

I do this, to allow external automation tools (NOT home-assistant) to interact with my esphome devices and/or to gather data.

The MQTT credentials are stored in `secrets.yaml`

Do note, I disable discovery, as I add these devices directly to home-assistant. If, you wish to use discovery instead, you could enable it here.

``` yaml title="config-mqtt.yaml"

mqtt:
  broker: ${mqtt_ip}
  username: ${mqtt_user}
  password: ${mqtt_pass}
  discovery: false
  discovery_retain: true
  topic_prefix: esphome/devices/${devicename}
  log_topic:
    topic: esphome/logs/${devicename}
    level: WARN
  birth_message:
    topic: esphome/state/${devicename}
    payload: online
  will_message:
    topic: esphome/state/${devicename}
    payload: offline
```

### config-ota

This section configures [OTA (over the air) update component](https://esphome.io/components/ota.html){target=_blank}.

``` yaml title="config-ota.yaml"
ota:
  password: ${ota_pass}
```

### config-time

[Esphome Time Component](https://esphome.io/components/time/){target=_blank}. Note- this is not required by default. By default, it will query home assistant for the time. 

Configures my devices to use NTP. By default, devices will gather the time from home-assistant. However, since I have a perfectly functional NTP server hosted on my core switch- I leverage it instead.

``` yaml title="config-time.yaml"
# Enable Time Component
time:
#  - platform: homeassistant
#    id: homeassistant_time
#    timezone: America/Chicago
  - platform: sntp
    servers: ${ntp_server_ip}
    timezone: ${timezone}
```

### config-wifi

Configures the [Wifi Component](https://esphome.io/components/wifi.html){target=_blank}

The ip_address variable is set in the configuration of each device. 

ssid/pass/etc are configured in secrets.yaml.

``` yaml title="config-wifi.yaml"

wifi:
  ssid: ${wifi_ssid}
  password: ${wifi_pass}
  domain: ${domain}
  fast_connect: True                    # My IOT SSID is hidden. This is required to connect to it. Also- speeds up connection time.
  power_save_mode: none                 # Don't enable power-savings mode.
  reboot_timeout: 15min                 # Reboot after 15 minutes, if we are unable to connect to wifi
  manual_ip:
    static_ip: ${ip_address}            # I define each device with its own static IP.
    gateway: ${gateway}
    subnet: 255.255.255.0               
    # Note- NO DNS is configured. These devices don't need DNS. I don't allow DNS on my IOT subnet.
    # Reason being- DNS queries can be used to send data back to the internet.

  ap:                                   # Fallback AP is enabled, because some of my ESP devices are inside of my wall. IF- something happened, This helps a lot to fix the issue.
    ssid: "${devicename} Fallback"
    password: ${fallback_pass}

```
## Buttons

### button-restart

This, just adds a "restart" button which will restart my device via home-assistant.

``` yaml title="button-restart.yaml"

  - platform: restart
    name: Restart
    icon: "mdi:restart"
    entity_category: diagnostic
```

### button-safemode

This adds a [Safe Mode Button](https://esphome.io/components/button/safe_mode.html){target=_blank}, which will reboot the esphome device into [Safe Mode](https://esphome.io/components/ota.html#config-ota){target=_blank}

``` yaml title="button-safemode.yaml"
  - platform: safe_mode
    name: Safe Mode Boot
    icon: "mdi:restart"
    entity_category: diagnostic
```

I don't think I have never had a reason to click or use this button, however, it does exist.

## Sensors

### sensor-uptime

This adds the [ESPHome Uptime Sensor](https://esphome.io/components/sensor/uptime.html){target=_blank}.

Quite simply, it adds the current uptime of each device into home-assistant. 

``` yaml title="sensor-uptime.yaml"

  - platform: uptime
    name: Uptime
    state_class: measurement
    device_class: duration
```

### sensor-wifi-signal

This adds the [ESPHome Wifi Signal Sensor](https://esphome.io/components/sensor/wifi_signal.html){target=_blank}.

This allows me to see the devices's current wifi signal strength in home-assistant.

``` yaml title="sensor-wifi-signal.yaml"

  - platform: wifi_signal
    name: "WiFi Signal"
    update_interval: 60s
    state_class: measurement
    device_class: SIGNAL_STRENGTH
```