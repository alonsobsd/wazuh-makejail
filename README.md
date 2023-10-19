# wazuh-makejail
Wazuh-makejail is a [AppJail](https://github.com/DtxdF/AppJail) file ([AppJail-makejail](https://github.com/AppJail-makejails)) used by deploy a testing [Wazuh](https://wazuh.com/) single-node infrastructure on [FreeBSD](https://freebsd.org/). The principal goals are helps us to fast way install, configure and run wazuh-indexer (opensearch), wazuh-manager, logstash, filebeat and wazuh-dashboards (opensearch-dashboards + wazuh-kibana-app). Take on mind this container as is must be used by testing/learning purpose and it is not recommended for production because it has a minimal configuration for run wazuh.

![image](https://github.com/alonsobsd/wazuh-makejail/assets/11150989/8b33452f-9288-4215-981e-1350e468a4b8)

![image](https://github.com/alonsobsd/wazuh-makejail/assets/11150989/803ff835-1f67-4bc0-80c8-29029b9ffb03)

![image](https://github.com/alonsobsd/wazuh-makejail/assets/11150989/021abc67-cb5e-4527-92b3-ded75eef9dc6)

![image](https://github.com/alonsobsd/wazuh-makejail/assets/11150989/8f60b7a2-ddf8-4d08-8986-e2b9bd5cf0fc)

## Requirements
Before you can install wazuh using this makejail you need some initial configurations

#### Enable Packet filter
We need add somes lines to /etc/rc.conf

```sh
# sysrc pf_enable="YES"
# sysrc pflog_enable="YES"

# cat << "EOF" >> /etc/pf.conf
nat-anchor 'appjail-nat/jail/*'
nat-anchor "appjail-nat/network/*"
rdr-anchor "appjail-rdr/*"
EOF
# service pf reload
# service pf restart
# service pflog restart
```
rdr-anchor section is necessary for use dynamic redirect from jails

### Enable forwarding
```sh
# sysrc gateway_enable="YES"
# sysctl net.inet.ip.forwarding=1
```
#### Bootstrap a FreeBSD version
Before you can begin creating containers, AppJail needs fetch and extract components for create jails. If you are creating FreeBSD jails it must be a version equal or lesser than your host version. In this example we will create a 13.2-RELEASE bootstrap

```sh
# appjail fetch
```
#### Create a virtualnet
Create a virtualnet for add wazuh jail to it from wazuh-makejail

```sh
# appjail network add wazuh-net 10.0.0.0/24
```
it will create a bridge named wazuh-net in where wazuh jail epair interfaces will be attached. By default wazuh-makejail will use NAT for internet outbound. Do not forget added a pass rule to /etc/pf.conf because wazuh-makefile will try to download and install packages and some another resources for configuration of wazuh services

```sh
pass out quick on wazuh-net inet proto { tcp udp } from 10.0.0.2 to any
```
#### Create a lightweight container system
Create a container named wazuh with a private IP address 10.0.0.2. Take on mind IP address must be part of wazuh-net network

```sh
# appjail makejail -f gh+alonsobsd/wazuh-makejail -j wazuh -- --network wazuh-net --server_ip 10.0.0.2
```

When it is done you will see credentials info for connect to wazuh-dashboards via web browser and one password to agent enrollment.

```sh
################################################ 
 Wazuh dashboard admin credentials                
 Hostname : https://jail-host-ip:5601/app/wazuh   
 Username : admin                                 
 Password : @hkXudpIp93xbIOvD                        
################################################
 Wazuh agent enrollment password                
 Password : @sXDudSIKJKfMTmCroHGvirVPE80=
################################################
 ```
Keep it to another secure place

## License
This project is licensed under the BSD-3-Clause license.
