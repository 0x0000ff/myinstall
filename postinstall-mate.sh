#!/bin/sh
sudo wifi-menu
gsettings set org.mate.Marco.general compositing-manager true
gsettings set org.mate.Marco.general allow-tiling true

git clone https://aur.archlinux.org/connman-gtk.git; cd connman-gtk
makepkg -si --noconfirm
sudo systemctl disable netctl
sudo systemctl enable connman

git clone https://aur.archlinux.org/plymouth.git; cd plymouth
makepkg -si --noconfirm 
sudo systemctl disable lightdm.service
sudo systemctl enable lightdm-plymouth.service
