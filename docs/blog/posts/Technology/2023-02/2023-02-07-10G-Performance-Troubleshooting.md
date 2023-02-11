---
title: "Network Performance Troubleshooting"
date: 2023-01-23
categories:
  - Technology
tags:
  - Homelab
  - Networking
---

# How to identify and resolve network performance problems

Last week, I added a [10G Unifi aggregation switch](https://amzn.to/3YnHkvM){target=_blank} to my network.

I noticed a few potential performance issues, and decided to track them down.

This is a simple guide, with a few methods you can leverage to troubleshoot network performance issues. 

<!-- more -->

## My Topology

For this experiment, I have 4 servers which will be used for testing.

1. Opnsense - HP Z240 [Dual port 10G Intel X540-T2](https://ebay.us/UmvExa){target=_blank}
2. TrueNAS - Dell R730 [Dual port 10G Dell X540 / 099GTM Daughterboard](https://ebay.us/q0d1te){target=_blank}
3. Kube01 - Optiplex 7060 i7-8700 [10G ConnectX-3 MCX311A-XCAT](https://ebay.us/PhtRHc){target=_blank}
4. Kube05 - HP Z240 i5-6500 [10G ConnectX-3 MCX311A-XCAT](https://ebay.us/PhtRHc){target=_blank}

All nodes are connected to a [10G Unifi Aggregation Switch](https://amzn.to/3YnHkvM){target=_blank}

Kube01 and Kube02, are leveraging [Really Cheap DACs](https://ebay.us/1NtLuC){target=_blank}

TrueNAS / Opnsense both leverage off-brand, cheapest of the cheap 10GBase-T modules to connect Cat6 into the switch.

## Troubleshooting

### Step 1. Do iperf tests between nodes.

To run iperf3 server: `iperf3 -s`

To run test from a client: `iperf3 -c ip.of.your.server`

To run bidirectional test, use `--bidir` flag.

For this post, I will be using `iperf3 -s target.ip --bidir` to do a bidirectial test from each combination of nodes. You will need to run `iperf3 -s` on the receiving server.

| Sender   | Receiver | Bandwidth | Retries |
| -------- | -------- | --------- | ------- |
| Kube01   | Kube05   | 9.27      | 0       |
| Kube01   | Opnsense | 4         | 150     |
| Kube01   | TrueNAS  | 5.81      | 3826    |
| Kube05   | Kube01   | 9.24      | 1028    |
| Kube05   | TrueNAS  | 6.79      | 4168    |
| Opnsense | Kube01   | 5         | 0       |
| Opnsense | Kube05   | 5         | 0       |
| Opnsense | TrueNAS  | 5.48      | 842     |
| TrueNAS  | Kube01   | 9.16      | 0       |
| TrueNAS  | Kube05   | 9.11      | 1637    |
| TrueNAS  | Opnsense | 5.09      | 0       |

### Step 2. Interpret the results

After looking at the data-

There are generally no retransmits / issues when sending data to kube01, and kube05. Both are able to receive 10Gbit/s no problem.

ANY test going to or from Opnsense, encounters the single-core iperf limitations, and generally is limited to 5-6Gbit/s of traffic.

TrueNAS is unable to receive data without encountering retransmits, as well, it never receives more then 5-6Gbit/s.

TrueNAS appears to be able to send data, without issue, and is able to achieve expected speeds.

To help normalize the results, I decided to switch all of these nodes over to 9k MTU jumbo frames. To note, **This is NOT required** for 10GBe.


##### iperf / cpu limitation

I noticed while running iperf on opnsense, its thread was at 100% usage.

iperf3 is single-threaded, which can make it more challenging to test 10/25/40/100GBe networks. This is especially a problem, when the single-threaded performance of a CPU is lower.

From Opnsense while running tests
``` bash
PID USERNAME    THR PRI NICE   SIZE    RES STATE    C   TIME    WCPU COMMAND
29147 root          1  85    0    17M  6296K CPU0     0   0:06  98.54% iperf3
```
Despite having additional cores on the system for use, iperf will only use a single thread.

Using `-P 4` will generate 4 parallel streams, however, is still limited to a single thread.

``` bash
firewall:~ # iperf3 -c 10.100.5.2 -P 4
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[SUM]   0.00-10.00  sec  9.02 GBytes  7.75 Gbits/sec  8630
```

## Switching to Jumbo Frames

After taking a bit to switch all of the interfaces over to leverage a 9,000 mtu, I saw dramatically increased performance across the board, with far fewer retransmits.

| Sender   | Receiver | Bandwidth | Retries |
| -------- | -------- | --------- | ------- |
| Kube01   | Kube05   | 9.7       | 0       |
| Kube01   | TrueNAS  | 9.6       | 26      |
| Kube05   | Kube01   | 9.7       | 0       |
| Kube05   | TrueNAS  | 9.6       | 21      |
| TrueNAS  | Kube01   | 9.8       | 1       |
| TrueNAS  | Kube05   | 9.8       | 85      |
| Kube01   | Opnsense | 9.7       | 0       |
| Opnsense | Kube01   | 9.4       | 0       |
| TrueNAS  | Opnsense | 9.8       | 0       |
| Opnsense | TrueNAS  | 8.2       | 436     |
| Kube05   | Opnsense | 700Mbit   | 0       |
| Opnsense | Kube05   | 46Mbit    | 853     |

Now- nearly everything is working perfectly, EXCEPT, traffic going from kube05, to Opnsense.

I suspect, this is an issue with the adapter.

### Troubleshooting Kube05 -> Opnsense

Since, kube05 works just fine testing to any of the other servers, this wouldn't be an issue relating to the physical network or cables. As well, this is likely not a switch issue.

I suspect, this is an issue with interfaces on the machine itself.

``` bash
kube05:~# ifconfig
(extra junk cleared out)
eno1      Link encap:Ethernet  HWaddr A0:8C:FD:C0:46:6D
          inet addr:10.100.5.103  Bcast:10.100.5.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3145017 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3955835 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:462587507 (441.1 MiB)  TX bytes:5595142800 (5.2 GiB)
          Interrupt:16 Memory:d1a00000-d1a20000

enp1s0    Link encap:Ethernet  HWaddr E4:1D:2D:DD:88:A0
          inet addr:10.100.5.105  Bcast:10.100.5.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:117799483 errors:0 dropped:0 overruns:0 frame:0
          TX packets:84629781 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:147325596294 (137.2 GiB)  TX bytes:103176751032 (96.0 GiB)
```

So- eno1, is the onboard 1GBe nic... which, shouldn't be active.

The solution here was quite simple. I wanted to leave it DHCP enabled, in the event I needed to access this box, without the 10GBe interface.

So, I unplugged the cable!

``` bash
kube05:~# iperf3 -c 10.100.5.1 --bidir
Connecting to host 10.100.5.1, port 5201
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID][Role] Interval           Transfer     Bitrate         Retr
[  5][TX-C]   0.00-10.00  sec  11.1 GBytes  9.52 Gbits/sec    0
[  7][RX-C]   0.00-10.00  sec  11.1 GBytes  9.50 Gbits/sec    0
```

Easiest fix ever, right?


## Summary

I was quite certain my issue was related to the really cheap DACs / SFP modules in use. However- turns out, it was all configuration issues.

I started by [looking the 10G NICs](./2023-02-07-ConnectX3-Settings.md){target=_blank}. I ensured proper settings and offloading was enabled. This did not help any.

The next step, was to put togather a metrix showing performance between each node. This allowed me to actually rule out most of the cables and connections, by showing nodes which were working at full speed.

The final step, was changing the MTU size.

### Why did MTU size fix everything?

NORMALLY, a larger MTU size won't have nearly as dramatic as a difference in my tests. 

However- one thing that was not clearly noted here- There are multiple vlans coming out of the interfaces for both Opnsense, and TrueNAS. ONE of the vlans was already set to 9,000MTU jumbo frames.

My assumptions on what happened-

1. Opnsense has low single-threaded CPU performance. This caused its results to be low across the board.
2. Data being sent to TrueNAS, was low across the board too. I believe this is due to its 10G interface having another vlan already, with jumbo frames enabled.
    * It doesn't make sense to me, why its receive speed would be low, however. But, jumbo frames did correct this.
    * This MAY be related to single-threaded iperf performance too. The CPU on my TrueNAS box has a lot of cores(40 of them), but, each core is quite slow.
3. Larger packet sizes cuts down on the amount of CPU required to process packets.
4. Kube05 obviously had a network identify crisis, with two NICs on the same network, each with differing MTUs.



So, my hopes of publishing this post, is to give you ideas of where to start troubleshooting network performance issues.
