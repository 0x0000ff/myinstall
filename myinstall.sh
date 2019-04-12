#!/bin/sh
sudo add-apt-repository multiverse
sudo apt update
sudo apt install curl arch-install-scripts

# Disk Partitioning and mount
lsblk
read -p "Installation Device: " HARDDRIVE
sudo gdisk $HARDDRIVE
read -p "Install Partition Number: " PARTNO
echo '-writing new filesystem'
sudo mkfs.btrfs -f -n 64K $HARDDRIVE$PARTNO

echo '-mounting filesystem'
sudo mount $HARDDRIVE$PARTNO /mnt

lsblk
read -p "EFI Partition: " BOOTPART 
mkdir -p /mnt/boot/efi
mount $BOOTPART /mnt/boot/efi

# Download verify and install bootstrap
echo '-fetching bootstrap and keys'
curl -O http://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz
curl -O http://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz.sig
curl -O http://mirror.rackspace.com/archlinux/iso/latest/md5sums.txt
curl -O http://mirror.rackspace.com/archlinux/iso/latest/sha1sums.txt

echo '-verifying keys'
gpg --keyserver pgp.mit.edu --keyserver-options auto-key-retrieve --verify archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz.sig
md5sum -c md5sums.txt
sha1sum -c sha1sums.txt
sleep 5s

echo '-extracting bootstrap'
sudo tar -xzvf archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz -C /mnt
sudo mv /mnt/root.x86_64/* /mnt
sudo cp postinstall.sh /mnt
sudo cp postinstall-gnome.sh /mnt
sudo mkdir /boot/efi

echo '-setting network'
read -p "Hostname: " $MYHOSTNAME
echo $MYHOSTNAME > /mnt/etc/hostname
echo 127.0.0.1 localhost >> /mnt/etc/hosts
echo ::1 localhost >> /mnt/etc/hosts
echo 127.0.1.1 $MYHOSTNAME.localdomain $MYHOSTNAME >> /mnt/etc/hosts
sudo vi /mnt/etc/pacman.d/mirrorlist
genfstab -U /mnt >> /mnt/etc/fstab

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
echo LANG=en_GB.UTF-8 > /etc/locale.conf
locale-gen
echo KEYMAP=uk > /etc/vconsole.conf

vi /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate archlinux
pacman -Syy

# Base Packages
echo -ne '\n' | pacman -S --noconfirm base base-devel elinks efibootmgr bluez wpa_supplicant openvpn dialog grub efibootmgr e2fsprogs lz4 git

lsblk
mkdir /boot/grub
sed 's/COMPRESSION="gzip"/#COMPRESSION="gzip"/' /etc/mkinitcpio.conf
sed 's/#COMPRESSION="lz4"/COMPRESSION="lz4"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/grub/efi bootloader-id=GRUB

EOF

