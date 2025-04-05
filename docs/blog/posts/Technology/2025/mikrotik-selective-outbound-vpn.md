---
title: Mikrotik Outbound Wireguard
date: 2025-04-05
tags:
    - Homelab
    - Networking
    - Networking/Mikrotik
    - Networking/VPN
    - Networking/VPN/WireGuard

---

# Mikrotik - Route specific websites or hosts through VPN.

This post outlines how to accomplish the following activities:

1. Creating an interface for a remote wireguard VPN connection to an upstream VPN provider.
2. Forcing specific websites over VPN via Destination IP or DNS.
3. Forcing specific hosts over VPN via Source IP.


<!-- more -->

## Get configuration from VPN Provider

Your upstream VPN provider will give you a configuration which resembles this:

``` ini
[Interface]
PrivateKey = gMe7NtkQJdnxeFc5jmdke+CNY45Y/aN1ugLpiMF9X3g=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = PsLFVA2NRBa0P8zXiwHN8LqD11e3weemHoduXs8XBns=
AllowedIPs = 0.0.0.0/0
Endpoint = 1.20.30.40:51820
```

## Configure VPN Interface, Routing/Firewall rules, etc.

Here is the full script to automatically provision the VPN connection, and create the proper interfaces, lists, peers, routing-tables, and NAT.

Details will be given below in this post.

This will NOT route any traffic over the VPN. Those steps will be provided later in this post.

!!! warning
    You will need to modify the variables at the top of the script.

```
### These variables MUST be changed

## Set Peer Endpoint
# Set the peer's endpoint here. (Under [peer] section of config)
# Remove the port!

: global peerEndpointIP 1.20.30.40
# Set the peer's port here (The port from [Peer].Endpoint)
: global peerEndpointPort 51820

## Set Public/Private Keys
# Put your peer's public key here. (Under [peer] section of config)
: global peerPublicKey "PsLFVA2NRBa0P8zXiwHN8LqD11e3weemHoduXs8XBns="
# Put your private key here. (Under [interface] section of config)
: global myPrivateKey "gMe7NtkQJdnxeFc5jmdke+CNY45Y/aN1ugLpiMF9X3g="

## Set Local IPs
# This is the IP address from the [Interface] section of the configuration from our provider.
: global myLocalIP 10.2.0.2
# This is the local IP address from the Peer. It is not listed in the configuration I received- however, 
# We can assume is is a /30 subnet, which leaves... 10.2.0.1. Also- this matches the DNS received in the upstream configuration.
: global peerLocalIP 10.2.0.1

### These variables can optionally be changed, if needed.
# Set a name for the interface
: global vpnInterfaceName "WG-VPN-OUT"
# Set a name for the interface list which will contain "outbound" VPNs
: global vpnInterfaceListName "Outbound_VPN"
# Set local port. (Only need to change if it is already in use by another connection)
: global vpnLocalPort 22580
# Name of the new routing-table which will be used to force clients over VPN connections
: global vpnRoutingTableName "force-vpn"
# Name of the firewall chain which will be used for VPN traffic
: global vpnFirewallChainNameIn "OUTBOUND_VPN-IN"

### Below here, creates the correct configurations.

## Create Interface

# Create interface
/interface/wireguard/add listen-port=$vpnLocalPort mtu=1420 name=$vpnInterfaceName private-key=$myPrivateKey

# Create the peer
/interface/wireguard/peers/add allowed-address=0.0.0.0/0 comment=$vpnInterfaceName endpoint-address=$peerEndpointIP endpoint-port=$peerEndpointPort interface=$vpnInterfaceName public-key=$peerPublicKey

# Create Interface List
/interface/list/add comment="Outbound VPN Interfaces" name=$vpnInterfaceListName

# Add VPN Interface to list
/interface/list/member/add comment="Remote VPN Peer" interface=$vpnInterfaceName list=$vpnInterfaceListName

# Create IP Address
/ip/address/add address="$myLocalIP/30" comment=$vpnInterfaceName interface=$vpnInterfaceName network=$myLocalIP

# Create Routing Table. This will force the specified clients to route over the VPN.
/routing/table/add disabled=no name=$vpnRoutingTableName fib

# Create Routes to force traffic over VPN.
/ip/route/add check-gateway=ping comment="Use VPN" disabled=no distance=1 dst-address=0.0.0.0/0 gateway=$peerLocalIP routing-table=$vpnRoutingTableName scope=30 suppress-hw-offload=no target-scope=10
# This create a blackhole route, which will drop outbound traffic if the VPN connection is down.
/ip/route/add blackhole comment="Drop traffic if VPN is down" disabled=no distance=32 dst-address=0.0.0.0/0 gateway="" routing-table=$vpnRoutingTableName scope=30 suppress-hw-offload=no

# Create outbound NAT rule to masquerade traffic going over VPN.
/ip/firewall/nat/add action=masquerade chain=srcnat comment="VPN Masquerade" out-interface-list=$vpnInterfaceListName

# Create Firewall Rules. Only allow established connections. Drop everything else.
/ip/firewall/filter
add chain=input                 action=jump                     comment="Chain: $vpnFirewallChainNameIn" in-interface-list=$vpnInterfaceListName jump-target=$vpnFirewallChainNameIn
add chain=$vpnFirewallChainNameIn    action=fasttrack-connection     comment="Fasttrack: Related, Established" connection-state=established,related hw-offload=yes
add chain=$vpnFirewallChainNameIn    action=accept                   comment="Accept: Established, Related, Untracked" connection-state=established,related,untracked
add chain=$vpnFirewallChainNameIn    action=drop                     comment="Drop: State: Invalid" connection-state=invalid
add chain=$vpnFirewallChainNameIn    action=drop                     comment="Drop All w/Log" log=yes log-prefix=DROP

# Create an address list containing the RFC1918 IPv4 subnet ranges. (Aka, Private IPv4 Ranges)
/ip firewall address-list
add address=10.0.0.0/8 list=rfc1918
add address=172.16.0.0/12 list=rfc1918
add address=192.168.0.0/16 list=rfc1918

# Create mangle rules, which will force the specific traffic to use the VPN-Only Routing Table
/ip firewall mangle
# This rule forces traffic via VPN for source IP address. Aka- force local hosts to use VPN
add action=mark-routing chain=prerouting comment="Force VPN for Source Address"      dst-address-list=!rfc1918      new-routing-mark=$vpnRoutingTableName src-address-list=Force_SRC_VPN
# This rule forces traffic via VPN for destination IP addresses. Aka, Specific hosts on the WAN, or specific websites.
add action=mark-routing chain=prerouting comment="Force VPN for Destination Address" dst-address-list=Force_DST_VPN new-routing-mark=$vpnRoutingTableName
```

