#!/bin/bash

# Define colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Checking for theme argument
if [ -z "$1" ]; then
  echo -e "${RED}No theme provided. Use: ./setup_oh_my_posh.sh <path_to_theme>${RESET}"
  exit 1
fi

theme="$1"

# Installing required packages
echo -e "${BLUE}Installing required packages: curl, git, zip...${RESET}"
apt update
apt install -y curl git zip fontconfig

# Checking and creating ~/bin directory
if [ ! -d "$HOME/bin" ]; then
  echo -e "${YELLOW}Creating ~/bin directory...${RESET}"
  mkdir -p "$HOME/bin"
else
  echo -e "${GREEN}~/bin directory already exists.${RESET}"
fi

# Installing oh-my-posh
if [ ! -f "$HOME/bin/oh-my-posh" ]; then
  echo -e "${YELLOW}Installing oh-my-posh...${RESET}"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
else
  echo -e "${GREEN}oh-my-posh is already installed.${RESET}"
fi

# Checking for ~/.bash_profile and adding PATH
if ! grep -q 'export PATH=$PATH:~/bin' "$HOME/.bash_profile" 2>/dev/null; then
  echo -e "${YELLOW}Adding PATH to ~/.bash_profile...${RESET}"
  echo 'export PATH=$PATH:~/bin' >> "$HOME/.bash_profile"
else
  echo -e "${GREEN}PATH is already added to ~/.bash_profile.${RESET}"
fi

# Checking and installing JetBrainsMono font
font_installed=$(fc-list | grep -i "JetBrainsMono" | wc -l)
if [ "$font_installed" -eq 0 ]; then
  echo -e "${YELLOW}Installing JetBrainsMono font...${RESET}"
  oh-my-posh font install JetBrainsMono
else
  echo -e "${GREEN}JetBrainsMono font is already installed.${RESET}"
fi

# Cloning oh-my-posh themes
if [ ! -d "$HOME/posh-thems" ]; then
  echo -e "${YELLOW}Cloning oh-my-posh themes...${RESET}"
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo -e "${GREEN}oh-my-posh themes are already cloned.${RESET}"
fi

# Adding or updating eval in ~/.bash_profile
eval_line="eval \"\$(oh-my-posh init bash --config $theme)\""
if grep -q 'oh-my-posh init bash --config' "$HOME/.bash_profile" 2>/dev/null; then
  echo -e "${YELLOW}Updating eval command in ~/.bash_profile...${RESET}"
  sed -i "/oh-my-posh init bash --config/c\\$eval_line" "$HOME/.bash_profile"
else
  echo -e "${YELLOW}Adding eval command to ~/.bash_profile...${RESET}"
  echo "$eval_line" >> "$HOME/.bash_profile"
fi

echo -e "${GREEN}oh-my-posh configuration has been updated with theme: $theme.${RESET}"

# Applying changes
echo -e "${BLUE}Applying changes...${RESET}"
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
  echo -e "${GREEN}Changes applied. To ensure they take effect, restart the terminal or run: source ~/.bash_profile${RESET}"
else
  echo -e "${RED}~/.bash_profile does not exist. Ensure the profile is created.${RESET}"
fi
