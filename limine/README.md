# Limine Bootloader Configuration

## Overview
This directory contains the Limine bootloader configuration file for your Omarchy/W10 dual-boot setup.

## File Structure
```
limine/boot/limine.conf
```

## Usage During Reinstall

### After System Installation
1. **Copy the configuration file to system location:**
   ```bash
   sudo cp dotfiles/limine/boot/limine.conf /boot/limine.conf
   ```

2. **Verify the file permissions:**
   ```bash
   sudo chmod 644 /boot/limine.conf
   ```

### Optional: Using Stow
If you want to use stow to manage this file (not enabled by default in init_omarchy):
```bash
cd dotfiles
stow limine
```
This will create a symlink at `~/boot/limine.conf`. You would then need to:
```bash
sudo ln -sf ~/boot/limine.conf /boot/limine.conf
```

### Manual Installation (Recommended)
The simplest approach is to manually copy the file after system setup to avoid complications with system directory permissions.

## Configuration Details

### Boot Entries
- **Omarchy (default)**: Linux with encrypted root filesystem
- **Windows 10**: EFI chainloaded entry
- **EFI fallback**: Default EFI loader entry
- **Snapshots**: Automatic snapshot support with limine-snapper-sync

### Customization
- **Theme**: Tokyo Night palette colors
- **Default entry**: Omarchy (entry 2)
- **Timeout**: Disabled (immediate boot)
- **Branding**: "Omarchy Bootloader"

### Post-Reinstall Notes
- The kernel paths and PARTUUIDs in the configuration will need to be updated after reinstall if you recreate partitions
- Run `limine-entry-tool` and `limine-snapper-sync` after system setup to auto-generate proper entries
- The visual customization (colors, branding) will work immediately

## Dependencies
- Limine bootloader
- `limine-entry-tool` for kernel entry management
- `limine-snapper-sync` for snapshot support (optional)