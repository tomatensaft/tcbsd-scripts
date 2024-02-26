## network examples
network examples for different options

### extract mac/ip
script to extract mac and ip address
``` 
extract_MacIp.sh
``` 

### ssmtp mail client
send mail with ssmtp
``` 
setup_mail_ssmtp.sh --setup ./conf/setup_mail_ssmtp.conf

setup_mail_ssmtp.sh --testmail mail@address.com
```

### mut gmail client
send gmail with token - generate at gmail
``` 
setup_mail_mutt.sh --setup ./conf/setup_mail_mutt.conf

setup_mail_mutt.sh --testmail mail@address.com
``` 

### send telegram message
send telegram message with curl - bottoken and chatid configurable in script
``` 
setup_telegram_msg.sh Testmessage [configfile]

``` 

### scan nmap
nmap examples
``` 
scan_nmap.sh --ip-port xx.xx.xx.xx 80 8080

scan_nmap.sh --ip-range xx.xx.xx.*

scan_nmap.sh --os xx.xx.xx.xx
``` 

### ncat send/receive tcp data
ncat examples
``` 
ncat_tcp_data.sh --listen xx.xx.xx.xx 6000

ncat_tcp_data.sh --send xx.xx.xx.xx 60000 Data
``` 

### tcpdump
tcpdump examples
``` 
scan_tcpdump.sh --start em0
``` 

### setup dhcp server
setup dhcp
``` 
setup_dchp_srv.sh em0
``` 

### setup nfs server
setup nfs
``` 
setup_nfs_srv.sh nfsfolder
``` 

### packetfiler
enable packetfilter
``` 
setup_pf.sh
``` 

### setup wlan interface
setup wlan interface
``` 
setup_wifi_if.sh em0 MySSID MyPSK
``` 

### setup wlan hotspot
setup wlan accesspoint
``` 
setup_wifi_ap.sh em0 MySSID MyPSK
``` 

### wireguard
setup wireguard vpn for local instance
``` 
setup_wireguard.sh
``` 
