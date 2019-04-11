#!/bin/sh

# Disk Partitioning and mount
lsblk
read -p "Installation Device: " HARDDRIVE
sudo gdisk $HARDDRIVE
read -p "Install Partition Number: " PARTNO
sudo mkfs.btrfs -f $HARDDRIVE$PARTNO
#sudo tune2fs -O encrypt /dev/sda1
sudo mount $HARDDRIVE$PARTNO /mnt

# Download verify and install bootstrap
curl -O http://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz
curl -O http://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz.sig
curl -O http://mirror.rackspace.com/archlinux/iso/latest/md5sums.txt
curl -O http://mirror.rackspace.com/archlinux/iso/latest/sha1sums.txt
gpg --keyserver pgp.mit.edu --keyserver-options auto-key-retrieve --verify archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz.sig
md5sum -c md5sums.txt
sha1sum -c sha1sums.txt
sleep 5s
sudo tar -xzvf archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz -C /mnt
sudo mv /mnt/root.x86_64/* /mnt
sudo cp postinstall.sh /mnt
sudo mkdir /boot/efi

sed 's/COMPRESSION="gzip"/#COMPRESSION="gzip"/' /mnt/etc/mkinitcpio.conf
sed 's/#COMPRESSION="lz4"/COMPRESSION="lz4"/' /mnt/etc/mkinitcpio.conf
read -p "Hostname: " $MYHOSTNAME
echo $MYHOSTNAME > /mnt/etc/hostname
echo 127.0.0.1 localhost >> /mnt/etc/hosts
echo ::1 localhost >> /mnt/etc/hosts
echo 127.0.1.1 $MYHOSTNAME.localdomain $MYHOSTNAME >> /mnt/etc/hosts
sudo vim /mnt/etc/pacman.d/mirrorlist

# Chroot
sudo mount --bind /mnt /mnt
cd /mnt
sudo cp /etc/resolv.conf /mnt/etc
sudo mount -t proc /proc proc
sudo mount --make-rslave --rbind /sys sys
sudo mount --make-rslave --rbind /dev dev
sudo mount --make-rslave --rbind /run run    # (assuming /run exists on the system)
sudo cat << EOF | sudo chroot /mnt /bin/bash


# Base Config
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
echo KEYMAP=uk > /etc/vconsole.conf

vi /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate archlinux
pacman -Syy

# Base Packages
echo -ne '\n' | pacman -S --noconfirm git base base-devel elinks efibootmgr bluez wpa_supplicant openvpn connman dialog grub os-prober efibootmgr e2fsprogs

# Mate Packages 
echo -ne '\n' | pacman -S gnome

read -p "EFI Partition: " $BOOTPART
mkdir /boot/efi
mount /dev/$BOOTPART
mkdir /boot/grub
grub-mkcfg -o /boot/grub/grub.cfg
grub-install --directory=/boot/grub/efi --target=x86_64-efi
EOF

