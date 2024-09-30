<!-- omit in toc -->
# system scripts 🇸🇨

different script for system setup

<!-- omit in toc -->
## contents

- [setup console tools](#setup-console-tools)
- [setup workstation](#setup-workstation)
- [setup xorg](#setup-xorg)

## setup console tools

activate doas without password

```sh
setup_console.sh --doas_pwd
```

activate keyboard layout

```sh
setup_console.sh --kbd_layout
```

activate keyboard shortcuts

```sh
setup_console.sh --kbd_shortcuts
```

sshd weaken security

```sh
setup_console.sh --sshd_weaken
```

activate autologon

```sh
setup_console.sh --set_autologon
```

install tcbsd tools

```sh
setup_console.sh --tools_tcbsd
```

install freebsd tools

```sh
setup_console.sh --tools_freebsd
```

## setup workstation

setup workstation with tools

```sh
setup_workstation.sh
```

## setup xorg

setup xorg only with chromium

```sh
setup_xorg.sh --install_chrome
```

setup xorg owith kde

```sh
setup_xorg.sh --install_kde
```
