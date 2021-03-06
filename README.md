# Dashboard

Super fancy Raspberry Pi based infotainment system for my car

![Preview](https://i.imgur.com/lRQowhB.png)

## Global setup on the Pi

Change the hostname of the Pi to whatever you want:

`$ sudo raspi-config`

Change the password for user Pi:

`$ sudo passwd pi`

Enable SSH, I2C and serial port and **disable the serial console**:

`$ sudo raspi-config`

Create the log directory:

`$ mkdir ~/logs`

Copy the required configuration:

```console
$ mkdir -p ~/.config/autostart/
$ cp config/dashboard.desktop ~/.config/autostart/
$ cp config/start.sh ~/
```

## Remove the junk

```console
$ sudo apt remove idle*
$ sudo apt remove scratch*
$ sudo apt remove libreoffice*
$ sudo apt remove sonic-pi
$ sudo apt remove python3-thonny
$ sudo apt remove minecraft-pi
$ sudo apt remove debian-reference-*
```

```console
$ rm -rf python_games
```

```console
$ sudo apt autoremove
```

## Install useful stuff

```console
$ sudo apt install matchbox-keyboard
$ sudo apt install cmake
$ sudo apt install libgl-dev
```

## Faster boot and operation

Edit /boot/config.txt, add

`dtoverlay=sdtweak,overclock_50=100

## Black screen until app is started

This allows the desktop to be hidden during a normal start sequence be to still be readily accessible if the dashboard is stopped.

Edit `/boot/config.txt`, add

`disable_splash=1`

Run

```console
$ sudo systemctl mask plymouth-start.service
```

Add this to the end of the line on `/boot/cmdline.txt`

`quiet loglevel=3 logo.nologo vt.global_cursor_default=0`

Create a delay script for the taskbar

```console
$ mkdir -p ~/.config/lxsession/LXDE-pi
$ cp config/delaytaskbar.sh ~/.config/lxsession/LXDE-pi/delaytaskbar.sh
$ cp config/autostart ~/.config/lxsession/LXDE-pi/
```

Reboot
