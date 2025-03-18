

## SystemD Script

Source: https://forums.servethehome.com/index.php?threads/bridging-network-interfaces-with-sr-iov-on-a-proxmox-host.42922/


Code:

```
[Unit]
Description=Enable SR-IOV and detach guest VFs from host
Requires=network.target
After=network.target
Before=pve-firewall.service
[Service]
Type=oneshot
RemainAfterExit=yes
# Create NIC VFs
ExecStart=/usr/bin/bash -c 'echo 8 > /sys/class/net/ens2f0np0/device/sriov_numvfs'
ExecStart=/usr/bin/bash -c 'echo 8 > /sys/class/net/ens2f1np1/device/sriov_numvfs'
# Set static MACs for VFs
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 0 mac 76:9e:17:83:39:e5'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 1 mac 46:2c:6d:24:6b:1b'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 2 mac 3e:47:48:12:ed:94'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 3 mac be:e3:6a:f3:8f:ac'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 4 mac 62:8f:3d:bb:02:08'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 5 mac ae:91:57:b9:14:7f'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 6 mac 5a:c2:08:a9:68:a7'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 7 mac b2:f0:18:af:cb:c5'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 0 mac 16:47:7c:a8:95:98'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 1 mac a6:c7:c5:7f:9c:22'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 2 mac b6:0f:45:34:5e:19'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 3 mac 2a:f7:37:84:31:30'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 4 mac 8a:fa:f8:c5:0b:93'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 5 mac b2:f5:d5:2f:79:06'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 6 mac c2:92:f5:fa:32:20'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 7 mac 2e:fb:29:1e:48:31'
# Detach VFs from host
ExecStart=/usr/bin/bash -c 'echo 0000:01:00.3 > /sys/bus/pci/devices/0000\\:01\\:00.3/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:00.4 > /sys/bus/pci/devices/0000\\:01\\:00.4/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:00.5 > /sys/bus/pci/devices/0000\\:01\\:00.5/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:00.6 > /sys/bus/pci/devices/0000\\:01\\:00.6/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:00.7 > /sys/bus/pci/devices/0000\\:01\\:00.7/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.0 > /sys/bus/pci/devices/0000\\:01\\:01.0/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.1 > /sys/bus/pci/devices/0000\\:01\\:01.1/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.3 > /sys/bus/pci/devices/0000\\:01\\:01.3/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.4 > /sys/bus/pci/devices/0000\\:01\\:01.4/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.5 > /sys/bus/pci/devices/0000\\:01\\:01.5/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.6 > /sys/bus/pci/devices/0000\\:01\\:01.6/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:01.7 > /sys/bus/pci/devices/0000\\:01\\:01.7/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:02.0 > /sys/bus/pci/devices/0000\\:01\\:02.0/driver/unbind'
ExecStart=/usr/bin/bash -c 'echo 0000:01:02.1 > /sys/bus/pci/devices/0000\\:01\\:02.1/driver/unbind'
# List new VFs
ExecStart=/usr/bin/lspci -D -d1924:
# Destroy VFs
ExecStop=/usr/bin/bash -c 'echo 0 > /sys/class/net/ens2f0np0/device/sriov_numvfs'
ExecStop=/usr/bin/bash -c 'echo 0 > /sys/class/net/ens2f1np1/device/sriov_numvfs'
# Reload NIC VFs
ExecReload=/usr/bin/bash -c 'echo 0 > /sys/class/net/ens2f0np0/device/sriov_numvfs'
ExecReload=/usr/bin/bash -c 'echo 0 > /sys/class/net/ens2f1np1/device/sriov_numvfs'
ExecReload=/usr/bin/bash -c 'echo 8 > /sys/class/net/ens2f0np0/device/sriov_numvfs'
ExecReload=/usr/bin/bash -c 'echo 8 > /sys/class/net/ens2f1np1/device/sriov_numvfs'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 0 mac 76:9e:17:83:39:e5'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 1 mac 46:2c:6d:24:6b:1b'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 2 mac 3e:47:48:12:ed:94'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 3 mac be:e3:6a:f3:8f:ac'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 4 mac 62:8f:3d:bb:02:08'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 5 mac ae:91:57:b9:14:7f'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 6 mac 5a:c2:08:a9:68:a7'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f0np0 vf 7 mac b2:f0:18:af:cb:c5'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 0 mac 16:47:7c:a8:95:98'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 1 mac a6:c7:c5:7f:9c:22'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 2 mac b6:0f:45:34:5e:19'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 3 mac 2a:f7:37:84:31:30'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 4 mac 8a:fa:f8:c5:0b:93'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 5 mac b2:f5:d5:2f:79:06'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 6 mac c2:92:f5:fa:32:20'
ExecReload=/usr/bin/bash -c '/usr/bin/ip link set ens2f1np1 vf 7 mac 2e:fb:29:1e:48:31'
ExecReload=/usr/bin/bash -c 'echo 0000:01:00.3 > /sys/bus/pci/devices/0000\\:01\\:00.3/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:00.4 > /sys/bus/pci/devices/0000\\:01\\:00.4/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:00.5 > /sys/bus/pci/devices/0000\\:01\\:00.5/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:00.6 > /sys/bus/pci/devices/0000\\:01\\:00.6/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:00.7 > /sys/bus/pci/devices/0000\\:01\\:00.7/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.0 > /sys/bus/pci/devices/0000\\:01\\:01.0/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.1 > /sys/bus/pci/devices/0000\\:01\\:01.1/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.3 > /sys/bus/pci/devices/0000\\:01\\:01.3/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.4 > /sys/bus/pci/devices/0000\\:01\\:01.4/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.5 > /sys/bus/pci/devices/0000\\:01\\:01.5/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.6 > /sys/bus/pci/devices/0000\\:01\\:01.6/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:01.7 > /sys/bus/pci/devices/0000\\:01\\:01.7/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:02.0 > /sys/bus/pci/devices/0000\\:01\\:02.0/driver/unbind'
ExecReload=/usr/bin/bash -c 'echo 0000:01:02.1 > /sys/bus/pci/devices/0000\\:01\\:02.1/driver/unbind'
ExecReload=/usr/bin/lspci -D -d1924:
[Install]
WantedBy=multi-user.target
```