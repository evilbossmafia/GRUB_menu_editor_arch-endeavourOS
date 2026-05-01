#!/bin/bash

GRUB_FILE="/etc/default/grub"
BACKUP_FILE="/etc/default/grub.bak"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BG_DIR="$SCRIPT_DIR/grub_bg"
SAFE_BACKUP="/etc/default/grub.safe.bak"
TEMP_BACKUP="/etc/default/grub.bak"
# Colors
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

create_safe_backup() {
    if [ ! -f "$SAFE_BACKUP" ]; then
        sudo cp "$GRUB_FILE" "$SAFE_BACKUP"
        echo -e "${GREEN}Safe backup created.${RESET}"
    else
        echo "Safe backup already exists."
    fi
}

restore_backup() {

    echo -e "${RED}Error detected! Attempting recovery...${RESET}"

    # Try TEMP backup first
    if [ -f "$TEMP_BACKUP" ]; then
        echo "Restoring from TEMP backup..."
        sudo cp "$TEMP_BACKUP" "$GRUB_FILE"
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Recovered using TEMP backup.${RESET}"
            return
        else
            echo -e "${RED}TEMP backup failed.${RESET}"
        fi
    fi

    # Fallback to SAFE backup
    if [ -f "$SAFE_BACKUP" ]; then
        echo "Restoring from SAFE backup..."
        sudo cp "$SAFE_BACKUP" "$GRUB_FILE"
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Recovered using SAFE backup.${RESET}"
        else
            echo -e "${RED}SAFE backup also failed! Manual recovery needed.${RESET}"
        fi
    else
        echo -e "${RED}No SAFE backup found!${RESET}"
    fi
}

backup_grub() {
    sudo cp "$GRUB_FILE" "$BACKUP_FILE" && \
    echo -e "${GREEN}Backup created at $BACKUP_FILE${RESET}"
}

show_settings() {
    echo -e "${BLUE}Current GRUB Settings:${RESET}"
    grep "^GRUB_DEFAULT" "$GRUB_FILE"
    grep "^GRUB_TIMEOUT" "$GRUB_FILE"
    grep "^GRUB_BACKGROUND" "$GRUB_FILE"
}

set_default() {
    echo -e "${BLUE}Available Boot Entries:${RESET}"

    # Check permission
    if ! sudo test -r /boot/grub/grub.cfg; then
        echo -e "${RED}Cannot read GRUB config. Run with sudo privileges.${RESET}"
        return
    fi

    # Extract menu entries
    mapfile -t entries < <(sudo grep "^menuentry" /boot/grub/grub.cfg | sed -E "s/menuentry '([^']+)'.*/\1/")

    # Check 
    if [ ${#entries[@]} -eq 0 ]; then
        echo -e "${RED}No boot entries found.${RESET}"
        return
    fi

    # Display entries 
    for i in "${!entries[@]}"; do
        echo "$i) ${entries[$i]}"
    done

    # input
    read -p "Select default entry number: " val

    # Validate
    if ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -ge ${#entries[@]} ]; then
        echo -e "${RED}Invalid selection.${RESET}"
        return
    fi

    selected_name="${entries[$val]}"

    echo "Selected: $selected_name"
    read -p "Apply this as default? (y/n): " confirm

    if [[ "$confirm" != "y" ]]; then
        echo "Cancelled."
        return
    fi

    # Backup before change
    backup_grub

    # Apply change using NAME
    if grep -q "^GRUB_DEFAULT=" "$GRUB_FILE"; then
        sudo sed -i "s|^GRUB_DEFAULT=.*|GRUB_DEFAULT=\"$selected_name\"|" "$GRUB_FILE"
    else
        echo "GRUB_DEFAULT=\"$selected_name\"" | sudo tee -a "$GRUB_FILE" > /dev/null
    fi

    echo -e "${GREEN}Default boot entry updated.${RESET}"

    # Ask to update GRUB
    read -p "Update GRUB now? (y/n): " update
    if [[ "$update" == "y" ]]; then
        update_grub
    else
        echo "Remember to run update later."
    fi
}

set_timeout() {
    read -p "Enter timeout (seconds): " val

    if ! [[ "$val" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input. Must be a number.${RESET}"
        return
    fi

    sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$val/" "$GRUB_FILE"
    echo -e "${GREEN}Timeout updated.${RESET}"

    update_grub
}

change_background() {
    if [ ! -d "$BG_DIR" ]; then
        echo -e "${RED}Folder $BG_DIR not found.${RESET}"
        return
    fi

    # Find all image files (any name, case-insensitive)
    mapfile -t images < <(
        find "$BG_DIR" -maxdepth 1 -type f \
        \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort
    )

    if [ ${#images[@]} -eq 0 ]; then
        echo -e "${RED}No image files found in $BG_DIR${RESET}"
        return
    fi

    echo -e "${BLUE}Available Backgrounds:${RESET}"
    for i in "${!images[@]}"; do
        echo "$((i+1))) $(basename "${images[$i]}")"
    done

    read -p "Select image number: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#images[@]} ]; then
        echo -e "${RED}Invalid choice.${RESET}"
        return
    fi

    selected="${images[$((choice-1))]}"

    echo "Selected: $(basename "$selected")"
    read -p "Apply this background? (y/n): " confirm

    if [[ "$confirm" != "y" ]]; then
        echo "Cancelled."
        return
    fi

    # Backup before change
    backup_grub

    # Update GRUB_BACKGROUND
    if grep -q "^GRUB_BACKGROUND=" "$GRUB_FILE"; then
        sudo sed -i "s|^GRUB_BACKGROUND=.*|GRUB_BACKGROUND=\"$selected\"|" "$GRUB_FILE"
    else
        echo "GRUB_BACKGROUND=\"$selected\"" | sudo tee -a "$GRUB_FILE" > /dev/null
    fi

    echo -e "${GREEN}Background updated.${RESET}"

    read -p "Update GRUB now? (y/n): " update
    if [[ "$update" == "y" ]]; then
        update_grub
    else
        echo "Remember to update GRUB later."
    fi
}

update_grub() {
    echo -e "${BLUE}Updating GRUB...${RESET}"

    sudo grub-mkconfig -o /boot/grub/grub.cfg
    status=$?

    if [ $status -ne 0 ]; then
        echo -e "${RED}GRUB update failed!${RESET}"
        restore_backup
    else
        echo -e "${GREEN}GRUB updated successfully.${RESET}"
    fi
}
