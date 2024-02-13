## rsync infos


### local - copy file to local folder
```  
rsync -azvh --progress archive.tar /tmp/
``` 

### local - sync to two dirs
```    
rsync -arvzh --progress /home/Administrator /home/Administrator/backup/
``` 

### local - sync to two dirs - only update
```  
rsync -au /home/Administrator/repo/ Administrator@192.168.1.xxx:/home/Administrator/repo
``` 

### remote - sync to remote host
```    
rsync -arvh --progress /home/Administrator Administrator@192.168.1.4:/tmp/backup/
rsync -arvhe ssh --progress /home/tech/django/ Administrator@192.168.1.:4/tmp/backup/ 
``` 

### remote - sync from remote host  
``` 
rsync -arvh --progress Administrator@192.168.1.3:/home/Administrator/ /tmp/backup/
rsync -arvhe ssh --progress Administrator@192.168.1.3:/home/Administrator/ /tmp/backup/ 
``` 

### rsync options    
``` 
rsync -avzh --progress --include '.txt' --exclude '.pdf' Administrator@192.168.1.3:/tmp/backup/ /home/Administrator/
rsync -avzhe ssh --max-size='50k' /home/Administrator/ user@192.168.1.4:/tmp/backup/ 
rsync -avzhe ssh --min-size='50k' /home/Administrator/ user@192.168.1.4:/tmp/backup/ 
``` 

### scp copy
``` 
scp -rp Repo Administrator@192.168.1.34:/home/User/Repo-main
``` 