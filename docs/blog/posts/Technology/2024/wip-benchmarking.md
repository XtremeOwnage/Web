## Iperf2

https://sourceforge.net/projects/iperf2/files/

``` bash
wget https://sourceforge.net/projects/iperf2/files/iperf-2.2.0.tar.gz/download


```



## ROCE Perf Testing

https://github.com/linux-rdma/perftest

``` bash
wget https://github.com/linux-rdma/perftest/releases/download/24.04.0-0.41/perftest-24.04.0-0.41.gd1b3607.tar.gz
tar -xvzf perftest-24.04.0-0.41.gd1b3607.tar.gz
cd perftest-24.04.0/
./autogen.sh
./configure

```


## ROCE Perf - Method 2

``` bash
apt-get install libmlx4-1 infiniband-diags ibutils ibverbs-utils rdmacm-utils perftest

```

Start Server: `udaddy`

Run Client: `udaddy -s server.ip`

``` bash
root@kube01:~# udaddy -s 10.100.4.102
udaddy: starting client
udaddy: connecting
initiating data transfers
receiving data transfers
data transfers complete
test complete
return status 0
```

Rdma Test

``` bash
# Server
root@kube02:~/iperf/perftest-24.04.0# rdma_server
rdma_server: start
rdma_server: end 0

# Client
root@kube01:~# rdma_client -s 10.100.4.102
rdma_client: start
rdma_client: end 0
```

Performance Test

Run Server

``` bash
ib_send_bw -d mlx5_0 -i 1 -F --report_gbits
```

Run Client

``` bash
root@kube01:~#  ib_send_bw -d mlx5_0 -i 1 -F --report_gbits 10.100.4.102
---------------------------------------------------------------------------------------
                    Send BW Test
 Dual-port       : OFF          Device         : mlx5_0
 Number of qps   : 1            Transport type : IB
 Connection type : RC           Using SRQ      : OFF
 PCIe relax order: ON
 ibv_wr* API     : ON
 TX depth        : 128
 CQ Moderation   : 1
 Mtu             : 1024[B]
 Link type       : Ethernet
 GID index       : 3
 Max inline data : 0[B]
 rdma_cm QPs     : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0000 QPN 0x0108 PSN 0xe562d0
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:10:100:06:100
 remote address: LID 0000 QPN 0x0108 PSN 0xf670e8
 GID: 00:00:00:00:00:00:00:00:00:00:255:255:10:100:06:102
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[Gb/sec]    BW average[Gb/sec]   MsgRate[Mpps]
 65536      1000             56.75              56.75              0.108237
---------------------------------------------------------------------------------------
```


https://enterprise-support.nvidia.com/s/article/ib-send-bw