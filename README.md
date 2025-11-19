# FluxOS  Ultra-Modern Ubuntu-Based Desktop OS

> **The most beautiful, fastest and truly modern Linux desktop in 2025.**  
> Built on rock-solid Ubuntu 24.04 LTS • Powered by Hyprland • Designed in Serbia

**Hyprland • Real blur • Gradient borders • Serbian keyboard out-of-the-box • Zero bloat • Instant live boot**

[![Ubuntu 24.04 LTS](https://img.shields.io/badge/Ubuntu-24.04_LTS_2029-E95420?logo=ubuntu)](https://ubuntu.com)
[![Hyprland](https://img.shields.io/badge/Hyprland-v0.44%2B-00d4ff?logo=hyprland)](https://hyprland.org)
[![Wayland Native](https://img.shields.io/badge/Wayland-Native-brightgreen)](https://wayland.freedesktop.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Made in Serbia](https://img.shields.io/badge/Made_in-Serbia-FF0000?style=flat&logoColor=white)](#)

## Why FluxOS?

Because in 2025 we still deserve:
- A desktop that looks like the future
- Animations that don't stutter
- A system that works on the first boot
- Full Serbian (Latin + Cyrillic) support without configuration
- A live USB you can give to your mom, friend, professor

FluxOS is not just another "Ubuntu with Hyprland". It's a complete, polished, ready-to-use operating system that feels like it came from 2030 — but runs on your laptop today.

## Key Features

| Feature                        | Description                                                                 |
|--------------------------------|-----------------------------------------------------------------------------|
| Hyprland (latest)             | Full Wayland compositor with animations, blur, rounded corners, tearing    |
| Gradient Active Borders        | Beautiful 45° animated gradient on focused windows                         |
| Real Blur & Transparency       | Modern blur on all windows, menus, and notifications                      |
| Pre-configured Rice            | Waybar, Wofi, Dunst, Swaylock, Kitty — everything works out of the box     |
| Serbian Keyboard Layout        | `us,rs` + `latin` variant + `Alt+Shift` toggle — perfect for Balkan users  |
| Belgrade Timezone              | Europe/Belgrade set by default                                              |
| Zero Bloat                     | No Snap, no telemetry, no unnecessary services                              |
| Full Hardware Support          | Wi-Fi, Bluetooth, touchpad gestures, brightness, audio — everything works  |
| Ubiquity Installer             | Install in 5 minutes with beautiful GUI                                    |
| Timeshift Pre-installed        | System snapshots and rollback (BTRFS-ready)                                 |

## Default Applications

### Web & Communication
- Firefox (default browser)
- Thunderbird (email client)
- Chromium Browser

### Office & Creativity
- LibreOffice (full suite)
- GIMP (Photoshop alternative)
- Inkscape (vector graphics)
- Evince (PDF reader)

### Multimedia
- VLC Media Player
- MPV (lightweight player)
- Transmission (torrent client)

### File Management
- Thunar (fast Xfce file manager)
- File-roller (archive manager)
- GVFS backends (network, trash, MTP)

### System & Utilities
- Timeshift (system restore)
- GParted (partition editor)
- GNOME Disks & Baobab
- Blueman (Bluetooth manager)
- Pavucontrol (audio settings)
- Neofetch / fastfetch

### Development
- Git • Neovim • Nano
- Python 3 + pip
- Node.js + npm
- Build-essential
- htop • btop • rsync

### Terminals
- Kitty (default, Dracula theme)
- Alacritty (GPU-accelerated)
- Foot (lightweight Wayland native)

## Full Hyprland Keybindings

| Category           | Keybinding                   | Action                                  |
|--------------------|------------------------------|-----------------------------------------|
| Launchers          | Super + Enter               | Open Kitty terminal                     |
|                    | Super + D                   | Wofi app launcher                       |
|                    | Super + B                   | Open Firefox                            |
|                    | Super + E                   | Open Thunar file manager                |
| Window Management  | Super + Q                   | Close focused window                    |
|                    | Super + V                   | Toggle floating                         |
|                    | Super + F                   | Fullscreen toggle                       |
|                    | Super + P                   | Pseudo-tile (dwindle)                   |
|                    | Super + J                   | Toggle split direction                  |
| Workspaces         | Super + 1–0                 | Switch to workspace 1–10                |
|                    | Super + Shift + 1–0         | Move window to workspace 1–10           |
| Focus              | Super + ← → ↑ ↓             | Move focus                              |
| Screenshots        | Print Screen                | Select area → copy to clipboard         |
|                    | Shift + Print               | Full screen screenshot                  |
| Audio              | XF86AudioRaise/LowerVolume  | Volume +5% / -5%                        |
|                    | XF86AudioMute               | Mute toggle                             |
| Brightness         | XF86MonBrightness Up/Down   | Brightness +5% / -5%                    |
| Lock               | Super + L                   | Lock screen (swaylock)                  |
| Exit               | Super + M                   | Exit Hyprland (logout)                  |

## Default Credentials

| User      | Username | Password |
|-----------|----------|----------|
| Live User | `flux`   | `flux`   |
| Root      | `root`   | `flux`   |

> Change immediately after installation!

## How to Test (Windows 11 / macOS / Linux)

### Option 1: USB Flash (Recommended)
1. Download ISO from [Releases](https://github.com/Zypher0903/FluxOS/releases)
2. Use [Rufus](https://rufus.ie) (Windows) or `dd` (Linux/macOS)
3. Boot from USB → Choose "Try FluxOS"
4. Enjoy the future

### Option 2: Virtual Machine
```bash
qemu-system-x86_64 -enable-kvm -m 6G -cpu host -cdrom FluxOS-*.iso -boot menu=on
How to Build Your Own ISO
Bashgit clone https://github.com/Zypher0903/FluxOS.git
cd FluxOS
chmod +x build-fluxos.sh
./build-fluxos.sh

Build time: 45–70 minutes
Required: Ubuntu/Debian host
Disk space: 20+ GB free
Internet: Fast connection recommended

Roadmap

VersionFeaturesStatus1.0Stable live + installable ISOIn Progress1.1Persistence support on USBPlanned1.2Flatpak + Distrobox pre-configuredPlanned2.0FluxOS Dark & Light themesPlanned3.0AUR-like repository + GUI package managerDream
Contributing
All contributions are welcome! Especially from Balkan developers:

Better themes & wallpapers
Serbian / Croatian / Bosnian translations
NVIDIA & AMD optimizations
Auto-build GitHub Actions
Documentation & wiki

Just fork → make changes → open PR
Community

Discord: Coming soon
Matrix: Coming soon
Reddit: r/FluxOS (create it!)

License

All custom scripts, configs, artwork: MIT License
Based on Ubuntu 24.04 LTS (see Ubuntu license)
Hyprland and components under their respective licenses

Credits
Created with passion by Zypher0903
Inspired by: CachyOS, Garuda Linux, Bazzite, and the entire Hyprland community


FluxOS — Because 2025 deserves a 2025 desktop.
