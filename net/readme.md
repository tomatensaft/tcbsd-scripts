<!-- omit in toc -->
# network examples 🚠

network examples for different options

<!-- omit in toc -->
## contents

- [extract mac/ip](#extract-macip)
- [ssmtp mail client](#ssmtp-mail-client)
- [mut gmail client](#mut-gmail-client)
- [send telegram message](#send-telegram-message)
- [scan nmap](#scan-nmap)
- [ncat send/receive tcp data](#ncat-sendreceive-tcp-data)
- [tcpdump](#tcpdump)
- [setup dhcp server](#setup-dhcp-server)
- [setup nfs server](#setup-nfs-server)
- [packetfiler](#packetfiler)
- [setup wlan interface](#setup-wlan-interface)
- [setup wlan hotspot](#setup-wlan-hotspot)
- [wireguard](#wireguard)

## extract mac/ip

script to extract mac and ip address

```sh
extract_MacIp.sh
```

## ssmtp mail client

send mail with ssmtp

```sh
setup_mail_ssmtp.sh --setup ./conf/setup_mail_ssmtp.conf

setup_mail_ssmtp.sh --testmail mail@address.com
```

## mut gmail client

send gmail with token - generate at gmail

```sh
setup_mail_mutt.sh --setup ./conf/setup_mail_mutt.conf

setup_mail_mutt.sh --testmail mail@address.com
```

## send telegram message

send telegram message with curl - bottoken and chatid configurable in script

```sh
setup_telegram_msg.sh Testmessage [configfile]

```

## scan nmap

nmap examples

```sh
scan_nmap.sh --ip-port xx.xx.xx.xx 80 8080

scan_nmap.sh --ip-range xx.xx.xx.*

scan_nmap.sh --os xx.xx.xx.xx
```

## ncat send/receive tcp data

ncat examples

```sh
ncat_tcp_data.sh --listen xx.xx.xx.xx 6000

ncat_tcp_data.sh --send xx.xx.xx.xx 60000 Data
```

## tcpdump

tcpdump examples

```sh
scan_tcpdump.sh --start em0
```

## setup dhcp server

setup dhcp

```sh
setup_dchp_srv.sh em0
```

## setup nfs server

setup nfs

```sh
setup_nfs_srv.sh nfsfolder
```

## packetfiler

enable packetfilter

```sh
setup_pf.sh
```

## setup wlan interface

setup wlan interface

```sh
setup_wifi_if.sh em0 MySSID MyPSK
```

## setup wlan hotspot

setup wlan accesspoint

```sh
setup_wifi_ap.sh em0 MySSID MyPSK
```

## wireguard

setup wireguard vpn for local instance

```sh
setup_wireguard.sh
```
