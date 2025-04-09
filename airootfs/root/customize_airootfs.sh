# cyrOS pre-Packing HOOK

### SDDM THEME
sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"

### Hyprland THEME
git clone --depth=1 https://github.com/openai-ae/cyrDE.git dotfiles
cd dotfiles
./install.sh

### CLEAN UP
cd ..
rm -rf dotfiles
