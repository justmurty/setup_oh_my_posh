#!/bin/bash

echo "First, we need to set it up on the Proxmox node for it to work with containers."

read -p "Do you want to continue and set it up on the Proxmox node? (Y/n): " confirm
confirm=${confirm:-Y} # Default to Y if empty

if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "Continuing with Proxmox node setup..."
else
  echo "The setup cannot proceed without being executed on the Proxmox node."
  echo "Script is stopping."
  exit 1
fi

# Installing required packages
echo "Installing required packages: curl, git, zip..."
apt update
apt install -y curl git zip fontconfig

# Check and create ~/bin directory
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

# Checking ~/.bash_profile and adding PATH
if ! grep -q 'export PATH=$PATH:~/bin' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Adding PATH to ~/.bash_profile..."
  echo 'export PATH=$PATH:~/bin' >> "$HOME/.bash_profile"
  source ~/.bash_profile
else
  echo "PATH is already added to ~/.bash_profile."
  source ~/.bash_profile
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
echo "Choose a theme from the list:"
echo "You can check the themes here: https://ohmyposh.dev/docs/themes"
if [ ! -d "$HOME/posh-thems" ]; then
  echo "Cloning oh-my-posh themes..."
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo "oh-my-posh themes are already cloned."
fi

# Displaying the list of themes and selecting one
echo "Choose a theme from the list:"
theme_dir="$HOME/posh-thems/themes"
themes=($(ls "$theme_dir"))

PS3="Select theme number: "
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo "You selected theme: $theme"
    break
  else
    echo "Invalid selection. Try again."
  fi
done

# Adding or updating eval in ~/.bash_profile
eval_line="eval \"\$(oh-my-posh init bash --config $theme_dir/$theme)\""
if grep -q 'oh-my-posh init bash --config' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Updating eval command in ~/.bash_profile..."
  sed -i "/oh-my-posh init bash --config/c\\$eval_line" "$HOME/.bash_profile"
else
  echo "Adding eval command to ~/.bash_profile..."
  echo "$eval_line" >> "$HOME/.bash_profile"
fi

# Applying changes
echo "Applying changes..."
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
  echo "Changes applied. To ensure they take effect, restart the terminal or run: source ~/.bash_profile"
else
  echo "~/.bash_profile does not exist. Ensure the profile is created."
fi

echo "We are ready with the Proxmox node, now starting with all containers."
echo -n "Starting in 5 seconds: "
echo ""

# Display progress bar for 5 seconds
progress_bar="===================================================================="
for ((i=1; i<=70; i++)); do
  echo -ne "${progress_bar:0:$i}\r"
  sleep 0.07
done

echo -e "\nContinuing..."
echo " "
# Selecting a theme for all containers
echo "Choose a theme from the list for containers:"
echo "You can check the themes here: https://ohmyposh.dev/docs/themes"
themes_dir="/root/posh-thems/themes"  # Correct path to themes
themes=($(ls "$themes_dir"))
PS3="Select theme number: "
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo "You selected theme: $theme"
    selected_theme="$themes_dir/$theme"
    break
  else
    echo "Invalid selection. Try again."
  fi
done

# Retrieving the list of containers
echo "Retrieving the list of containers..."
containers=$(pct list | awk 'NR>1 {print $1}')
if [ -z "$containers" ]; then
  echo "No containers available."
  exit 1
fi

echo "Containers found:"
echo "$containers"

# Copying setup_oh_my_posh.sh to containers
for container in $containers; do
  echo "Copying setup_oh_my_posh.sh to /root/ on container $container..."
  pct push $container ./setup_oh_my_posh.sh /root/setup_oh_my_posh.sh
done

# Choosing action
echo ""
echo "Select what you want to do:"
echo "1) Apply to all containers"
echo "2) Apply to a specific container"
read -p "Enter your choice (1/2): " choice

case $choice in
  1)
    echo "Selected: Apply to all containers."
    for container in $containers; do
      echo "Processing container $container..."
      pct exec $container -- bash -c "chmod +x /root/setup_oh_my_posh.sh && /root/setup_oh_my_posh.sh $selected_theme"
      echo "Processing of container $container is complete."
    done
    ;;
  2)
    read -p "Enter container ID: " container
    if [[ "$containers" == *"$container"* ]]; then
      echo "Processing container $container..."
      pct exec $container -- bash -c "chmod +x /root/setup_oh_my_posh.sh && /root/setup_oh_my_posh.sh $selected_theme"
      echo "Processing of container $container is complete."
    else
      echo "Container with ID $container not found."
    fi
    ;;
  *)
    echo "Invalid choice. Script is stopping."
    exit 1
    ;;
esac

echo "Script is complete."
