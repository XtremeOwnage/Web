---
title: "Home Assistant - Work Days / Work Hours sensor"
date: 2022-12-15
categories:
    - Home-Automation
---

# Home Assistant - Is Working Sensor

Creating simple sensors to determine if we are "at work". Includes setting up a work_days sensor, time of day sensor, and a template sensor to tie everything togather. 

As well, includes steps for handling vacation / OoO days, and holidays.

<!-- more -->

### Seperating configuration files.

This step is optional, however, to keep my configuration.yaml nice and simple, I split individual sections into dedicated files.

``` yaml title="configuration.yaml"
binary_sensor: !include binary_sensor.yaml
sensor: !include sensors.yaml
template: !include template.yaml
```
### Setup 'work_days' integration

We will need to setup the [work_days](https://www.home-assistant.io/integrations/workday/){target=_blank} integration. This is a built-in integration provided with home assistant, which will allow us to easily determine if a specific day, is a "work day". Please check out its [Documentation](https://www.home-assistant.io/integrations/workday/){target=_blank} for options which can be configured.

As well, We will use the [Time of Day](https://www.home-assistant.io/integrations/tod/){target=_blank} integration, to determine if it is between the hours of 7:30am, and 5pm. This sensor is also built-in.

``` yaml title="binary_sensor.yaml"
- platform: workday
  name: work_days
  country: US
  province: OK
  workdays: [mon, tue, wed, thu, fri]
  excludes: [sat, sun, holiday]

- platform: tod
  name: work_hours
  unique_id: work_hours
  after: "07:30"
  before: "17:00"
```

### Create template binary sensor to tie previous sensors togather. 

To combine the previous two sensors (and a few others) into a single sensor, I will be leverage a [template binary_sensor](https://www.home-assistant.io/integrations/template/){target=_blank}. Like the previous integrations, this is also a built-in out of the box integration.

You will also note, I reference a helper boolean previously configured, for `input_boolean.mode_vacation`. When I am away from my house for an extended peroid of time, I use this helper to disable many of the automations I don't want running when I am away from home.

``` yaml title="template.yaml"
- binary_sensor:
  - name: is_working
    state: >
      {{
         is_state('binary_sensor.work_days', 'on')
         and is_state('binary_sensor.work_hours', 'on')
         and is_state('input_boolean.mode_vacation', 'off')
      }}
```

As a disclaimer, you could also skip creating the above tod sensor, and wrap everything into a single template sensor if desired. However, I have special use-cases where having the above sensors broke-out into seperate sensors will come in handy.

### Handling Days Off

For handling taking a day off, I use the built-in [Calendar Integration](https://www.home-assistant.io/integrations/calendar/){target=_blank}. I use this, rather then integrate with my work-calendar, due to company/security policies. 

The process is quite simple. 

Step 1. Goto Integrations

[![Open your Home Assistant instance and show your integrations.](https://my.home-assistant.io/badges/integrations.svg)](https://my.home-assistant.io/redirect/integrations/){target=_blank}

Step 2. Click Add Integration (Bottom-Right)

Type in "Calendar"

Step 3. Add the "Local Calendar" integration. For this example, I will use "Vacation" as the calendar name.

Step 4. On the left bar, you should see "Calendar" At this point, you can select the calendar we just created, to add events.

To tie this into the previous example, we can update the template sensor, like so:

``` yaml title="template.yaml"
- binary_sensor:
  - name: is_working
    state: >
      {{
         is_state('binary_sensor.work_days', 'on')
         and is_state('binary_sensor.work_hours', 'on')
         and is_state('input_boolean.mode_vacation', 'off')
         and is_state('calendar.vacation', 'off')
      }}
```

Do note, the state will be `off` when there are no events. However, when an event is added to the "vacation" calendar, its state will change to `on`.


## Conclusion

This was just a simple guide on how to setup some basic sensors to determine if it is during work hours, on a day you should be working.

A few steps were added to also include an easy way to determine if its a vacation day. The built-in [work_days](https://www.home-assistant.io/integrations/workday/){target=_blank} already has support for handling holidays.

Hope this is helpful, Cheers!