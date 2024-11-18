#!/bin/bash

# Checking for theme argument
if [ -z "$1" ]; then
  echo "No theme provided. Use: ./setup_oh_my_posh.sh <path_to_theme>"
  exit 1
fi

theme="$1"

# Installing required packages
echo "Installing required packages: curl, git, zip..."
apt update
apt install -y curl git zip fontconfig

# Checking and creating ~/bin directory
if [ ! -d "$HOME/bin" ]; then
  echo "Creating ~/bin directory..."
  mkdir -p "$HOME/bin"
else
  echo "~/bin directory already exists."
fi

# Installing oh-my-posh
if [ ! -f "$HOME/bin/oh-my-posh" ]; then
  echo "Installing oh-my-posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
else
  echo "oh-my-posh is already installed."
fi

# Checking for ~/.bash_profile and adding PATH
if ! grep -q 'export PATH=$PATH:~/bin' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Adding PATH to ~/.bash_profile..."
  echo 'export PATH=$PATH:~/bin' >> "$HOME/.bash_profile"
fi

# Checking and installing JetBrainsMono font
font_installed=$(fc-list | grep -i "JetBrainsMono" | wc -l)
if [ "$font_installed" -eq 0 ]; then
  echo "Installing JetBrainsMono font..."
  oh-my-posh font install JetBrainsMono
else
  echo "JetBrainsMono font is already installed."
fi

# Cloning oh-my-posh themes
if [ ! -d "$HOME/posh-thems" ]; then
  echo "Cloning oh-my-posh themes..."
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo "oh-my-posh themes are already cloned."
fi

# Adding or updating eval in ~/.bash_profile
eval_line="eval \"\$(oh-my-posh init bash --config $theme)\""
if grep -q 'oh-my-posh init bash --config' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Updating eval command in ~/.bash_profile..."
  sed -i "/oh-my-posh init bash --config/c\\$eval_line" "$HOME/.bash_profile"
else
  echo "Adding eval command to ~/.bash_profile..."
  echo "$eval_line" >> "$HOME/.bash_profile"
fi

echo "oh-my-posh configuration has been updated with theme: $theme."

# Applying changes
echo "Applying changes..."
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
  echo "Changes applied. To ensure they take effect, restart the terminal or run: source ~/.bash_profile"
else
  echo "~/.bash_profile does not exist. Ensure the profile is created."
fi
