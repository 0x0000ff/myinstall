#!/bin/sh

sudo cp /boot/vmlinuz-linux /boot/efi/efi/arch/vmlinuz-linux.efi
sudo cp /boot/initramfs-linux.img /boot/efi/efi/arch
efibootmgr --disk /dev/mmcblk0 --part 1 --create --label "Arch" --loader "EFI\arch\vmlinuz-linux.efi" --unicode 'root=/dev/mmcblk1p1 rw initrd=\efi\arch\initramfs-linux.img apparmor=1  initcall_debug printk.time=y init=/usr/bin/bootchartd2 security=apparmor' --verbose 
