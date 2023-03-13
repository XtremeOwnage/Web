---
title: "Fireplace Automation - Part 3"
date: 2021-10-30
categories:
    - Home-Automation
    - Technology
tags:
    - HVAC
    - Z-Wave
    - Home Assistant
---

# Fireplace Automation - Part 3

The goal of this article, is to simplify everything as much as possible. Simpler automation, is more reliable automation generally.

<!-- more -->

A few years ago, I automated my natural gas fireplace to automatically turn on and turn off to keep my house at a consistent temperature. This allows me to save a lot of energy by not heating the entire house during the day, and only heating the main living areas. As well, it also saves the electricity from running the blower fan.

Well, Today, I also updated my HVAC systems to Z-Wave.

If you have not seen the articles, here are links:

[Fireplace Automation – Part 1](https://xtremeownage.com/2020/10/16/fireplace-automation/){target=_blank} – Building a esphome device, and using naive node-red automation to control it.

[Fireplace Automation – Part 2](https://xtremeownage.com/2020/10/20/fireplace-automation-part-2/){target=_blank} – Updating the automation for better “presence” detection, and using a template thermostat.

[Updating my HVAC to Z-Wave](./full-local-hvac-control.md) – Replacing my Cloud/Wifi thermostat with z-wave, and replacing my fireplace’s electronics with a z-wave relay.

## Updating the “Presence Detection”

In Part 2 of the fireplace automation, I used individual automations to both turn on, and turn off the fireplace automation. I am going to consolidate all of the logic into a single template binary_sensor. This will replace multiple automations.

``` yaml title="configuration.yaml"
template:
- binary_sensor:
    - name: hvac_presence_detection
    state: >
        {{
        (
            is_state('light.livingroom_ceiling_light', 'on')
            or is_state('fan.ceiling', 'on')
        )
        and is_state('group.all_people', 'home')
        and is_state('input_boolean.mode_vacation', 'off')
        and
        (
            is_state('climate.thermostat', 'heat')
            or is_state('climate.thermostat', 'heat_cool')
        )
        }}
```

The above template sensor, looks for a few conditions.

1. One of the devices in the living room must be on. At the time of writing this, my TV relies on the smartthings integration which I have recently removed due to numerous issues. So, for now, you must have a light turned on to have heat.
2. Next- SOMEBODY has to be at home, using the home assistant presence detection. group.all_people consists of me & my wife’s android phones with the home assistant app.
3. Next- vacation mode must be off. This is a helper which I can toggle on, when we are away for extended periods of time.
4. Lastly, the thermostat must be in either “heat” or “heat_cool” mode.

By creating this template sensor, it allows me to trigger on its state to clean up the other automations.

Next, I built a single automation to replace the “Enable / Disable” fireplace automations used previously.

All it does, is either turn the climate entry for the fireplace on or off, based on the template sensor. Thats it.

Since the template sensor has conditions built in for vacation, presence detect, and HVAC mode, there is no reason to repeat the logic here.

``` yaml
alias: 'HVAC: Fireplace Enable/Disable'
description: Toggles the fireplace on and off based on presence detection
trigger:
  - platform: state
    entity_id: binary_sensor.hvac_presence_detection
condition: []
action:
  - choose:
      - conditions:
          - condition: state
            entity_id: binary_sensor.hvac_presence_detection
            state: 'on'
        sequence:
          - service: climate.turn_on
            target:
              entity_id: climate.fireplace
    default:
      - service: climate.turn_off
        target:
          entity_id: climate.fireplace
mode: single
```

Next up, the climate.fireplace entity has not been changed since part 2, other then updating the entity IDs to match the new z-wave ids.

``` yaml
climate:
  - platform: generic_thermostat
    name: Fireplace
    heater: switch.fireplace_gas
    target_sensor: sensor.thermostat_air_temperature
    min_temp: 60
    max_temp: 90
    ac_mode: false
    target_temp: 0
    cold_tolerance: 0.3
    hot_tolerance: 0.5
    min_cycle_duration:
      minutes: 2
    keep_alive:
      minutes: 3
    initial_hvac_mode: "off"
    away_temp: 16
    precision: 1.0
```

At this point, we have all of the automations needed to turn the fireplace on and off, when somebody is home, and likely in the living areas. The only remaining piece to do now, is to sync the temperature.

## Syncing Temperature 

To handle this, I have a simple automation based on the thermostat’s setpoint. When the setpoint changes, this automation kicks off. These automations utilize the number helper created previously, to tell the fireplace how many degrees above the thermostat setpoint to use. The way this works- I typically set the main thermostat two degrees under the value I actually want it to use, and I keep the fireplace setpoint helper set to “2”.

``` yaml
-- When the thermostat is in "HEAT" mode:
service: climate.set_temperature
data_template:
  entity_id: climate.fireplace
  temperature: |
    {{  float(
      state_attr('climate.thermostat','temperature') | float +
      states("input_number.fireplace_setpoint_increase")  | float 
      ) 
    }}
  hvac_mode: heat
-- When the thermostat is in "HEAT_COOL" mode (Includes a tiny amount of additional logic to ensure we don't kick the A/C on.)
service: climate.set_temperature
data_template:
  entity_id: climate.fireplace
  temperature: >
    {% if (float(state_attr('climate.thermostat', 'target_temp_low')) +
    float(states("input_number.fireplace_setpoint_increase"))) <
    float(state_attr("climate.thermostat", 'target_temp_high')) %}
      {{ float(state_attr('climate.thermostat','target_temp_low') + float(states("input_number.fireplace_setpoint_increase"))  ) }}
    {% else %}
      {{ float(state_attr('climate.thermostat','target_temp_high') - 2) }}
    {% endif %}
  hvac_mode: heat
```

The only other piece to this, besides my dashboards, is an automation for cycling the central heat.

Last year, while working from home during some of the colder weather, I noticed, it can get pretty chilly back here in my office.

So, I built a simple script, which turns the fireplace off for a couple of hours, and turns the main thermostat up a few degrees to heat up the office. After the office gets up to the desired temperature, it kicks off. I can also rely on the central HVAC’s fan to circulate a bit of heat back here as well.

## Summary

That was it- This was just intended to be a simple explanation regarding how the automation for my fireplace is configured. 

As of me migrating this post from wordpress to this static site in 2023, this automation has been running more or less untouched. The only real difference- I no longer have any dependency on cloud-based tools or services now. So, no more smart things. 

And- I disabled the automation to sync the temp. The fireplace is now just statically configured between 70 and 72 degrees, and the main thermostat STAYS set around 64 during the day, and 58 at night.

If we feel cold, we just turn it up a degree or two using the home-assistant app.