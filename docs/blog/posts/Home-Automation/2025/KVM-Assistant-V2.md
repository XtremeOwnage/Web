---
title: "KVM Assistant"
date: 2025-05-08
tags:
  - Homelab
  - Home Assistant
  - ESPHome
---

# Introducing KVM Assistant

This year, [I automated a cheap KVM switch](2025-02-24-KVM-Esphome.md){target=_blank} by disassembling it, and installing a micro controller inside of it running ESPHome. 

That was intended to be a preface to my next project. Fully automating my office / desk.

Well, the time has come to share the end result.

Introducing... KVM Assistant.

<!-- more -->

But first, lets talk about the challenge, and then I will discuss my solution.

## The Problem

My home office is multi-purpose. It is used for both work, and play. Also, since I happen to have a smaller house, my office is also my bedroom where I sleep.

This, introduces a few unique challenges. For example, when I am sleeping, I really don't want a bunch of LEDs flashing. 

My setup is pretty simple. I have three monitors.

1. 32" 1440p/144hz, LEFT
2. 32" 4k/60hz, RIGHT
3. 24" 1080p/60hz, TOP.

I have multiple configurations, depending on the activity being performed.

1. When working.....
    - All three monitors connected to work PC.
    - Both 32" screens connected to work PC, but, top 24" screen connected to personal PC, for watching movie, camera feeds, alerts, home assistant, etc...

``` mermaid
    graph TB
    subgraph "Monitors"
        A1["32in 1440p@144hz LG"]
        A2["32in 4k@60hz Philips"]
        A3["24in 1080p@60hz Dell"]
    end

    subgraph "Computers"
        B1["Gaming/Personal PC"]
        B2["Work PC"]
        B3["Wife's Gaming PC"]
    end

A1 & A2 & A3 --> B2
```

2. When gaming alone....
    - Both 32" screens connected to the gaming PC.
    - 24" may, or may not be connected to gaming PC, depending on the task being performed.

``` mermaid
    graph TB
    subgraph "Monitors"
        A1["32in 1440p@144hz LG"]
        A2["32in 4k@60hz Philips"]
        A3["24in 1080p@60hz Dell"]
    end

    subgraph "Computers"
        B1["Gaming/Personal PC"]
        B2["Work PC"]
        B3["Wife's Gaming PC"]
    end

A1 & A2 --> B1
A3 -.-> B1
```

3. When gaming together (with wife)....
    - Left 32" screen connected to her PC.
    - Right 32" screen, and Top 24" screen connected to my PC.

``` mermaid
    graph TB
    subgraph "Monitors"
        A1["32in 1440p@144hz LG"]
        A2["32in 4k@60hz Philips"]
        A3["24in 1080p@60hz Dell"]
    end

    subgraph "Computers"
        B1["Gaming/Personal PC"]
        B2["Work PC"]
        B3["Wife's Gaming PC"]
    end

A1 --> B3
A2 --> B1
A3 -.-> B1
```

4. When.... working on the homelab, or working on another PC.
    - Both 32" screens connected to my personal PC.
    - Top 24" screen connected to the device or PC I am working on.
        - Note- This is not commonly needed as everything in my rack can be fully controlled, and imaged remotely.
        - Imagine.... say, I am building my kid's a new gaming PC. That is the use-case here.

``` mermaid
    graph TB
    subgraph "Monitors"
        A1["32in 1440p@144hz LG"]
        A2["32in 4k@60hz Philips"]
        A3["24in 1080p@60hz Dell"]
    end

    subgraph "Computers"
        B1["Gaming/Personal PC"]
        B2["Work PC"]
        B3["Wife's Gaming PC"]
    end

    B4["Random PC on a desk"]

A1 & A2 --> B1
A3 --> B4
```

### Requirements

For a list of my requirements, I would like to....

1. Be able to mix-and-match displays, between connected PCs.
2. Use DisplayPort. Ideally, Leverage DisplayPort MST. (Multiple Streams. Aka, multiple monitors, one cable)
3. Handle everything semi-automatically.
4. Not spend over 300$ on a solution.

## Solution #1. KVM Switches

To solve this problem, KVM switches can be leveraged.

KVMs, allow multiple monitors, to connect to multiple PCs.

Since, I am sure many of you have been silently screaming JUST USE A 3x3 KVM... 

Lets demonstrate the problem.

### The problem with a single KVM switch

First, lets assume we just throw a KVM switch into the middle.

``` mermaid
    graph TB
    subgraph "Monitors"
        A1["32in 1440p@144hz LG"]
        A2["32in 4k@60hz Philips"]
        A3["24in 1080p@60hz Dell"]
    end

    K1["KVM Switch"]

    subgraph "Computers"
        B1["Gaming/Personal PC"]
        B2["Work PC"]
        B3["Wife's Gaming PC"]
    end

    B4["Random PC on a desk"]

A1 & A2 & A3 --> K1 --> B1 & B2 & B3 & B4
```

Instantly- you have a big problem.

Most KVM switches are not "matrix"/"multiview" capable.

Multiview- is a short way of saying, you can have multiple monitors connected to different PCs at the same time. 

In short- this means, all of the screens will be connected to one PC.

To further aggregate this issue, you will typically only find multi-view capabilities, in HDMI KVMs. Not DisplayPort KVMs.

