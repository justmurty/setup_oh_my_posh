#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Installing required packages
echo -e "${YELLOW}Installing required packages: curl, git, zip...${RESET}"
apt update
apt install -y curl git zip fontconfig

# Checking and creating ~/bin directory
if [ ! -d "$HOME/bin" ]; then
  echo -e "${GREEN}Creating ~/bin directory...${RESET}"
  mkdir -p "$HOME/bin"
else
  echo -e "${BLUE}~/bin directory already exists.${RESET}"
fi

# Installing oh-my-posh
if [ ! -f "$HOME/bin/oh-my-posh" ]; then
  echo -e "${YELLOW}Installing oh-my-posh...${RESET}"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
else
  echo -e "${CYAN}oh-my-posh is already installed.${RESET}"
fi

# Checking for ~/.bash_profile and adding PATH
if ! grep -q 'export PATH=$PATH:~/bin' "$HOME/.bash_profile" 2>/dev/null; then
  echo -e "${YELLOW}Adding PATH to ~/.bash_profile...${RESET}"
  echo 'export PATH=$PATH:~/bin' >> "$HOME/.bash_profile"
  source ~/.bash_profile
else
  echo -e "${BLUE}PATH is already added to ~/.bash_profile.${RESET}"
  source ~/.bash_profile
fi

# Checking and installing JetBrainsMono font
font_installed=$(fc-list | grep -i "JetBrainsMono" | wc -l)
if [ "$font_installed" -eq 0 ]; then
  echo -e "${YELLOW}Installing JetBrainsMono font...${RESET}"
  oh-my-posh font install JetBrainsMono
else
  echo -e "${CYAN}JetBrainsMono font is already installed.${RESET}"
fi

# Cloning oh-my-posh themes
echo -e "${BLUE}You can check the themes here: https://ohmyposh.dev/docs/themes${RESET}"
echo ""
if [ ! -d "$HOME/posh-thems" ]; then
  echo -e "${YELLOW}Cloning oh-my-posh themes...${RESET}"
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo -e "${CYAN}oh-my-posh themes are already cloned.${RESET}"
fi

# Displaying the list of themes and selection
echo -e "${YELLOW}Choose a theme from the list:${RESET}"
theme_dir="$HOME/posh-thems/themes"
themes=($(ls "$theme_dir"))

PS3="$(echo -e ${CYAN}Select a theme number: ${RESET})"
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo -e "${GREEN}You selected the theme: $theme${RESET}"
    break
  else
    echo -e "${RED}Invalid selection. Try again.${RESET}"
  fi
done

# Adding or updating eval in ~/.bash_profile
eval_line="eval \"\$(oh-my-posh init bash --config $theme_dir/$theme)\""
if grep -q 'oh-my-posh init bash --config' "$HOME/.bash_profile" 2>/dev/null; then
  echo -e "${YELLOW}Updating eval command in ~/.bash_profile...${RESET}"
  sed -i "/oh-my-posh init bash --config/c\\$eval_line" "$HOME/.bash_profile"
else
  echo -e "${YELLOW}Adding eval command to ~/.bash_profile...${RESET}"
  echo "$eval_line" >> "$HOME/.bash_profile"
fi

# Asking whether to execute source ~/.bash_profile
echo -e -n "${CYAN}Do you want to apply the changes immediately? (Y/n): ${RESET}"
read apply_changes
apply_changes=${apply_changes:-Y} # Default to Y if empty

if [[ "$apply_changes" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Applying changes...${RESET}"
  if [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
    echo -e "${GREEN}Changes have been applied. To ensure they take effect, restart the terminal or run: source ~/.bash_profile${RESET}"
  else
    echo -e "${RED}~/.bash_profile does not exist. Ensure the profile is created.${RESET}"
  fi
else
  echo -e "${YELLOW}To apply the changes manually, run:${RESET}"
  echo -e "${CYAN}source ~/.bash_profile${RESET}"
fi
