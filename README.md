# wazuh-makejail
Wazuh-makejail is a [AppJail](https://github.com/DtxdF/AppJail) template (AppJail-makejail) used by deploy a testing [Wazuh](https://wazuh.com/) single-node infrastructure on [FreeBSD](https://freebsd.org/). The principal goals are helps us to fast way install, configure and run wazuh-indexer (opensearch), wazuh-manager, logstash, filebeat and wazuh-dashboards (opensearch-dashboards + wazuh-kibana-app). Take on mind this container as is must be used by testing/learning purpose and it is not recommended for production because it has a minimal configuration for run wazuh.

![image](https://user-images.githubusercontent.com/11150989/204661974-141395d0-dda0-4573-8ea6-4d3b17ad2759.png)

![image](https://user-images.githubusercontent.com/11150989/204662101-75880698-8cfd-4aa9-b0ac-e9bac011cd5c.png)

## Requirements
Before you can install wazuh using this template you need some initial configurations

#### Create a loopback interface
We can create it add some lines to /etc/rc.conf
```sh
# sysrc cloned_interfaces="lo1"
# sysrc ifconfig_lo1_name="appjail0"
# service netif cloneup
```
#### Enable Packet filter
We need add somes lines to /etc/rc.conf

```sh
# sysrc pf_enable="YES"
```
Edit /etc/pf.conf and modify like you want. Minimal working configuration could look at the following

```sh
ext_if="em0"
lo_if="bastille0"

set block-policy return
scrub in on $ext_if all fragment reassemble
set skip on lo

table <jails> persist
nat on $ext_if from <jails> to any -> ($ext_if:0)
rdr-anchor "rdr/*"

block in all
pass out quick keep state
antispoof for $ext_if inet
pass in inet proto tcp from any to any port ssh flags S/SA keep state

pass in quick on $ext_if inet proto { tcp udp } from any to any
pass out quick on $ext_if inet proto { tcp udp } from any to any

pass in quick on $lo_if inet proto { tcp udp } from any to any
pass out quick on $lo_if inet proto { tcp udp } from any to any
```
rdr-anchor section is necessary for use dynamic redirect from jails

Start packet filter

```sh
# service pf start
```
#### Bootstrap a FreeBSD version
Before you can begin creating containers, AppJail needs to "bootstrap" a release. It must be a version equal or lesser than your host version. In this example we will create a 13.2-RELEASE bootstrap

```sh
# appjail bootstrap 13.2-RELEASE
```
#### Create a lightweight container system
Create a container named wazuh with a private IP address 10.0.0.2

```sh
# appjail makejail -f gh+alonsobsd/wazuh-makejail -j wazuh -- --network wazuh-net --server_ip 10.0.0.2
# appjail makejail -j wazuh -- --network wazuh-net --server_ip 10.0.0.2
```

When it is done you will see credentials info for connect to wazuh-dashboards via web browser.

```sh
################################################ 
 Wazuh dashboard admin credentials                
 Hostname : https://jail-host-ip:5601/app/wazuh   
 Username : admin                                 
 Password : @hkXudpIp93xbIOvD                          
################################################
 ```
Keep it to another place

## License
This project is licensed under the BSD-3-Clause license.