!!! note
    The above keys were randomly generated.... they don't work anywhere.
    Don't bother trying...

### More Details

This section will break the above script into smaller pieces, and provide brief explanations

I don't believe any further details are needed for setting the variables.

The purpose of the variables, is to remove the need for you to update multiple items in the configuration.

#### Create Interface

This creates a new wireguard interface, and associates the private key from the upstream configuration.

```
## Create Interface

# Create interface
/interface wireguard
add listen-port=$vpnLocalPort mtu=1420 name=$vpnInterfaceName private-key=$myPrivateKey
```

#### Create the peer

This will create the remote peer. By specifying the endpoint here, the router will automatically connect to the endpoint and maintain a connection.

```
/interface wireguard peers
add allowed-address=0.0.0.0/0 comment=$vpnInterfaceName endpoint-address=$peerEndpointIP endpoint-port=$peerEndpointPort interface=$vpnInterfaceName public-key=$peerPublicKey
```

#### Create Interface List

To simplify other configurations, I am leveraging an interface list. 

If- for example you had multiple outbound VPN connections to various providers, you could just add the interfaces to this list, which will automatically apply the same firewall rules.

```
/interface list
add comment="Outbound VPN Interfaces" name=$vpnInterfaceListName
```

Then- we add the VPN interface to the newly created list.

```
/interface list member
add comment="Remote VPN Peer" interface=$vpnInterfaceName list=$vpnInterfaceListName
```

#### Create IP Address

We need to provision an IP address to allow routing to work.

This line provisions our local IP address, for the VPN interface.

```
/ip address
add address="$myLocalIP/30" comment=$vpnInterfaceName interface=$vpnInterfaceName network=$myLocalIP
```

#### Create Routing Table. This will force the specified clients to route over the VPN.

The easiest way for us to route traffic over the VPN, is literally by routing the traffic over the VPN.

To do this- we will first create a routing table. This- will not be used by anything "yet"

```
/routing/table
add disabled=no name=$vpnRoutingTableName fib
```

Next- we create the default route, which tells all traffic to route through the remote peer.

`check-gateway=ping` is configured here, which will mark the route as inactive if we are unable to ping the remote host. (aka, the connection is down.)

The distance here is set to 1, which will make this the preferred route.

```
/ip/route
add check-gateway=ping comment="Use VPN" disabled=no distance=1 dst-address=0.0.0.0/0 gateway=$peerLocalIP routing-table=$vpnRoutingTableName scope=30 suppress-hw-offload=no target-scope=10
```
Afterwards, A blackhole route is created with a higher distance then the default route.

When- the primary default route is marked as inactive due to the remote host being unreachable, this will become the default route.

This will "blackhole" the traffic. Ie- it gets dropped.

