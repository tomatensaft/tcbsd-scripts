## filesystem infos

### geom - geometric partitioning

list disks
```
geom disk list
```

### gpart - partitioning

show partitions
```
gpart show
gpart show -l daX
```

delete/destroy partitions `-F` force
``` 
gpart delete -i 2 adaX
gpart destroy daX
gpart destroy -F daX
```

create paritions `-s` gpt/mbr sheme
```
gpart create -s gpt daX 
```

add partitions
```
gpart add -a 1m -t freebsd-swap -s 8g -l swap daX 
gpart add -t freebsd-boot -l boot -s 512K daX -l Label
gpart add -a 1m -t freebsd-ufs 5g -l root daX
gpart add -a 1m -t freebsd-ufs 5g -l tmp daX
gpart add -a 1m -t freebsd-ufs 100g -l var daX
gpart add -a 1m -t freebsd-ufs -l usr daX
```

resize parition
```
gpart resize -i 6 -s 100g -a 1m daX 
```

modify/change partitions
```
gpart modify -i 2 -l rootfs vtbdX
gpart modify -i 2 -t freebsd-zfs vtbdX
```

### uefi - partitioning

create partition for uefi loader
```
gpart create -s gpt daX
gpart add -t efi 800K daX
dd if=/boot/boot1.efidat of=/dev/daXpY    
```

### ufs - unix file system

```
newfs /dev/gpt/var
newfs -L var /dev/adaXsYd
tunefs tuning
growfs growing
mksnap_ffs .sanp/bevoreupgrade
fsck check filesystem
```

### zfs - zettabyte filesystem

list datasets
```
zfs list
```

set quota limit
```
zfs set qutota=2G zroot/usr/home
```

get mountstatus
```
zfs get mounted zroot/ROOT
```

get compression info
```
zfs get Compression
```

example zfs create
```
zfs create zroot/usr/local
zfs create -o canmount=off zroot/var/db/
zfs create zroot/var/db/sql
zfs create zroot/var/db/sql/dataset
chown -R sql:sql /var/db/sql

zfs create zroot/usr/local/sql-new
tar cfC - /usr/local/sql . | tar xpfC - /usr/local/sql-new
mv /usr/local/sql /usr/local/sql-old
zfa rename zroot/use/local/sql-new zroot/usr/local/sql

zfs destroy zroot/usr/local
zfs rename zroot/use/local zroot/use/new-local
```

create snapshot
```
zfs snapshot zroot/usr/home@2020-0101-00-00-00
zfs list -t snapshot
zfs destroy zroot/usr/home@2020-0101-00-00-00
```

 ### zpool - virtual storage pool

list zpools
```
zpool list
```

status zpools
```
zpool status jail
zpool get all zroot
zpool get readonly
```

create zpool
```
zpool create db mirror gpt/zfs3 gpt/zfs4 mirror
zpool create scratch gpt/zfs3 gpt/zfs4 striped
zpool create db raidz gpt/zfs3 gpt/zfs4 gpt/zfs5 raidz
```

destroy zpool
```
zpool destroy db
```

clean zpool
```
zpool scrub zroot
zpool scrub -s zroot cancel
```

switch zpool on/offline
```
zpool online 12345 guid
zpool offline db gpt/zfs6
```

replace parition of zpool
```
zpool replace db gpt/zfs3 gpt/zfs6
```

### beadm/bectl - boot environments

list boot env
```
beadm list
```

create boot env
```
beadm create 2020-01-01-00-00-00
```

activate boot env
```
beadm activate 2020-01-01-00-00-00
```

destroy boot env
```
beadm destroy 2020-01-01-00-00-00
```

mount with different types `msdosfs` `cd9669` `udf` `ext2fs` `ext3fs`
``` 
mount -t msdosfs
```

### disk state

free storage `-h` human readable
``` 
df -h 
```

### images

create file images
```  
truncate -s 1G fielsystem.file
mdconfig -a -t vnode -f filesystem.file
newfs -j /dev/md0 create UFS filesystem
```

### flags - disk state

`noschg` wirte protection / `-R` remove
``` 
chflags -R noschg
```