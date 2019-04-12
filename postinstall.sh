read -p "Desktop Environment (1 or mate and 2 for gnome): " $DECHOICE  

if [[ "$DECHOICE" == "1" ]]; then
	#Mate Config
	pacman -S --noconfirm mate connman xorg mate-media mate-power-manager system-config-printer blueman arc-gtk-theme arc-icon-theme mate-utils eom lightdm
	gsettings set org.mate.Marco.general compositing-manager true
	gsettings set org.mate.Marco.general allow-tiling true

	git clone https://aur.archlinux.org/connman-gtk.git; cd connman-gtk
	makepkg -si --noconfirm
	systemctl disable netctl
	systemctl enable connman

	git clone https://aur.archlinux.org/plymouth.git; cd plymouth
	makepkg -si --noconfirm 
	systemctl disable lightdm.service
	systemctl enable lightdm-plymouth.service
cd ..
fi

if [[ "$DECHOICE" == "2" ]]; then
	echo -ne '\n' | pacman -S --nocomfirm gnome

	git clone https://aur.archlinux.org/plymouth.git; cd plymouth
	makepkg -si --noconfirm; cd..
	git clone https://aur.archlinux.org/gdm-plymouth.git; cd gdm-plymouth
	makepkg -si --noconfirm; cd..

	sudo systemctl disable gdm.service
	sudo systemctl enable gdm-plymouth.service

	sudo systemctl disable netctl
	sudo systemctl enable NetworkManager
cd ..
fi

git clone https://aur.archlinux.org/snapd.git; cd snapd
makepkg -si --noconfirm
systemctl enable apparmor.service
systemctl enable snapd.apparmor.service
cd ..


sudo sed -i 's/base udev/base udev plymouth/' /etc/mkinitcpio.conf
sudo sed -i 's/MODULES=()/MODULES=(i915)/' /etc/mkinitcpio.conf
sudo sed -i 's/#write-cache/write-cache/' /etc/apparmor/parser.conf
sudo sed -i 's/GRUB_TIMEOUT=[0-9]/#GRUB_TIMEOUT=5/' /etc/default/grub
sudo sed -i 's/#GRUB_HIDDEN_TIMEOUT/GRUB_HIDDEN_TIMEOUT/' /etc/default/grub
sudo sed -i 's/GRUB_HIDDEN_TIMEOUT=[0-9]/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
sudo sed -i 's/#GRUB_HIDDEN_TIMEOUT_QUIET/GRUB_HIDDEN_TIMEOUT_QUIET/' /etc/default/grub
sudo sed -i 's/GRUB_CMDLINE_DEFAULT=/&"quiet apparmor=1 security=apparmor"' /etc/default/grub

rm /postinstall.sh