```
add blackhole comment="Drop traffic if VPN is down" disabled=no distance=32 dst-address=0.0.0.0/0 gateway="" routing-table=$vpnRoutingTableName scope=30 suppress-hw-offload=no
```

#### Outbound NAT

While- most VPN providers do handle NAT on their end, I still prefer to do NAT on my side.

One reason being- I don't want the remote VPN provider to know anything about my internal IP structures. I also don't want the remote provider to be able to easily distinguish my internal clients based on their IP addresses.

So- I NAT outbound traffic going through any of the interfaces in the newly created interface list.

```
/ip firewall nat
add action=masquerade chain=srcnat comment="VPN Masquerade" out-interface-list=$vpnInterfaceListName
```

#### Firewall Rules

Since- I have quite a few firewall rules, I prefer to use chains to organize rules together. For this example, I am storing all of the rules for the outbound VPN interfaces into a new chain.

```
/ip firewall filter

# When traffic comes into any of the interfaces on the outbound VPN interface list, we will jump to the "VPN-IN Chain"
add chain=input                 action=jump                     comment="Chain: $vpnFirewallChainNameIn" in-interface-list=$vpnInterfaceListName jump-target=$vpnFirewallChainNameIn

## The below rules are only applied against traffic matched by the above jump rule.

# For any hardware-offloaded established connections, fast-track.
add chain=$vpnFirewallChainNameIn    action=fasttrack-connection     comment="Fasttrack: Related, Established" connection-state=established,related hw-offload=yes

# Allow established, related sessions.
add chain=$vpnFirewallChainNameIn    action=accept                   comment="Accept: Established, Related, Untracked" connection-state=established,related,untracked

# Drop invalid packets.
add chain=$vpnFirewallChainNameIn    action=drop                     comment="Drop: State: Invalid" connection-state=invalid

# Drop... ALL packets.
# This- will drop any inbound packets, which are not apart of an active, established session.
add chain=$vpnFirewallChainNameIn    action=drop                     comment="Drop All w/Log" log=yes log-prefix=DROP
```

## Route Specific Hosts through VPN (By Source IP/Mask)

To force specific hosts to route all traffic through VPN, we will use a simple pre-routing rule.

!!! info
    Note- you will need to customize the addresses for this list.

```
/ip firewall address-list
# Add clients to be forced through the outbound VPN.
add address=192.168.1.8  comment="IP Addresses in this list will only be allowed to access the internet via VPN." list=Force_SRC_VPN
add address=192.168.1.16 comment="IP Addresses in this list will only be allowed to access the internet via VPN." list=Force_SRC_VPN
```

After the lists has been created, Add a mangle rule to force clients to use the new routing table created earlier, but only for traffic WAN-bound.

!!! info
    This uses the $vpnRoutingTableName variable from the main script. This also uses the rfc1918 address-list created in the initial script.

    This mangle rule is created by the main script as well.

```
/ip firewall mangle
add action=mark-routing chain=prerouting comment="Force VPN for Source Address" dst-address-list=!rfc1918 new-routing-mark=$vpnRoutingTableName src-address-list=Force_SRC_VPN
```

Thats it. Any hosts in the `Force_SRC_VPN` address-list will now be forced to be routed over the VPN connection.

If the VPN connection is down, the traffic will instead be dropped via the routing blackhole.

## Route Specific Websites through VPN (By DNS)

This example shows how to force specific websites to be forced over the VPN connection.

This can be used to selectively route certain websites which may have geopolitical restrictions.

First- we will need to setup a reusable script which will be used to populate address lists based on DNS lookups.

