## jail templates

### init jail system

init once jail system from configfile (network/zfs) - reboot required
``` 
doas ./setup_jail_guest.sh --init ./conf/jail_standard.conf
``` 

### usage bsd jails

create jail from configfile
``` 
doas ./setup_jail_guest.sh --create ./conf/jail_standard.conf
``` 

install software in jail from configfile
``` 
doas ./setup_jail_guest.sh --add_sw ./conf/jail_standard.conf
``` 

clean jail data
``` 
doas ./setup_jail_guest.sh --clean
``` 

### usage linux jails

alpine linux - no additional software
``` 
doas ./setup_jail_guest.sh --create ./conf/jail_alpine_linux.conf
``` 

devuan linux - debootstrap required
``` 
/usr/local/etc/pkg/repos/FreeBSD.confFreeBSD: { enabled: yes }
pkg install debootstrap

doas ./setup_jail_guest.sh --create ./conf/jail_devuan_linux.conf
``` 