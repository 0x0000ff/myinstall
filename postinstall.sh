
git clone https://aur.archlinux.org/snapd.git; cd snapd
makepkg -si --noconfirm; cd ..
systemctl enable apparmor.service
systemctl enable snapd.apparmor.service


sudo sed -i 's/base udev/base udev plymouth/' /etc/mkinitcpio.conf
sudo sed -i 's/MODULES=()/MODULES=(i915)/' /etc/mkinitcpio.conf
sudo sed -i 's/#write-cache/write-cache/' /etc/apparmor/parser.conf
sudo sed -i 's/GRUB_TIMEOUT=[0-9]/#GRUB_TIMEOUT=5/' /etc/default/grub
sudo sed -i 's/#GRUB_HIDDEN_TIMEOUT/GRUB_HIDDEN_TIMEOUT/' /etc/default/grub
sudo sed -i 's/GRUB_HIDDEN_TIMEOUT=[0-9]/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
sudo sed -i 's/#GRUB_HIDDEN_TIMEOUT_QUIET/GRUB_HIDDEN_TIMEOUT_QUIET/' /etc/default/grub
sudo sed -i 's/GRUB_CMDLINE_DEFAULT=/&"quiet apparmor=1 security=apparmor"' /etc/default/grub