!!! note
    I did not create this script! But- in my testing, it does work.

    [Original Source](https://gist.github.com/Pablo1/5410433){target=_blank}


```
/system script
add comment="Adds specified DNS Domains to an address list" dont-require-permissions=no name=DNSToAddressList owner=admin policy=read,write source=":global ListName\
    \n:global Servers\
    \n:global Done\
    \n\
    \n#has \$Done been initialized\?\
    \n:if ([:typeof \$Done] != \"boolean\") do={\
    \n  :set Done true;\
    \n}\
    \n\
    \n#make sure previous runs have finished\
    \nwhile (!\$Done) do={\
    \n  :nothing;\
    \n}\
    \n\
    \n#block any other runs\
    \n:set Done false;\
    \n\
    \n#delete old address lists\
    \n:foreach aListItem in=[/ip firewall address-list find list=\$ListName] do={\
    \n  /ip firewall address-list remove \$aListItem;\
    \n}\
    \n\
    \n:foreach aServer in=\$Servers do={\
    \n#force the dns entries to be cached\
    \n  :resolve \$aServer;\
    \n\
    \n  :foreach dnsRecord in=[/ip dns cache all find where (name=\$aServer)] do={\
    \n#if it's an A records add it directly\
    \n    :if ([/ip dns cache all get \$dnsRecord type]=\"A\") do={\
    \n       /ip firewall address-list add list=\$ListName address=[/ip dns cache all get \$dnsRecord data] comment=\$aServer;\
    \n    }\
    \n\
    \n#if it's a CNAME follow it until we get A records\
    \n    :if ([/ip dns cache all get \$dnsRecord type]=\"CNAME\") do={\
    \n      :local cname;\
    \n      :local nextCname\
    \n      :set cname [/ip dns cache all find where (name=\$aServer && type=\"CNAME\")];\
    \n      :set nextCname [/ip dns cache all find where (name=[/ip dns cache all get \$cname data] && type=\"CNAME\")];\
    \n\
    \n      :while (\$nextCname != \"\") do={\
    \n          :set cname \$nextCname;\
    \n          :set nextCname [/ip dns cache all find where (name=[/ip dns cache all get \$cname data] && type=\"CNAME\")];\
    \n        }\
    \n  \
    \n#add the a records we found\
    \n    :foreach aRecord in=[/ip dns cache all find where (name=[/ip dns cache all get \$cname data] && type=\"A\")] do={\
    \n      /ip firewall address-list add list=\$ListName address=[/ip dns cache all get \$aRecord data] comment=\$aServer;\
    \n      }\
    \n    }\
    \n  }\
    \n}\
    \n\
    \n#allow other scripts to call this\
    \n:set Done true"
```

Next, we will create a schedule which will automatically execute on an interval to populate our IP Address Lists, for a given list of domains.

This script will populate the target list with the DNS to IP lookups from the script itself. Customize the host names as needed. Multiple dns addresses can be added.

I set the interval to run every hour, however, you can customize as needed.

```
/system scheduler
add comment="This executes the script which populates Force_DST_VPN address list" interval=1h name=UpdateForcedVPNList on-event=":global ListName Force_VPN\
    \n:global Servers {\"yourwebsite.com\";\"www.yourwebiste.com\";\"anotherwebsite.com\"}\
    \n/system script run DNSToAddressList" policy=read,write,test start-time=startup
```


Now we need to create another mangle rule to force the specified traffic to use the VPN-Only routing table.

!!! info
    This uses the $vpnRoutingTableName variable from the main script.

    This mangle rule is created by the main script as well.

```
/ip firewall mangle
add action=mark-routing chain=prerouting comment="Force VPN for Destination Address" dst-address-list=Force_DST_VPN new-routing-mark=$vpnRoutingTableName
```

Thats... basically it.


### Testing destination WAN.

Using, a very well-known website with geopolitical restrictions, I added only the primary domain to an address list, and performed testing.

```
ping wellknownwebsite.com

Pinging wellknownwebsite.com [66.254.114.41] with 32 bytes of data:
Reply from 66.254.114.41: bytes=32 time=143ms TTL=57
Reply from 66.254.114.41: bytes=32 time=142ms TTL=57

ping www.wellknownwebsite.com

Pinging wellknownwebsite.com [66.254.114.41] with 32 bytes of data:
Reply from 66.254.114.41: bytes=32 time=146ms TTL=57
Reply from 66.254.114.41: bytes=32 time=142ms TTL=57
Reply from 66.254.114.41: bytes=32 time=143ms TTL=57

## Testing.... with an alternative domain to said website

ping wellknownpremiumwebsite.com

Pinging wellknownpremiumwebsite.com [66.254.114.0] with 32 bytes of data:
Reply from 66.254.114.0: bytes=32 time=10ms TTL=55
Reply from 66.254.114.0: bytes=32 time=10ms TTL=55
Reply from 66.254.114.0: bytes=32 time=10ms TTL=55
```

In the first two examples the traffic is being routed out of a common european country, which is a very popular place for hosted VPNs.

In the bottom example, the "premium" website was not added to the IP Address list. Notice the much shorter response times.

## Summary

This post was just intended to centralize documentation and methods for forcing traffic over a VPN connection.

You should now be able to force traffic over VPN by both Source IP (your internal IP), Destination IP, and Destination DNS.

This was not intended to be the end-all guide to Mikrotik VPN, only a short reference for forcing specific traffic over VPN connections.

Here are a few of the various references I used to build these configurations:

* <https://help.mikrotik.com/docs/spaces/ROS/pages/69664792/WireGuard>{target=_blank}
* <https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting#Scripting-Variables>{target=_blank}
* <https://help.mikrotik.com/docs/spaces/ROS/pages/48660587/Mangle>{target=_blank}
* <https://protonvpn.com/support/wireguard-mikrotik-routers/>{target=_blank}
* <https://superuser.com/questions/999196/mikrotik-and-vpn-for-specific-web-sites-only>{target=_blank}