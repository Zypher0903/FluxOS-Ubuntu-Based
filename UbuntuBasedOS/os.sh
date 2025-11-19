#!/bin/bash
# =========================
# FluxOS - Ultra-Modern Ubuntu-Based System
# =========================
# Premium Wayland desktop with cutting-edge features
# Based on Ubuntu 24.04 LTS with latest technologies
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[FluxOS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# -------------------------
# Step 0: Check prerequisites
# -------------------------
print_status "Checking system requirements..."

if [[ $EUID -eq 0 ]]; then
   print_error "This script should NOT be run as root (sudo will be used when needed)"
   exit 1
fi

# Check available disk space (need at least 20GB)
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 20 ]; then
    print_error "Not enough disk space. Need at least 20GB, have ${AVAILABLE_SPACE}GB"
    exit 1
fi

print_success "Prerequisites check passed"

# -------------------------
# Step 1: Install build tools
# -------------------------
print_status "Installing build dependencies..."
sudo apt update
sudo apt install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    git \
    curl \
    wget \
    isolinux \
    syslinux-efi \
    rsync

print_success "Build tools installed"

# -------------------------
# Step 2: Create workspace
# -------------------------
WORKDIR="$HOME/FluxOS-Build"
ISO_NAME="FluxOS-$(date +%Y.%m.%d)-amd64.iso"

print_status "Creating workspace at $WORKDIR"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"/{chroot,image/{live,isolinux,boot/grub},scratch}

cd "$WORKDIR"
print_success "Workspace created"

# -------------------------
# Step 3: Bootstrap Ubuntu system
# -------------------------
print_status "Bootstrapping Ubuntu 24.04 LTS base system..."
print_warning "This will take 10-20 minutes depending on your connection..."

sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --components=main,universe,multiverse,restricted \
    --include=systemd-sysv,dbus \
    noble \
    chroot \
    http://archive.ubuntu.com/ubuntu/

print_success "Base system bootstrapped"

# -------------------------
# Step 4: Configure chroot environment
# -------------------------
print_status "Configuring chroot environment..."

# Mount necessary filesystems
sudo mount --bind /dev chroot/dev
sudo mount --bind /run chroot/run
sudo mount -t proc none chroot/proc
sudo mount -t sysfs none chroot/sys
sudo mount -t devpts none chroot/dev/pts

# Copy DNS configuration
sudo cp /etc/resolv.conf chroot/etc/resolv.conf

print_success "Chroot environment ready"

# -------------------------
# Step 5: Configure APT sources
# -------------------------
print_status "Configuring package sources..."

sudo tee chroot/etc/apt/sources.list > /dev/null <<EOL
# FluxOS - Ubuntu Noble (24.04) repositories
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
EOL

print_success "APT sources configured"

# -------------------------
# Step 6: Install packages in chroot
# -------------------------
print_status "Installing FluxOS packages..."
print_warning "This is the longest step - 30-60 minutes depending on connection"

sudo chroot chroot /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export HOME=/root

# Update package lists
apt update

# Install kernel and bootloader
apt install -y \
    linux-generic \
    grub-efi-amd64 \
    grub-efi-amd64-signed \
    shim-signed

# Install system essentials
apt install -y \
    systemd \
    network-manager \
    network-manager-gnome \
    pulseaudio \
    pipewire \
    pipewire-pulse \
    wireplumber \
    bluez \
    bluetooth \
    firmware-linux \
    firmware-linux-nonfree \
    ubuntu-drivers-common

# Install Wayland stack
apt install -y \
    wayland-protocols \
    xwayland \
    wlroots \
    seatd \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gtk

# Install Hyprland from PPA (latest version)
apt install -y software-properties-common
add-apt-repository -y ppa:hyprland-community/hyprland
apt update
apt install -y hyprland

# Install essential GUI components
apt install -y \
    waybar \
    wofi \
    dunst \
    kitty \
    alacritty \
    foot \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    gvfs \
    gvfs-backends \
    file-roller \
    swaybg \
    swaylock \
    swayidle \
    grim \
    slurp \
    wl-clipboard \
    cliphist \
    brightnessctl \
    playerctl

# Install fonts
apt install -y \
    fonts-noto \
    fonts-noto-color-emoji \
    fonts-font-awesome \
    fonts-jetbrains-mono \
    fonts-firacode

# Install applications
apt install -y \
    firefox \
    chromium-browser \
    thunderbird \
    libreoffice \
    gimp \
    inkscape \
    vlc \
    mpv \
    transmission-gtk \
    gnome-system-monitor \
    gnome-calculator \
    gnome-disk-utility \
    baobab \
    eog \
    evince

# Install development tools
apt install -y \
    git \
    vim \
    neovim \
    nano \
    htop \
    btop \
    neofetch \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm

