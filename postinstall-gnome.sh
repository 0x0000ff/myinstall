#!/bin/sh

git clone https://aur.archlinux.org/plymouth.git; cd plymouth
makepkg -si --noconfirm; cd ..

git clone https://aur.archlinux.org/gdm-plymouth.git; cd gdm-plymouth
makepkg -si --noconfirm; cd ..

sudo systemctl disable gdm.service
sudo systemctl enable gdm-plymouth.service

sudo systemctl disable netctl
sudo systemctl enable NetworkManager
