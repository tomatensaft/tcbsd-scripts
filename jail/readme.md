<!-- omit in toc -->
# jail templates ⚓

jail templaes for easy cration of different jails

<!-- omit in toc -->
## contents

- [init](#init)
- [usage bsd jails](#usage-bsd-jails)
- [usage linux jails](#usage-linux-jails)

## init

init once jail system from configfile (network/zfs) - reboot required

```sh
doas ./setup_jail_guest.sh --init ./conf/jail_standard.conf:
```

## usage bsd jails

create jail from configfile

```sh
doas ./setup_jail_guest.sh --create ./conf/jail_standard.conf
```

install software in >jail from configfile

```sh
doas ./setup_jail_guest.sh --add_sw ./conf/jail_standard.conf
```

clean jail data

```sh
doas ./setup_jail_guest.sh --clean
```

## usage linux jails

alpine linux - no additional software

```sh
doas ./setup_jail_guest.sh --create ./conf/jail_alpine_linux.conf
```

devuan linux - debootstrap required

```sh
/usr/local/etc/pkg/repos/FreeBSD.confFreeBSD: { enabled: yes }
pkg install debootstrap

doas ./setup_jail_guest.sh --create ./conf/jail_devuan_linux.conf
```