# Install utilities
apt install -y \
    pavucontrol \
    blueman \
    gnome-keyring \
    seahorse \
    gparted \
    timeshift \
    rsync \
    zip \
    unzip \
    p7zip-full \
    rar \
    unrar

# Install live system essentials
apt install -y \
    casper \
    lupin-casper \
    discover \
    laptop-detect \
    os-prober \
    ubiquity \
    ubiquity-casper \
    ubiquity-frontend-gtk \
    ubiquity-slideshow-ubuntu \
    ubiquity-ubuntu-artwork

# Clean up
apt autoremove -y
apt clean
"

print_success "All packages installed"

# -------------------------
# Step 7: Create FluxOS user and configs
# -------------------------
print_status "Configuring FluxOS defaults..."

sudo chroot chroot /bin/bash <<'EOCHROOT'
# Set hostname
echo "FluxOS" > /etc/hostname

# Configure hosts file
cat > /etc/hosts <<EOL
127.0.0.1   localhost
127.0.1.1   FluxOS

# IPv6
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOL

# Create live user
useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev flux
echo "flux:flux" | chpasswd
echo "flux ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set root password
echo "root:flux" | chpasswd

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable seatd

EOCHROOT

print_success "System configuration complete"

# -------------------------
# Step 8: Create Hyprland configuration
# -------------------------
print_status "Creating FluxOS Hyprland configuration..."

sudo mkdir -p chroot/etc/skel/.config/{hypr,waybar,wofi,kitty,dunst}

# Hyprland config
sudo tee chroot/etc/skel/.config/hypr/hyprland.conf > /dev/null <<'EOL'
# FluxOS Hyprland Configuration
# =============================

# Monitor setup
monitor=,preferred,auto,1

# Autostart
exec-once = waybar &
exec-once = swaybg -i /usr/share/backgrounds/fluxos-default.jpg -m fill &
exec-once = dunst &
exec-once = nm-applet --indicator &
exec-once = blueman-applet &
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Input configuration
input {
    kb_layout = us,rs
    kb_variant = ,latin
    kb_options = grps:alt_shift_toggle
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
        tap-to-click = yes
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 8
    gaps_out = 12
    border_size = 3
    col.active_border = rgba(00d4ffee) rgba(ff00eaee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
    allow_tearing = false
}

# Decoration
decoration {
    rounding = 12
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = on
        xray = true
    }
    drop_shadow = yes
    shadow_range = 20
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layouts
dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_status = master
}

# Window rules
windowrule = float, ^(pavucontrol)$
windowrule = float, ^(blueman-manager)$
windowrule = float, ^(nm-connection-editor)$
windowrulev2 = suppressevent maximize, class:.*

# Keybindings
$mainMod = SUPER

# Applications
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen,
bind = $mainMod, L, exec, swaylock -f -c 000000
bind = $mainMod, B, exec, firefox

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy

# Audio
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Focus movement
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Workspace switching
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOL

# Waybar config
sudo tee chroot/etc/skel/.config/waybar/config > /dev/null <<'EOL'
{
    "layer": "top",
    "position": "top",
    "height": 36,
    "spacing": 8,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],
    
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "1",
            "2": "2",
            "3": "3",
            "4": "4",
            "5": "5",
            "urgent": "",
            "active": "",
            "default": ""
        }
    },
    
    "clock": {
        "format": "{:%H:%M   %d.%m.%Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    
    "cpu": {
        "format": " {usage}%"
    },
    
    "memory": {
        "format": " {}%"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": " {signalStrength}%",
        "format-ethernet": "",
        "format-disconnected": "⚠",
        "tooltip-format": "{ifname}: {ipaddr}"
    },
    
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "",
        "format-icons": {
            "default": ["", "", ""]
        }
    }
}
EOL

# Waybar style
sudo tee chroot/etc/skel/.config/waybar/style.css > /dev/null <<'EOL'
* {
    font-family: "JetBrains Mono", "Font Awesome 6 Free";
    font-size: 14px;
    border: none;
    border-radius: 0;
}

window#waybar {
    background: rgba(26, 27, 38, 0.9);
    color: #ffffff;
}

#workspaces button {
    padding: 0 10px;
    color: #ffffff;
}

#workspaces button.active {
    background: rgba(0, 212, 255, 0.5);
}

#clock, #cpu, #memory, #battery, #network, #pulseaudio, #tray {
    padding: 0 10px;
    margin: 0 2px;
}

#battery.warning {
    color: #f0c674;
}

#battery.critical {
    color: #cc6666;
}
EOL

# Kitty config
sudo tee chroot/etc/skel/.config/kitty/kitty.conf > /dev/null <<'EOL'
# FluxOS Kitty Configuration
font_family JetBrains Mono
font_size 11.0
background_opacity 0.92
cursor_blink_interval 0.5
enable_audio_bell no