And, for my purposes, I would like to leverage a minimum of Displayport 1.4

A short TLDR; after going down a long rabbithole of just building my own KVM from scratch- Display port is quite a bit more complex to pass through. 

### Use a matrix/multiview KVM switch?

There is a very easy explanation as to why I did not do this.

1. [Exhibit 1. KVMSwitchesOnline - KVMs priced in the thousands](https://www.kvm-switches-online.com/multiviewer-kvm-switch.html){target=_blank}
2. [Exhibit 2. CKL-KVM. Cheapest multi-view priced at 299$. But, HDMI](https://cklkvm.com/collections/multi-view-kvm-switches){target=_blank}
3. [Exhibit 3. TESSmart 4 PC, 3 Monitor. Cheapest: 585$](https://www.tesmart.com/collections/for-4-pcs-3-monitors){target=_blank}

Remember the list of requirements? Not a single one of the units above can meet more then a single requirements.

The CKL, can meet the price of <= 300$, however, does not support Display Port.

The other units, are far in excess of what I would be willing to pay.

CKL, does have (currently) [2x2 Matrix KVMs](https://cklkvm.com/collections/matrix-kvm-switches){target=_blank} for under 200$. However I need... more ports!

### Using multiple KVM switches

While, KVMs supporting 3/4+ monitors/PCs are expensive- there is.... another option.

Just- use multiple KVMs.

Lets, create a list, of which screens may need to connect to which PCs.

1. Left 32". Can connect to Work, Game, Wife.
2. Right 32" Can connect to Work, Game.
3. Top 24". Can connect to Work, Game, Aux.

Then, lets create a matrix for this.

1. D1: Left 32"
2. D2: Right 32"
3. D3: Top 24"
4. C1: Work PC
5. C2: Gaming/Personal PC
6. C3: Wife's PC
7. C4: Auxiliary PC

And..... then create a table.

| Display        | Work PC (C1) | Gaming/Personal PC (C2) | Wife's PC (C3) | Auxiliary PC (C4) |   |
| -------------- | ------------ | ----------------------- | -------------- | ----------------- | - |
| Left 32" (D1)  | X            | X                       | X              |                   |   |
| Right 32" (D2) | X            | X                       |                |                   |   |
| Top 24" (D3)   | X            | X                       |                | X                 |   |

INITIALLY, I considered chaining KVMs together, like this:

``` mermaid
graph TB
subgraph "Monitors"
    1["32in 1440p@144hz LG"]
    2["32in 4k@60hz Philips"]
    3["24in 1080p@60hz Dell"]
end

subgraph "KVMs"
    K1["2x2 DP KVM-1"]
    K2["2x2 DP KVM-2"]
    K3["2x2 HDMI KVM-3"]
end

subgraph "Computers"
    C["Wife's Gaming PC"]
    A["Gaming/Personal PC"]
    B["Work PC"]

end

A & B ==> |2x DP| K1
A & B --> |1x HDMI| K3
K1 --> |1x DP| 2 & K2
C --> | 1x DP| K2
K2 --> | 1x DP| 1
K3 --> | 1x HDMI| 3
```

However, I will tell you- chaining multiple KVMs together, does not work very well, at all.

(I tried it. Bad things happened. Don't do it.)

Lets go back to the table-

| Display        | Work PC (C1) | Gaming/Personal PC (C2) | Wife's PC (C3) | Auxiliary PC (C4) |   |
| -------------- | ------------ | ----------------------- | -------------- | ----------------- | - |
| Left 32" (D1)  | X            | X                       | X              |                   |   |
| Right 32" (D2) | X            | X                       |                |                   |   |
| Top 24" (D3)   | X            | X                       |                | X                 |   |

Going with the experience of chaining KVM is bad- we would need...

1. 2x Single Monitor, 3 Computer KVMs OR 1x Dual Monitor, 3 Computer Matrix KVM.
2. 1x Single Monitor, Single PC KVM.

The single monitor, single PC- Piece of cake. I have 4 dual-port KVMs laying around which can meet this need. (Just- don't use the other ports)

I can also simplify my requirements, by removing the requirement to connect an auxiliary PC DIRECTLY to the KVM. Instead, I can switch the 24" monitor's input.

And, to further simplify just to get SOMETHING automated, lets also just manually switch the input on the left monitor when the wife wants to shoot zombies.

That yields these results:

| Display        | Work PC (C1) | Gaming/Personal PC (C2) | 
| -------------- | ------------ | ----------------------- | 
| Left 32" (D1)  | X            | X                       | 
| Right 32" (D2) | X            | X                       | 
| Top 24" (D3)   | X            | X                       | 


And, yields this simplified solution:

``` mermaid
    graph TB
    subgraph "Monitors"
        1["32in 1440p@144hz LG"]
        2["32in 4k@60hz Philips"]
        3["24in 1080p@60hz Dell"]
    end

    subgraph "KVMs"
        K1["1x2 MST DP KVM"]
        K2["1x2 DP KVM"]
    end

    subgraph "Computers"
        A["Gaming/Personal PC"]
        B["Work PC"]

    end

    A & B ==> |2x MST DP| K1 --> 1 & 2
    A & B --> |1x DP| K2 --> 3
```

This uses existing hardware I already have laying around. 