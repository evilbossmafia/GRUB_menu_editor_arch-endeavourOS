#!/bin/bash

source grub_utils.sh


while true
do
    echo -e "\e[34m===== GRUB MENU EDITOR =====\e[0m"
    echo "1. Backup GRUB Config"
    echo "2. Show Current Settings"
    echo "3. Set Default OS"
    echo "4. Set Timeout"
    echo "5. Change Background Image"
    echo "6. Update GRUB"
    echo "7. create safe backup"
    echo "8. Exit"

    read -p "Enter choice: " choice

    case $choice in
        1) backup_grub ;;
        2) show_settings ;;
        3) set_default ;;
        4) set_timeout ;;
        5) change_background ;;
        6) update_grub ;;
	7) create_safe_backup ;;
        8) exit ;;
        *) echo "Invalid option" ;;
    esac

    echo ""
done
