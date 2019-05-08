# Fedora Remix for Macbook Pro 14,1 (based on Fedora version 27-30)

This is a small repo to capture my work in automating the creation of a Fedora
*Remix* Installer that doesn't crash on recent Macbook Pro releases.

It creates a Fedora *Remix* ISO that talks, walks and kicks ass like the
original, without branding or affiliation with Fedora (beyond being a Remix).

More on Remixes here (note it's not a spin):

https://fedoraproject.org/wiki/Remix

# Work in progress notes:

## macbookpro14_fedora

Working:
- Display
- Keyboard (including backlight)
- Trackpad
- Triple boot


## Keyboard
Backlight:

```
[root@sage ~]# cat /sys/class/leds/spi\:\:kbd_backlight/max_brightness 
255
[root@sage ~]# 
[root@sage ~]# cat /sys/class/leds/spi\:\:kbd_backlight/brightness 
0
[root@sage ~]# 
[root@sage ~]# echo 255 > /sys/class/leds/spi\:\:kbd_backlight/brightness 
[root@sage ~]# cat /sys/class/leds/spi\:\:kbd_backlight/brightness 
255
[root@sage ~]# 
```


## Triple Boot
```
[root@sage ~]# fdisk -l /dev/nvme0n1
Disk /dev/nvme0n1: 233.8 GiB, 251000193024 bytes, 61279344 sectors
Units: sectors of 1 * 4096 = 4096 bytes
Sector size (logical/physical): 4096 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: redacted

Device            Start      End  Sectors   Size Type
/dev/nvme0n1p1        6    76805    76800   300M EFI System
/dev/nvme0n1p2    76806 14884095 14807290  56.5G unknown
/dev/nvme0n1p3 14884096 41129217 26245122 100.1G Microsoft basic data
/dev/nvme0n1p4 41129472 41355263   225792   882M Windows recovery environment
/dev/nvme0n1p5 41355264 41406463    51200   200M EFI System
/dev/nvme0n1p6 41406464 41457663    51200   200M Apple HFS/HFS+
/dev/nvme0n1p7 41457664 41719807   262144     1G Linux filesystem
/dev/nvme0n1p8 41719808 61279231 19559424  74.6G Linux filesystem
[root@sage ~]# 
```

## APFS Fuse

Mount recent MacOS encrypted volumes with apfs-fuse:
https://github.com/sgan81/apfs-fuse

`yum install apfs-fuse`

```
[root@sage ~]# apfs-fuse /dev/nvme0n1p2 /mnt/tmp/
Volume MacOS is encrypted.
Enter Password: 
[root@sage ~]# 
```
