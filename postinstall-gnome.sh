# Username and Password
read -p "Username: " MYNAME
mkdir /home/$MYNAME
useradd -d /home/$MYNAME -g wheel $MYNAME -s /postinstall.sh
passwd

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

sed 's/base udev/base udev plymouth/' /etc/mkinitcpio.conf
sed 's/MODULES=()/MODULES=(i915)/' /etc/mkinitcpio.conf
sed 's/#write-cache/write-cache/' /etc/apparmor/parser.conf
sed 's/GRUB_TIMEOUT=[0-9]/#GRUB_TIMEOUT=5/' /etc/default/grub
sed 's/#GRUB_HIDDEN_TIMEOUT/GRUB_HIDDEN_TIMEOUT/' /etc/default/grub
sed 's/GRUB_HIDDEN_TIMEOUT=[0-9]/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
sed 's/#GRUB_HIDDEN_TIMEOUT_QUIET/GRUB_HIDDEN_TIMEOUT_QUIET/' /etc/default/grub
sed 's/GRUB_CMDLINE_DEFAULT=/&"quiet apparmor=1 security=apparmor"' /etc/default/grub

rm /postinstall.sh
