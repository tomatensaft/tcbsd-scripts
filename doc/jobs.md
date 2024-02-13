## jobs


### job commands

list jobs
```
jobs
jobs -p (pid)
```

start job in the background - &
```
execute_script.sh &
```

put ob in the foreground
```
fg %1 (jobnumber)
```

put ob in the background
```
bg %1 (jobnumber)
```

stop job
```
stop %1 (jobnumber)
```

kill all jobs
```
kill -9 $(jobs -p)
```

start program in foreground and hit `CTRL + Z`
```
jobs
fg %1 (jobnumber)
```

### at - execute jobs

#### configuration file `/etc/cron.d/at`

execute at a specific time
```
at -f /home/youscript.sh 1200
```

execute at a specific date and time
```
at -t 11102344 -f /home/youscript.sh 1200
```

list queued jobs
```
at -l
atq
```

remove queued jobs
```
at -r (jobid)
atrm (jobid)
```

### cron

#### use `/etc/cron.d/` folder and shell scripts

edit users crontab settings
```
crontab -e
```

execution samples
```
SHELL=/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin
HOME=/var/log
#
#minute (0-59)
#|   hour (0-23)
#|   |    day of the month (1-31)
#|   |    |   month of the year (1-12 or Jan-Dec)
#|   |    |   |   day of the week (0-6 with 0=Sun or Sun-Sat)
#|   |    |   |   |   commands
#|   |    |   |   |   |
#### rotate logs weekly (Sunday at midnight)
00   0    *   *   0   /usr/local/bin/test.sh
```