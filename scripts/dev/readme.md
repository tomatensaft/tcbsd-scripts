## dev(ice) tools


### mount devices

mount nfs file system
``` 
./nfs_mount.sh --mount /dev/da0s1"
``` 

mount usb file system
``` 
./usb_mount.sh --mount /dev/da0s1
``` 

### zfs

create zfs file system - adjust partitions in .sh file
``` 
./setup_zfs_raid.sh (option)
``` 