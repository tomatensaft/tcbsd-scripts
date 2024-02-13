## useful system information

### boot messages
``` 
dmseg  
var/run_demseg.boot
``` 


### importand files

enable/disable system service and daemons
``` 
rc.conf
``` 

tunables that can be set only at boot time
``` 
loader.conf
``` 

tunable that can be set at any time
```                    
sysctl.conf
``` 

safely add rc.conf parameter
``` 
sysrc                  
``` 

kernel state read/write
``` 
sysctl  
``` 

view libraries
``` 
ldconfig -r
``` 

check rc.conf
``` 
sh /etc/rc.conf
``` 


### script debug

start debug
``` 
set -x
``` 

stop debug
``` 
set +x
``` 


### rescue singleuser boot

mount zroot for writing
``` 
zfs mount –a 
zfs set readonly=off zroot/ROOT/default
``` 


### rights executebales

change mode
``` 
chmod -R 755 /tmp
``` 


### pci - tools

scan pci bus
``` 
pciscan -lv
``` 

### shell 

change shell
```  
chsh –s tcsh
``` 


### compression archives

extract `-x`
```  
tar -xzvf
tar -xvf  
``` 

create `-c`
``` 
tar -cfz
tar -cfv
``` 

list `-t`
``` 
tar -tvf
``` 

unzip archive
``` 
unzip
``` 


### package system

update meta data
``` 
    pkg update
```     

upgrade system `-n` see changes
``` 
pkg upgrade
pkg upgrade -n                      
``` 

list installes packages
``` 
pkg info
```     

install package
``` 
pkg install XY
```   

deinstall package
``` 
pkg delete XY
```  

clean pkg cache
```
pkg clean 
```    

install offline package
```
pkg add XY 
```     

search package in cache
```
pkg search 
``` 
   
package query
```
pkg query
    %n - Package name
    %o - Port Package
    %v - version
    %c - comment

```

package query example for non automatic packages
```
pkg query -e '%a = o' %n
```   

remove unused dependecies   
 ```        
    pkg autoremove
 ``` 

lock package for update   
``` 
pkg lock
```

list locked packages
``` 
pkg lock -l             
```   

unlock packages
``` 
    pkg unlock
``` 

display local package location
``` 
pkg which
```    

check checksum of package
``` 
    pkg check
``` 


### devices

ata style
``` 
/dev/ada*
``` 

scsi / usb 
``` 
/dev/da*
``` 

cd
``` 
/dev/cd*
```

access to the camcontrol subsystem
```
camcontrol devlist
```


### logging

log messages
```
    /var/log/messages
```

security messages
```
    /var/log/security
```


### startprocess

boot kernel
```
kernel
```

bootstrap
```
loader
```   
   
process control init  
```
init
```

runlevel control
```
rc
```

terminal login
```
getty
```  


### cron

edit ctrotab
```
crontab -e
```   
