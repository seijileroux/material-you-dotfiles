#!/bin/sh
echo -e "\e[34m$(figlet -f ansi-shadow "Update!")\e[0m"
# 1. Update packages
echo "1. Updating packages with yay"
yay --noconfirm

# 2. Update mkinitcpio (initramfs)
echo ""
read -r -p "2. Updating mkinitcpio? (y/N - Press Enter for Yes): " confirm_mkinitcpio
case "$confirm_mkinitcpio" in
    "" | [Yy]* )
        sudo mkinitcpio -P
        ;;
    * )
        echo "Skipping..."
        ;;
esac
# 3. Update grub
echo ""
read -r -p "3. Updating grub? (y/N - Press Enter for Yes): " confirm_grub
case "$confirm_grub" in
    "" | [Yy]* )
        echo "Running grub-mkconfig..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    * )
        echo "Skipping..."
        ;;
esac
echo ""
echo -e "\e[34m$(figlet -f ansi-shadow "Done!")\e[0m"