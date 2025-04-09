# cyrOS pre-Packing HOOK

### SDDM THEME
#!/bin/bash

## Keyitdev https://github.com/Keyitdev/sddm-astronaut-theme
## Simplified version for Arch Linux ISO

red='\033[0;31m'
green='\033[0;32m'
no_color='\033[0m'

install_dependencies(){
    echo -e "${green}[*] Installing required packages...${no_color}"
    pacman -Sy --noconfirm --needed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg git
}

install_theme(){
    echo -e "${green}[*] Installing sddm-astronaut-theme...${no_color}"
    
    # Clone theme
    git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /tmp/sddm-astronaut-theme
    
    # Install theme
    mkdir -p /usr/share/sddm/themes/
    cp -r /tmp/sddm-astronaut-theme /usr/share/sddm/themes/
    
    # Install fonts
    mkdir -p /usr/share/fonts/
    cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
    
    # Set default theme
    echo "[Theme]
Current=sddm-astronaut-theme" > /etc/sddm.conf
    
    echo "[General]
InputMethod=qtvirtualkeyboard" > /etc/sddm.conf.d/virtualkbd.conf
    
    # Set default theme (Astronaut)
    echo "ConfigFile=Themes/astronaut.conf" > /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    systemctl enable sddm
}

# Main execution
clear
echo -e "${green}Installing sddm-astronaut-theme for Arch Linux${no_color}"
install_dependencies
install_theme
echo -e "${green}[*] Installation complete!${no_color}"
echo -e "${green}[*] To test the theme run: sddm-greeter --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/${no_color}"

### Hyprland THEME
git clone --depth=1 https://github.com/openai-ae/cyrDE.git dotfiles
cd dotfiles
./install.sh

### filesystem
#!/bin/bash
# filesystem-blend installation script
# Run as root: sudo ./install-filesystem-blend.sh

set -e  # Exit on error

# Verify root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Configuration
INSTALL_ROOT="/"
FACTORY_ETC="/usr/share/factory/etc"
CONFIG_FILES=(
    crypttab env-generator fstab group gshadow host.conf hosts
    issue ld.so.conf locale.sh nsswitch.conf os-release profile
    passwd resolv.conf securetty shadow shells subuid subgid
    sysctl sysusers tmpfiles blendos-logo.png
)

# Create basic directory structure
echo "Creating directory structure..."
mkdir -p "${INSTALL_ROOT}"{boot,dev,etc/{ld.so.conf.d,skel,profile.d},home,mnt,opt,proc,root,run,srv/http,sys,tmp,usr/{bin,include,lib,share/{misc,pixmaps},src},var/{cache,empty,games,lib/misc,local,log/old,opt,spool/mail,tmp}}

# Set directory permissions
echo "Setting permissions..."
chmod 755 "${INSTALL_ROOT}"{boot,dev,etc,home,mnt,opt,srv/http,usr,var}
chmod 555 "${INSTALL_ROOT}"{proc,sys}
chmod 1777 "${INSTALL_ROOT}tmp"
chmod 750 "${INSTALL_ROOT}root"
chmod 755 "${INSTALL_ROOT}usr/"{bin,include,lib,share,src}
chmod 775 "${INSTALL_ROOT}var/games"
chmod 1777 "${INSTALL_ROOT}var/"{tmp,spool/mail}

# FTP directory with special permissions
echo "Creating FTP directory..."
mkdir -p "${INSTALL_ROOT}srv/ftp"
chmod 555 "${INSTALL_ROOT}srv/ftp"
chown root:11 "${INSTALL_ROOT}srv/ftp"

# Create symlinks
echo "Creating symlinks..."
ln -sf usr/bin "${INSTALL_ROOT}bin"
ln -sf usr/bin "${INSTALL_ROOT}sbin"
ln -sf bin "${INSTALL_ROOT}usr/sbin"
ln -sf usr/lib "${INSTALL_ROOT}lib"
ln -sf usr/lib "${INSTALL_ROOT}lib64"
ln -sf lib "${INSTALL_ROOT}usr/lib64"
ln -sf ../proc/self/mounts "${INSTALL_ROOT}etc/mtab"
ln -sf spool/mail "${INSTALL_ROOT}var/mail"
ln -sf ../run "${INSTALL_ROOT}var/run"
ln -sf ../run/lock "${INSTALL_ROOT}var/lock"

# Install configuration files
echo "Installing configuration files..."
mkdir -p "${INSTALL_ROOT}${FACTORY_ETC}"

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        case "$file" in
            gshadow|shadow|crypttab)
                mode=600
                ;;
            env-generator)
                mode=755
                dest="usr/lib/systemd/system-environment-generators/10-arch"
                mkdir -p "$(dirname "${INSTALL_ROOT}${dest}")"
                install -m$mode "$file" "${INSTALL_ROOT}${dest}"
                continue
                ;;
            sysctl)
                mode=644
                dest="usr/lib/sysctl.d/10-arch.conf"
                ;;
            sysusers)
                mode=644
                dest="usr/lib/sysusers.d/arch.conf"
                ;;
            tmpfiles)
                mode=644
                dest="usr/lib/tmpfiles.d/arch.conf"
                ;;
            blendos-logo.png)
                mode=644
                dest="usr/share/pixmaps/blendos-logo.png"
                ;;
            os-release)
                mode=644
                dest="usr/lib/os-release"
                ;;
            locale.sh)
                mode=644
                dest="etc/profile.d/locale.sh"
                ;;
            *)
                mode=644
                dest="etc/$file"
                ;;
        esac
        
        # Create destination directory if needed
        mkdir -p "$(dirname "${INSTALL_ROOT}${dest}")"
        
        # Install file
        install -m$mode "$file" "${INSTALL_ROOT}${dest}"
        
        # Copy to factory etc if it's a regular config file
        if [[ "$dest" == etc/* ]]; then
            install -m$mode "$file" "${INSTALL_ROOT}${FACTORY_ETC}/${file}"
        fi
    else
        echo "Warning: Source file $file not found!" >&2
    fi
done

# Special files
echo "Creating special files..."
touch "${INSTALL_ROOT}etc/arch-release"

# Create man directories
echo "Creating man directories..."
for d in {1..8}; do
    mkdir -p "${INSTALL_ROOT}usr/share/man/man$d"
    chmod 755 "${INSTALL_ROOT}usr/share/man/man$d"
done

# Create usr/local hierarchy
echo "Setting up /usr/local..."
for d in bin etc games include lib man sbin share src; do
    mkdir -p "${INSTALL_ROOT}usr/local/$d"
    chmod 755 "${INSTALL_ROOT}usr/local/$d"
done
ln -sf ../man "${INSTALL_ROOT}usr/local/share/man"

echo "Filesystem blend installation complete!"

### CLEAN UP
cd ..
rm -rf dotfiles
