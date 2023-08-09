












## Testing Method

Testing will be performed using a LXC container running on top of proxmox, with ceph-block storage mounted.

```
seq_wr: (g=0): rw=write, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=256
seq_rd: (g=1): rw=read, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=256
rand_rd: (g=2): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
rand_wr: (g=3): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
fio-3.33
```


### Test 1. 4x SATA SSD + 980 evo, Ran on remote node.

| Workload   | Read/Write | Block Size | Queue Depth | Bandwidth (KiB/s) | IOPS   |
|------------|------------|------------|-------------|-------------------|--------|
| seq_rd     | Read       | 128 KiB    | 256         | 190 MiB/s         | 1519   |
| seq_wr     | Write      | 128 KiB    | 256         | 86.0 MiB/s        | 688    |
| rand_rd    | Read       | 4 KiB      | 256         | 6215 KiB/s        | 1553   |
| rand_wr    | Write      | 4 KiB      | 256         | 7382 KiB/s        | 1845   |


### Test 2. 4x SATA SSD. 980 evo removed.

With the Samsung 980 evo removed, we get these results:

| Workload   | IOPs  | Bandwidth (MiB/s) | Avg Latency (ms) | 99th Percentile Latency (ms) |
|------------|-------|-------------------|------------------|-----------------------------|
| seq_wr     | 1428  | 179               | 179              | 334                         |
| seq_rd     | 1326  | 166               | 191              | 334                         |
| rand_rd    | 1136  | 4.44              | 224              | 300                         |
| rand_wr    | 4320  | 16.9              | 59.09            | 163                         |



### Test 3. Running benchmarks local to ceph OSDs

Previous tests were ran on `kube02` which has no storage attached to it. As a result, all ceph traffic has to visit `kube01` and `kube05`.

For this test, the benchmarks will be ran from `kube05`, which hosts 3 of the 4 currently active OSDs.

| Workload  |   IOPs | Bandwidth (MiB/s) | Avg Latency (ms) | 99th Percentile Latency (ms) |
|-----------|-------:|-------------------:|-----------------:|-----------------------------:|
| seq_wr    |   2280 |             285    |          112.23  |                        236    |
| seq_rd    |   2271 |             284    |          112.16  |                        171    |
| rand_rd   |   1822 |               7.29 |          140.23  |                        230    |
| rand_wr   |   4015 |              15.7  |           63.74  |                        107    |


### Test 4. Addition of 4x new OSDs

Added 4x new SSDs.

| Workload  | IOPs | Bandwidth (MiB/s) | Average Latency (ms) | 99th Percentile Latency (ms) |
|-----------|------|-------------------|----------------------|-----------------------------|
| seq_wr    | 2321 | 290               | 110.18               | 205                         |
| seq_rd    | 1959 | 245               | 130.12               | 243                         |
| rand_rd   | 1384 | 5.47              | 184.05               | 215                         |
| rand_wr   | 5171 | 20.2              | 49.43                | 137.36                      |


### Test 5. Just deleted and recreated the test volume.

| Workload | IOPs  | Bandwidth (MiB/s) | Average Latency (ms) | 99th Percentile Latency (ms) |
|----------|-------|-------------------|----------------------|-----------------------------|
| seq_wr   | 2687  | 336               | 95.186               | 207                         |
| seq_rd   | 2249  | 281               | 112.753              | 317                         |
| rand_rd  | 1518  | 5.93              | 167.525              | 347                         |
| rand_wr  | 7569  | 29.6              | 33.748               | 95.945                      |


### Test 6. ceph tell

After noticing, far less then expected changes after test 4 and 5- I determined that perhaps my benchmarking strategy is flawed.

So, a few more tests.

First up, `ceph tell osd.* bench`

| OSD  | Bytes Written | Block Size | Elapsed Time (sec) | Bytes Per Second (MiB/s) | IOPS       |
|------|---------------|------------|--------------------|-------------------------|------------|
| osd.0 | 1.0 GiB       | 4 MiB      | 2.2576             | 453.6                   | 113.393    |
| osd.1 | 1.0 GiB       | 4 MiB      | 2.3308             | 440.1                   | 109.833    |
| osd.2 | 1.0 GiB       | 4 MiB      | 2.2770             | 454.7                   | 112.430    |
| osd.3 | 1.0 GiB       | 4 MiB      | 1.0902             | 939.8                   | 234.823    |
| osd.4 | 1.0 GiB       | 4 MiB      | 2.2956             | 445.1                   | 111.519    |
| osd.5 | 1.0 GiB       | 4 MiB      | 1.0839             | 944.6                   | 236.176    |
| osd.6 | 1.0 GiB       | 4 MiB      | 1.0796             | 948.6                   | 237.123    |
| osd.7 | 1.0 GiB       | 4 MiB      | 1.0729             | 953.2                   | 238.604    |


### Test 7. Rados

`rados bench -p scbench 10 write --no-cleanup`

| Metric                | Value         |
|-----------------------|---------------|
| Total time run        | 10.0457 sec   |
| Total writes made     | 1878          |
| Write size            | 4194304 bytes |
| Object size           | 4194304 bytes |
| Bandwidth (MB/sec)    | 747.784 MB/s  |
| Stddev Bandwidth      | 55.6433       |
| Max bandwidth (MB/sec)| 828 MB/s      |
| Min bandwidth (MB/sec)| 664 MB/s      |
| Average IOPS          | 186           |
| Stddev IOPS           | 13.9108       |
| Max IOPS              | 207           |
| Min IOPS              | 166           |
| Average Latency(s)    | 0.0855197 sec |
| Stddev Latency(s)     | 0.0543139 sec |
| Max latency(s)        | 0.394606 sec  |
| Min latency(s)        | 0.010446 sec  |


`rados bench -p scbench 10 seq`



