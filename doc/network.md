## network infos


### ip aqddress

set ip address console
``` 
ifconfig em0 inet 192.168.3.4 255.255.255.0
ifconfig em0 inet 192.168.3.4/24
```
in `rc.conf`
```
ifconfig_igb1="inet 192.168.5.7 netmask 255.255.255.0" 
ifconfig_em0="DHCP
```

multiple ip addresses
```
ifconfig em0 inet alias 192.168.3.10/24
```
in `rc.conf`
```
ifconfig_em0_alias0="inet 192.168.3.10/24"
```

### dns naming

configuration exmaples for `resolv.conf`
```
search lan                      
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 192.168.1.254
name_servers="8.8.8.8 8.8.4.4"  
```

generate resolv.conf
```
resolvconf -ugenerate resolv.conf
```

### interface

interface naming
```
ifconfig em1 name test1
```
in `rc.conf`
```
ifconfig_em1_name="test1"
```


cloning / virtual interfaces in `rc.conf`
```  
cloned_interfaces="tap0"
ifconfig_tap0="inet 192.168.5.7 netmask 255.255.255.0"
```

### network routes

different route examples
``` 
route add default 192.168.1.1
route add -net 192.168.2.0/24 192.168.1.2
defaultrouter="192.168.1.1"         -> entry rc.conf
static_routes="internalnet2"
route_internalnet2="-net 192.168.2.0/24 192.168.1.2"
static_routes="net1 net2"
route_net1="-net 192.168.0.0/24 192.168.0.1"
route_net2="-net 192.168.1.0/24 192.168.1.1"
```

default gateway in `rc.conf`
```
gateway_enable="YES"
```

network service `start` `stop` `restart`  
```
service netif restart
```

example vlan interface
```
ifconfig interface.tag create vlan tag vlandev interface
ifconfig em0.2 create vlan 2 vlandev em0
ifconfig em0.2 inet 192.168.3.4/24
ifconfig em0.2 create vlan 2 vlandev em0 inet 192.168.3.4/24
vlans_em0="2 3"                     -> entry rc.conf
ifconfig_em0_2="inet 192.168.56.4/28"
ifconfig_em0_3="inet 198.45.3.2/24"
ifconfig_em0="up"
```

### packetfilter

some simple examples
```
pass in quick proto tcp to port 48898 synproxy state
pass in quick proto tcp to port 502 keep state
table <intranet> { 192.168.0.0/24, 192.168.1.0/24, !192.168.0.1 }
```

short description
```   
pass on                             -> in/out-going data traffic
pass in                             -> in-going data traffic
pass out                            -> out-going data traffic
quick                               -> next rules will be ignored
keep state                          -> established connection will not be checked anymore
tables                              -> save more ip addresses / ip ranges
```

simple pf config `~/etc/pf.conf`
``` 
### INTERFACES ###
if = "{ lo0, rl0 }"

### SETTINGS ###
set block-policy drop

### OFFENE TCP/UDP-PORTS ###
tcp_pass = "{ 53 2031 }"
udp_pass = "{ 53 2031 }"
icmp_types = "echoreq"

### NORMALISATION ###
scrub in all
antispoof for $if

### TABLES ###
table <intranet>   { 192.168.0.0/24 }
table <bruteforce> persist

### RULES ###
set skip on lo0
block all
block quick from <bruteforce>
pass in quick from <intranet> to any keep state
pass in on $if proto tcp from any to any port $tcp_pass flags S/SA keep state (max-src-conn 100, max-src-conn-rate 15/5, overload <bruteforce> flush global)
pass in on $if proto udp to any port $udp_pass keep state
pass out quick all keep state

# PING #
pass in on $if inet proto icmp all icmp-type $icmp_types keep state

# TRACEROUTE #
pass in on $if inet proto udp from any to any port 33433 >< 33626 keep state
``` 

### tcpdump

some command examples
```
tcpdump -D
tcpdump -i ens3
tcpdump -i 2 "port http"
tcpdump -i 2  port http -v
tcpdump -i 2  port http -vvv
tcpdump -i 2  "port http" -ASCII
tcpdump -i 2  "port http" -X
tcpdump -i 2  port http -q -n

tcpdump -i 2  tcp
tcpdump -i 2  udp
tcpdump -i 2  icmp
tcpdump -i 2  arp
tcpdump -i 2  ip

tcpdump -i 2  dst google.com
tcpdump -i 2  portrange 70-90
```


### netstat

netstat examples
```
netstat -w 5 -d

netstat -na -f inet

netstat -m #Mem
```

### sockstat

sockstat examples
```
sockstat -4
```

### hping3 for test purposes

hping3 code examples
```
hping3 -c 15000 -d 120 -S -w 64 -p 8080 --flood --rand-source xx.xx.xx.xx

hping3 -c 15000 -d 120 -S -w 64 -p 8080 --flood -a zz.zz.zz.zz xx.xx.xx.xx

hping3 -a zz.zz.zz.zz xx.xx.xx.xx -S -q -p 8080

hping3 -S — scan 21–500 xx.xx.xx.xx

hping3 -S -p 80 xx.xx.xx.xx — flood

hping3 — icmp — flood xx.xx.xx.xx

hping3 --syn --flood --rand-source --destport 443 xx.xx.xx.xx

hping3 --icmp --spoof xx.xx.xx.xx yy.yy.yy.yy

doas hping3 -S xx.xx.xx.xx -p 8080 -c 15000

hping3 -S xx.xx.xx.xx -p 8080 -c 1

```



### links 
[OpenBSD pf](https://www.openbsdhandbook.com/pf/anchors/)
[Dummynet Bridge](https://lists.freebsd.org/pipermail/freebsd-ipfw/2006-July/002549.html)