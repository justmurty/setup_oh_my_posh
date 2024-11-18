#!/bin/bash

# Define colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

echo -e "${BLUE}First, we need to set it up on the Proxmox node for it to work with containers.${RESET}"

# Prompt user to continue
echo -e -n "${YELLOW}Do you want to continue and set it up on the Proxmox node? (Y/n): ${RESET}"
read confirm
confirm=${confirm:-Y} # Default to Y if empty

if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}Continuing with Proxmox node setup...${RESET}"
else
  echo -e "${RED}The setup cannot proceed without being executed on the Proxmox node.${RESET}"
  echo -e "${RED}Script is stopping.${RESET}"
  exit 1
fi

# Installing required packages
echo -e "${BLUE}Installing required packages: curl, git, zip...${RESET}"
apt update
apt install -y curl git zip fontconfig

# Check and create ~/bin directory
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

# Checking ~/.bash_profile and adding PATH
if ! grep -q 'export PATH=$PATH:~/bin' "$HOME/.bash_profile" 2>/dev/null; then
  echo -e "${YELLOW}Adding PATH to ~/.bash_profile...${RESET}"
  echo 'export PATH=$PATH:~/bin' >> "$HOME/.bash_profile"
  source ~/.bash_profile
else
  echo -e "${GREEN}PATH is already added to ~/.bash_profile.${RESET}"
  source ~/.bash_profile
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
echo -e "${BLUE}Choose a theme from the list:${RESET}"
echo -e "${BLUE}You can check the themes here: https://ohmyposh.dev/docs/themes${RESET}"
if [ ! -d "$HOME/posh-thems" ]; then
  echo -e "${YELLOW}Cloning oh-my-posh themes...${RESET}"
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo -e "${GREEN}oh-my-posh themes are already cloned.${RESET}"
fi

# Displaying the list of themes and selecting one
echo -e "${BLUE}Choose a theme from the list:${RESET}"
theme_dir="$HOME/posh-thems/themes"
themes=($(ls "$theme_dir"))

PS3="$(echo -e ${YELLOW}Select theme number: ${RESET})"
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo -e "${GREEN}You selected theme: $theme${RESET}"
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

# Applying changes
echo -e "${BLUE}Applying changes...${RESET}"
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
  echo -e "${GREEN}Changes applied. To ensure they take effect, restart the terminal or run: source ~/.bash_profile${RESET}"
else
  echo -e "${RED}~/.bash_profile does not exist. Ensure the profile is created.${RESET}"
fi

echo -e "${BLUE}We are ready with the Proxmox node, now starting with all containers.${RESET}"
echo -ne "${YELLOW}Starting in 5 seconds: ${RESET}"
echo ""

# Display progress bar for 5 seconds
progress_bar="===================================================================="
for ((i=1; i<=70; i++)); do
  echo -ne "${YELLOW}${progress_bar:0:$i}\r${RESET}"
  sleep 0.07
done

echo -e "\n${GREEN}Continuing...${RESET}"
echo ""

# Selecting a theme for all containers
echo -e "${BLUE}Choose a theme from the list for containers:${RESET}"
echo -e "${BLUE}You can check the themes here: https://ohmyposh.dev/docs/themes${RESET}"
themes_dir="/root/posh-thems/themes"  # Correct path to themes
themes=($(ls "$themes_dir"))
PS3="$(echo -e ${YELLOW}Select theme number: ${RESET})"
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo -e "${GREEN}You selected theme: $theme${RESET}"
    selected_theme="$themes_dir/$theme"
    break
  else
    echo -e "${RED}Invalid selection. Try again.${RESET}"
  fi
done

# Retrieving the list of containers
echo -e "${BLUE}Retrieving the list of containers...${RESET}"
containers=$(pct list | awk 'NR>1 {print $1}')
if [ -z "$containers" ]; then
  echo -e "${RED}No containers available.${RESET}"
  exit 1
fi

echo -e "${GREEN}Containers found:${RESET}"
echo "$containers"

# Copying setup_oh_my_posh.sh to containers
for container in $containers; do
  echo -e "${YELLOW}Copying setup_oh_my_posh.sh to /root/ on container $container...${RESET}"
  pct push $container ./setup_oh_my_posh.sh /root/setup_oh_my_posh.sh
done

# Choosing action
echo ""
# Choosing an action
echo -e "${YELLOW}Select what you want to do:${RESET}"
echo -e "${BLUE}1) Apply to all containers${RESET}"
echo -e "${BLUE}2) Apply to a specific container${RESET}"
echo -n -e "${YELLOW}Enter your choice (1/2): ${RESET}"
read choice

case $choice in
  1)
    echo -e "${GREEN}Selected: Apply to all containers.${RESET}"
    for container in $containers; do
      echo -e "${YELLOW}Processing container $container...${RESET}"
      pct exec $container -- bash -c "chmod +x /root/setup_oh_my_posh.sh && /root/setup_oh_my_posh.sh $selected_theme"
      echo -e "${GREEN}Processing of container $container is complete.${RESET}"
    done
    ;;
  2)
    read -p "$(echo -e ${YELLOW}Enter container ID: ${RESET})" container
    if [[ "$containers" == *"$container"* ]]; then
      echo -e "${YELLOW}Processing container $container...${RESET}"
      pct exec $container -- bash -c "chmod +x /root/setup_oh_my_posh.sh && /root/setup_oh_my_posh.sh $selected_theme"
      echo -e "${GREEN}Processing of container $container is complete.${RESET}"
    else
      echo -e "${RED}Container with ID $container not found.${RESET}"
    fi
    ;;
  *)
    echo -e "${RED}Invalid choice. Script is stopping.${RESET}"
    exit 1
    ;;
esac

echo -e "${GREEN}Script is complete.${RESET}"
