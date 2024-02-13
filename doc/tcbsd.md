## useful tcbsd information


### tc system service

tc system servive tool
``` 
TcSysExe.exe 
``` 

tc system service options
``` 
--osImageVersion
--platformId
--netID
--fingerprint
--mode
--run
--config 
``` 

### tc realtime ethernet

show ethernet realtime settings
```      
TcRteConfig show
``` 

disable realtime ethernet
``` 
TcRteConfig disable igb.1
``` 


### tc core

show actual core configuration
```   
TcCoreConf
``` 

### restorepoints / snapshots

create restorepoint
``` 
restorepoint create your-restorepoint
``` 

list restorepoints
``` 
restorepoint status
``` 

rollback restorepoints
``` 
restorepoint rollback    
restorepoint rollback factoryreset 
``` 

    
### backupscript
``` 
sh -c “TcBackup.sh --disk /dev/ada0 > backup.bckp”
sh -c "TcBackup.sh --disk /dev/ada1 < backup.bckp”
``` 

### ads logger

ads logger
``` 
    tcamslog -c -r -s 20 -f testlog
``` 

ads logger options
``` 
(l)isten, (p)ort, (c)apture, (f)ile, (d)ir, (s)ize, (r)ingpuffer
``` 

### tc registry

change net id and registry parameters
``` 
    /usr/local/etc/TwinCAT/3.1/TcRegistry.xml
``` 

### ads router

add ads route from console
``` 
ads 192.168.0.231 addroute --addr=192.168.0.1 --netid=192.168.0.1.1.1 --password=1 --routename =example.beckhoff.com
``` 
