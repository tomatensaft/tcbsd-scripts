## system script
different script for system setup

### setup console tools
activate doas without password
``` 
setup_console.sh --doas_pwd
``` 

activate keyboard layout
``` 
setup_console.sh --kbd_layout
``` 

activate keyboard shortcuts
``` 
setup_console.sh --kbd_shortcuts
``` 

sshd weaken security
``` 
setup_console.sh --sshd_weaken
``` 

activate autologon
``` 
setup_console.sh --set_autologon
``` 

install tcbsd tools
``` 
setup_console.sh --tools_tcbsd
``` 

install freebsd tools
``` 
setup_console.sh --tools_freebsd
``` 


### setup workstation
setup workstation with tools
``` 
setup_workstation.sh
``` 

### setup xorg
setup xorg only with chromium
``` 
setup_xorg.sh --install_chrome
``` 

setup xorg owith kde
``` 
setup_xorg.sh --install_kde
``` 
