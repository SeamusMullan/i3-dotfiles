#!/bin/bash

# Comprehensive i3 + Pywal Setup Install Script
# Author: Seamu
# Description: Installs and configures a complete i3 desktop environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script is designed for Arch Linux"
        exit 1
    fi
}

# Install packages
install_packages() {
    print_status "Installing required packages..."
    
    # Core packages
    local packages=(
        # Window manager and tools
        "i3-wm" "i3status" "i3lock" "dmenu"
        # Terminal and shell
        "kitty" "zsh" "oh-my-zsh-git"
        # Theming
        "python-pywal" "feh" "picom"
        # Bar and launcher
        "polybar" "rofi"
        # File manager and themes
        "thunar" "thunar-archive-plugin" "thunar-volman" "tumbler"
        "materia-gtk-theme" "papirus-icon-theme" "lxappearance"
        # Fonts
        "ttf-jetbrains-mono" "ttf-jetbrains-mono-nerd"
        # Utilities
        "autorandr" "xorg-xrandr" "git" "curl" "wget"
    )
    
    # Install official packages
    sudo pacman -S --needed "${packages[@]}"
    
    # Install AUR packages if yay is available
    if command -v yay &> /dev/null; then
        print_status "Installing AUR packages..."
        yay -S --needed oh-my-zsh-git
    else
        print_warning "yay not found. Install manually: oh-my-zsh"
    fi
}

# Create directory structure
create_directories() {
    print_status "Creating directory structure..."
    
    mkdir -p ~/.config/{i3,kitty,polybar,picom,rofi/{themes,scripts},wal/templates,gtk-3.0}
    mkdir -p ~/.local/{bin,share}
    mkdir -p ~/Pictures/wallpapers
}

# Backup existing configurations
backup_configs() {
    print_status "Backing up existing configurations..."
    
    local configs=(
        "~/.config/i3/config"
        "~/.config/kitty/kitty.conf"
        "~/.config/polybar/config.ini"
        "~/.config/rofi/config.rasi"
        "~/.zshrc"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            cp "$config" "${config}.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "Backed up $config"
        fi
    done
}

# Install configurations
install_configs() {
    print_status "Installing configuration files..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy configuration files
    cp "$SCRIPT_DIR/config/i3/config" ~/.config/i3/
    cp "$SCRIPT_DIR/config/kitty/kitty.conf" ~/.config/kitty/
    cp "$SCRIPT_DIR/config/polybar/config.ini" ~/.config/polybar/
    cp "$SCRIPT_DIR/config/polybar/launch.sh" ~/.config/polybar/
    cp "$SCRIPT_DIR/config/picom/picom.conf" ~/.config/picom/
    cp "$SCRIPT_DIR/config/rofi/config.rasi" ~/.config/rofi/
    cp "$SCRIPT_DIR/config/rofi/themes/"* ~/.config/rofi/themes/
    cp "$SCRIPT_DIR/config/rofi/scripts/"* ~/.config/rofi/scripts/
    cp "$SCRIPT_DIR/config/wal/templates/"* ~/.config/wal/templates/
    cp "$SCRIPT_DIR/config/gtk-3.0/settings.ini" ~/.config/gtk-3.0/
    cp "$SCRIPT_DIR/config/zsh/.zshrc" ~/
    
    # Copy scripts
    cp "$SCRIPT_DIR/scripts/"* ~/.local/bin/
    
    # Make scripts executable
    chmod +x ~/.config/polybar/launch.sh
    chmod +x ~/.config/rofi/scripts/*
    chmod +x ~/.local/bin/*
    
    print_success "Configuration files installed"
}

# Install fonts
install_fonts() {
    print_status "Installing additional fonts..."
    
    # Create fonts directory
    mkdir -p ~/.local/share/fonts
    
    # Download and install JetBrains Mono Nerd Font if not available
    if ! fc-list | grep -i "jetbrains.*nerd" &> /dev/null; then
        print_status "Downloading JetBrains Mono Nerd Font..."
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
        unzip -q /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/
        fc-cache -fv
        rm /tmp/JetBrainsMono.zip
    fi
}

# Setup shell
setup_shell() {
    print_status "Setting up Zsh and Oh My Zsh..."
    
    # Install Oh My Zsh if not present
    if [[ ! -d ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install zsh plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
    
    # Install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 2>/dev/null || true
    
    # Change default shell to zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_status "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        print_warning "Please log out and back in for shell changes to take effect"
    fi
}

# Setup default wallpaper and theme
setup_theme() {
    print_status "Setting up default theme..."
    
    # Copy default wallpaper
    if [[ -f "$SCRIPT_DIR/wallpapers/default.jpg" ]]; then
        cp "$SCRIPT_DIR/wallpapers/default.jpg" ~/Pictures/wallpapers/
        
        # Generate initial theme
        wal -i ~/Pictures/wallpapers/default.jpg
        
        # Update theme
        ~/.local/bin/theme-update.sh ~/Pictures/wallpapers/default.jpg
    else
        print_warning "No default wallpaper found. Please run theme-update.sh with your wallpaper"
    fi
}

# Setup monitor configuration
setup_monitors() {
    print_status "Setting up monitor configuration..."
    
    # Detect monitors and create autorandr profile
    if command -v autorandr &> /dev/null; then
        print_status "Autorandr available. You can setup monitor profiles with 'autorandr --save <profile-name>'"
    fi
}

# Set file manager as default
setup_file_manager() {
    print_status "Setting Thunar as default file manager..."
    xdg-mime default thunar.desktop inode/directory
}

# Final setup
final_setup() {
    print_status "Performing final setup..."
    
    # Update font cache
    fc-cache -fv
    
    # Set GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
    
    print_success "Setup completed!"
}

# Print post-install instructions
print_instructions() {
    print_success "Installation completed successfully!"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Log out and log back in (or reboot)"
    echo "2. Select i3 as your window manager at login"
    echo "3. Run: ~/.local/bin/theme-update.sh /path/to/your/wallpaper.jpg"
    echo "4. Configure your monitors with autorandr if needed"
    echo "5. Run 'p10k configure' to setup your shell prompt"
    echo
    echo -e "${BLUE}Key bindings:${NC}"
    echo "- \$mod+Return: Open terminal"
    echo "- \$mod+d: App launcher (rofi)"
    echo "- \$mod+Shift+e: Power menu"
    echo "- \$mod+Shift+f: File manager"
    echo "- \$mod+Shift+r: Restart i3"
    echo
    echo -e "${BLUE}Configuration files:${NC}"
    echo "- i3: ~/.config/i3/config"
    echo "- Kitty: ~/.config/kitty/kitty.conf"
    echo "- Polybar: ~/.config/polybar/config.ini"
    echo "- Rofi: ~/.config/rofi/config.rasi"
    echo
    echo -e "${GREEN}Enjoy your new setup!${NC}"
}

# Main execution
main() {
    print_status "Starting i3 + Pywal setup installation..."
    
    check_arch
    install_packages
    create_directories
    backup_configs
    install_configs
    install_fonts
    setup_shell
    setup_file_manager
    setup_theme
    setup_monitors
    final_setup
    print_instructions
}

# Run main function
main "$@"