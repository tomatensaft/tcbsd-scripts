## examples configuration files

## editors

### vi editor mode
* `CTRL+G` move to the end of the file
* `CTRL+F` move to the end of screen
* `CTRL+L` refresh the screen
* `x` delete the charakter at the cursor
* `dd` delete the line at the cursor
* `yy` yank the current line
* `p` put the yanked line below the current line
* `/searchstring` find forward `n` next result
* `?searchstring` find backward `N` previous result

### vi command mode `:` 
* `:wq!` save and quit
* `:r file` read file
* `:w (file)` write file
* `q!` quit without saving
* `:w !sudo tee %` write as user

### vi input mode
* `a` insert char right at the cursor
* `i` insert char left to the cursor
* `o` add a new line after the current line

### setup vi/vim
install vim
``` 
pkg install vim
``` 

vi(m) options  `~/.exrx` `~/.vimrc`
``` 
:set number
``` 