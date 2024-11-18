# Setup Oh My Posh

This script automates the installation and configuration of **Oh My Posh** on Debian-based Linux distributions.

## What Does the Script Do?

1. **Installs required packages**:
   - `curl`
   - `git`
   - `zip`
   - `fontconfig` (for font management)
2. **Creates the `~/bin` directory** for installing Oh My Posh.
3. **Installs Oh My Posh** in the `~/bin` directory.
4. **Adds `~/bin` to PATH** in `~/.bash_profile`, if not already added.
5. **Installs the JetBrainsMono font**, if not already installed.
6. **Clones the Oh My Posh themes repository**.
7. **Displays a list of available themes** and allows you to select one.
8. **Adds or updates the configuration** in `~/.bash_profile` to load the selected theme.
9. **Prompts to apply changes immediately** by running `source ~/.bash_profile`.

## How to Use the Script?

1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/justmurty/setup_oh_my_posh/refs/heads/main/setup_oh_my_posh.sh
   chmod +x setup_oh_my_posh.sh
   ./setup_oh_my_posh.sh
