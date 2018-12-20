#/bin/sh
mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y-%m)

# Disk Partitioning and mount
lsblk
read -p "Installation Device: " HARDDRIVE
if [[ $LOKIE == y ]]; then gdisk $HARDDRIVE; fi
read -p "Install Partition Number: " PARTNO
mkfs.btrfs -O {FEATURES} $HARDDRIVE$PARTNO
mount $HARDDRIVE$PARTNO /mnt

# Download verify and install bootstrap
curl -O http://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz
curl -O http://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-$(date +%Y.%m).01-x86_64.tar.gz.sig
curl -O http://mirror.rackspace.com/archlinux/iso/latest/md5sums.txt
curl -O http://mirror.rackspace.com/archlinux/iso/latest/sha1sums.txt
gpg --keyserver pgp.mit.edu --keyserver-options auto-key-retrieve --verify archlinux-$(date + %Y.%m).01-x86_64.tar.gz.sig
md5sum -c md5sums.txt
sha1sum -c sha1sums.txt
tar -xzvf archlinux-bootstrap-$(date +%Y-%m).01-x86_64.tar.gz -C /mnt
cp postinstall.sh /mnt

# Chroot
arch-chroot /mnt

# Base Config
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
echo KEYMAP=uk > /etc/vconsole.conf
read -p "Hostname: " $MYHOSTNAME
echo $MYHOSTNAME > /etc/hostname
echo 127.0.0.1 localhost >> /etc/hostname
echo ::1 localhost >> /etc/hostname
echo 127.0.1.1 $MYHOSTNAME.localdomain $MYHOSTNAME >> /etc/hostname

# Base Packages
echo -ne '\n' | pacman -S --noconfirm git base-devel elinks efibootmgr bluez wpa_supplicant openvpn connman dialog

# Mate Packages 
echo -ne '\n' | sudo pacman -S --noconfirm mate xorg mate-media mate-power-manager system-config-printer blueman arc-gtk-theme arc-icon-theme mate-utils eom

# Username and Password
read -p "Username: " MYNAME
mkdir /home/$MYNAME
useradd -d /home/$MYNAME -g wheel $MYNAME -s /postinstall.sh
passwd
exit
