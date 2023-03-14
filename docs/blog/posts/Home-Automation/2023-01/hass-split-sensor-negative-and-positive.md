---
title: "Home Assistant - Split Sensor"
date: 2023-03-14
categories:
    - Home-Automation
    - Technology
tags:
    - Home Assistant
---

# Home Assistant - Split Sensor into Negative and Positive

This is a very quick post on how to take a sensor- such as `sensor.grid_power` and split it into `sensor.grid_power_in` and `sensor.grid_power_out`.

This can be handy if you need a separate sensor for energy/power in, and energy/power out.

For this short post, I will be splitting `sensor.battery_power` into `sensor.battery_power_in` and `sensor.battery_power_out`

<!-- more -->

## How to do it?

First- you need to update your `configuration.yaml`/`templates`

I personally keep my templates in a dedicated file named `template.yaml`. This helps me keep everything organized.

### How to store templates in a dedicated file

Simple, in your `configuration.yaml`, we will tell it to include sensors.yaml.

``` yaml title="configuration.yaml"
template: !include template.yaml
```

You can do this with sensors, binary_sensors, or any other section. 

### How to split sensor into negative/positive sensors

To do this, we will leverage home-assistant's [template sensor](https://www.home-assistant.io/integrations/template/){target=_blank}.

``` yaml title="template.yaml"
- sensor:
  - name: battery_power_in
    unit_of_measurement: "W"
    state_class: measurement
    device_class: energy
    state: >
        {% if states('sensor.battery_power')|float >= 0 %}
          {{ states('sensor.battery_power') }}
        {% else %}
          0
        {% endif %}
  - name: battery_power_out
    unit_of_measurement: "W"
    state_class: measurement
    device_class: energy
    state: >
        {% if states('sensor.battery_power')|float < 0 %}
          {{ states('sensor.battery_power') | float  * -1  }}
        {% else %}
          0
        {% endif %}
```

`state_class`, and `device_class` are not required fields. However, if you wish to specify them, here is the documentation for acceptable values:

* [State Class](https://developers.home-assistant.io/docs/core/entity/sensor/#available-state-classes){target=_blank}
* [Device Class - Sensor](https://www.home-assistant.io/integrations/sensor/){target=_blank}

After making your changes, in home assistant, press `C`, and `Reload Template Entities`

If your new sensors do not show up, check your logs for errors.

## Summary

This was intended to be a very simple guide on how to split a number into multiple sensors.