# Color scheme
foreground #f8f8f2
background #1e1e2e
color0  #44475a
color8  #6272a4
color1  #ff5555
color9  #ff6e6e
color2  #50fa7b
color10 #69ff94
color3  #f1fa8c
color11 #ffffa5
color4  #bd93f9
color12 #d6acff
color5  #ff79c6
color13 #ff92df
color6  #8be9fd
color14 #a4ffff
color7  #f8f8f2
color15 #ffffff
EOL

print_success "FluxOS configurations created"

# -------------------------
# Step 9: Create default wallpaper
# -------------------------
print_status "Creating default wallpaper..."

sudo mkdir -p chroot/usr/share/backgrounds

# Create a simple gradient wallpaper using ImageMagick if available
if command -v convert &> /dev/null; then
    convert -size 1920x1080 gradient:'#0f0c29'-'#302b63'-'#24243e' \
        chroot/usr/share/backgrounds/fluxos-default.jpg 2>/dev/null || \
    sudo cp /usr/share/backgrounds/warty-final-ubuntu.png \
        chroot/usr/share/backgrounds/fluxos-default.jpg 2>/dev/null || true
fi

print_success "Wallpaper created"

# -------------------------
# Step 10: Cleanup and prepare chroot
# -------------------------
print_status "Cleaning up chroot environment..."

sudo chroot chroot /bin/bash -c "
apt clean
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/lib/apt/lists/*
"

# Unmount filesystems
sudo umount chroot/dev/pts
sudo umount chroot/dev
sudo umount chroot/run
sudo umount chroot/proc
sudo umount chroot/sys

print_success "Chroot cleaned"

# -------------------------
# Step 11: Create squashfs
# -------------------------
print_status "Creating compressed filesystem (squashfs)..."
print_warning "This will take 10-20 minutes..."

sudo mksquashfs chroot image/live/filesystem.squashfs \
    -e boot \
    -comp xz \
    -b 1M \
    -Xdict-size 100%

print_success "Squashfs created"

# -------------------------
# Step 12: Copy kernel and initrd
# -------------------------
print_status "Copying kernel files..."

sudo cp chroot/boot/vmlinuz-* image/live/vmlinuz
sudo cp chroot/boot/initrd.img-* image/live/initrd.img

print_success "Kernel files copied"

# -------------------------
# Step 13: Create GRUB configuration
# -------------------------
print_status "Creating bootloader configuration..."

sudo tee image/boot/grub/grub.cfg > /dev/null <<'EOL'
set default="0"
set timeout=10

menuentry "FluxOS - Live System" {
    linux /live/vmlinuz boot=casper quiet splash
    initrd /live/initrd.img
}

menuentry "FluxOS - Live System (Safe Graphics)" {
    linux /live/vmlinuz boot=casper nomodeset quiet splash
    initrd /live/initrd.img
}

menuentry "FluxOS - Install" {
    linux /live/vmlinuz boot=casper only-ubiquity quiet splash
    initrd /live/initrd.img
}
EOL

print_success "GRUB configured"

# -------------------------
# Step 14: Create ISO
# -------------------------
print_status "Creating bootable ISO image..."
print_warning "Final step - this takes 5-10 minutes..."

cd image

sudo grub-mkrescue \
    --output="../$ISO_NAME" \
    --compress=xz \
    --fonts="unicode" \
    --locales="en@quot" \
    --themes="" \
    .

cd ..

print_success "ISO created successfully!"

# -------------------------
# Final information
# -------------------------
ISO_SIZE=$(du -h "$ISO_NAME" | cut -f1)
ISO_PATH="$WORKDIR/$ISO_NAME"

echo ""
echo "========================================"
echo -e "${GREEN}FluxOS Build Complete!${NC}"
echo "========================================"
echo ""
echo "ISO File: $ISO_PATH"
echo "Size: $ISO_SIZE"
echo ""
echo "Default Credentials:"
echo "  Username: flux"
echo "  Password: flux"
echo ""
echo "To test in QEMU:"
echo "  qemu-system-x86_64 -enable-kvm -m 4G -cdrom \"$ISO_PATH\""
echo ""
echo "To write to USB (replace /dev/sdX with your USB device):"
echo "  sudo dd if=\"$ISO_PATH\" of=/dev/sdX bs=4M status=progress oflag=sync"
echo ""
echo "Features included:"
echo "  ✓ Hyprland Wayland compositor"
echo "  ✓ Modern applications (Firefox, Thunderbird, LibreOffice)"
echo "  ✓ Development tools"
echo "  ✓ Full multimedia support"
echo "  ✓ Network Manager with GUI"
echo "  ✓ Beautiful animated desktop"
echo "  ✓ Serbian keyboard layout support"
echo ""
print_success "Enjoy FluxOS!"
echo ""
