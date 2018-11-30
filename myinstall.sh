#/bin/sh

# Base Install and chroot
timedatectl set-ntp true
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Base Config
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
echo KEYMAP=uk > /etc/vconsole.conf
echo Gemini > /etc/hostname
echo 127.0.0.1 localhost >> /etc/hostname
echo ::1 localhost >> /etc/hostname
echo 127.0.1.1 myhostname.localdomain myhostname >> /etc/hostname
#'/base udev/base udev plymouth/'
#'/MODULES=()/MODULES=(i915)/'

# Base Packages
echo -ne '\n' | pacman -S --noconfirm git base-devel elinks efibootmgr bluez wpa_supplicant openvpn connman dialog

# Mate Packages 
echo -ne '\n' | sudo pacman -S --noconfirm mate xorg mate-media mate-power-manager system-config-printer blueman arc-gtk-theme arc-icon-theme mate-utils eom

#Mate Config
gsettings set org.mate.Marco.general compositing-manager true
gsettings set org.mate.Marco.general allow-tiling true

# AUR Packages
mkdir packages

git clone https://aur.archlinux.org/plymouth.git; cd plymouth
makepkg -si --noconfirm 
systemctl disable lightdm.service
systemctl enable lightdm-plymouth.service
cd ..

git clone https://aur.archlinux.org/snapd.git; cd snapd
makepkg -si --noconfirm
systemctl enable apparmor.service
systemctl enable snapd.apparmor.service
cd ..

git clone https://aur.archlinux.org/connman-gtk.git; cd connman-gtk
makepkg -si --noconfirm
systemctl disable netctl
systemctl enable connman
cd ..

# Kernel and Ramdisk

#boot entry for sd boot
efibootmgr --disk /dev/mmcblk0 --part 1 --create --label "Arch" --loader "EFI\arch\vmlinuz-linux.efi" --unicode 'root=/dev/mmcblk1p1 rw initrd=\efi\arch\initramfs-linux.img apparmor=1 security=apparmor quiet splash' --verbose
 
# Username and Password
passwd
