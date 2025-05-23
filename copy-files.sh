# Create your dotfiles repository structure
mkdir -p ~/Documents/Github/i3-dotfiles/{config/{i3,kitty,polybar,picom,rofi/{themes,scripts},wal/templates,gtk-3.0,zsh},scripts,wallpapers}

# Copy your current configs
cp ~/.config/i3/config ~/Documents/Github/i3-dotfiles/config/i3/
cp ~/.config/kitty/kitty.conf ~/Documents/Github/i3-dotfiles/config/kitty/
cp ~/.config/polybar/config.ini ~/Documents/Github/i3-dotfiles/config/polybar/
cp ~/.config/polybar/launch.sh ~/Documents/Github/i3-dotfiles/config/polybar/
cp ~/.config/picom/picom.conf ~/Documents/Github/i3-dotfiles/config/picom/
cp ~/.config/rofi/config.rasi ~/Documents/Github/i3-dotfiles/config/rofi/
cp ~/.config/rofi/themes/* ~/Documents/Github/i3-dotfiles/config/rofi/themes/
cp ~/.config/rofi/scripts/* ~/Documents/Github/i3-dotfiles/config/rofi/scripts/
cp ~/.config/wal/templates/* ~/Documents/Github/i3-dotfiles/config/wal/templates/
cp ~/.config/gtk-3.0/settings.ini ~/Documents/Github/i3-dotfiles/config/gtk-3.0/
cp ~/.zshrc ~/Documents/Github/i3-dotfiles/config/zsh/
cp ~/.local/bin/theme-update.sh ~/Documents/Github/i3-dotfiles/scripts/

# Add a default wallpaper (replace with your favorite wallpaper path)
cp /path/to/your/favorite/wallpaper.jpg ~/Documents/Github/i3-dotfiles/wallpapers/default.jpg

# Navigate to your dotfiles directory
cd ~/Documents/Github/i3-dotfiles

# Initialize git repository if not already done
git init
git add .
git commit -m "Initial commit: Complete i3 + pywal setup"