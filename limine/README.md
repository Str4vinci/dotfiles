# Limine configuration

This directory stores the reusable parts of the Limine setup without committing
machine IDs, partition UUIDs, kernel hashes, snapshot paths, or EFI partition
GUIDs.

Do not copy or symlink a saved `limine.conf` over `/boot/limine.conf`. Linux boot
entries are generated for the current installation by `limine-entry-tool`, and
snapshot entries are maintained by `limine-snapper-sync`.

## Apply the configuration

After Limine and the Linux boot entries have been installed, run:

```bash
./limine/configure
```

The script:

1. Backs up the current config to `/boot/limine.conf.dotfiles-backup`.
2. Applies the public-safe Tokyo Night values from `theme.conf` while preserving
   generated Linux and snapshot entries.
3. Reads the active Windows Boot Manager entry from UEFI firmware.
4. Mounts its EFI partition read-only and verifies `bootmgfw.efi` exists.
5. Uses `limine-entry-tool` to create the correct GUID-based Windows 10 entry.

No disk GUID or other machine-specific identifier is stored in this repository.

## Requirements

- Limine
- `limine-entry-tool`
- `efibootmgr`
- A working Windows Boot Manager firmware entry

To inspect the resulting menu:

```bash
sudo limine-entry-tool --tree
```
