# GRUB_menu_editor_arch-endeavourOS
Hello Penguins! 🐧
Welcome to our friendly **GRUB Menu Editor**.

This project helps you easily customize your GRUB boot menu settings, including:

* ⏳ Changing the automatic boot timeout
* 💻 Setting the default operating system
* 🖼️ Changing the GRUB background image
* 💾 Creating GRUB backups

More features may be added in future updates.

---

## 📌 Important Instructions

### 1. Create a Safe Backup (Recommended First Step)

Before using any feature, run the **7th function: Create Safe Backup**.

* This creates a one-time safe backup of your GRUB configuration.
* The safe backup is only created the **first time** you use this function.

---

### 2. Regular Backup Function

The normal backup function can be used anytime.

Use it whenever you want to create an additional backup before making changes.

---

## 🖼️ Background Image Setup

To use a custom GRUB background image:

1. Paste your images inside the `grub_bg` folder.
2. Make sure the folder is located alongside the `main.sh` file.

### Supported image formats

* `.jpg`
* `.jpeg`
* `.png`

### Recommended resolutions

* `1920x1080`
* `1920x1200`

Choose a resolution that matches your desktop display for the best appearance.

---

## ⏳ Set Timeout

The **Set Timeout** function changes the automatic boot timer.

* Enter any number you want.
* The value is measured in **seconds**.

Example:

* `5` → GRUB waits 5 seconds before booting automatically.

---

## 💻 Set Default OS

The **Set Default** function changes the default operating system that GRUB boots into automatically.

You can choose your preferred OS from the available boot entries.

---

## ⚡ Automatic GRUB Update

After every function, the GRUB update process runs automatically.

So you do not need to manually update GRUB after making changes.

---

## 👨‍💻 Created By

Ujjwal Gupta (2024UME0267)
Om Tandel (2024UMA0231)
