# Oh-My-Posh Configuration for Proxmox Containers

This project provides scripts to automate the installation and configuration of **Oh-My-Posh** across all containers in a Proxmox environment.

---

## Features

1. **Scripts:**
   - `setup_oh_my_posh.sh`: Installs and configures **Oh-My-Posh** in a single container.
   - `run_on_all_containers.sh`: Executes `setup_oh_my_posh.sh` across all or selected containers in Proxmox.

2. **Functionality:**
   - Installs required packages (`curl`, `git`, `zip`, `fontconfig`).
   - Downloads and sets up **Oh-My-Posh** in containers.
   - Configures the **JetBrainsMono** font for proper rendering.
   - Applies a user-selected theme to all containers automatically without additional prompts.

3. **Supported Environment:**
   - Works exclusively with Proxmox containers (LXC) and not virtual machines.
   - Testet and work only on Debian and Ubuntu.

---

## Installation Instructions

1. Ensure you are logged in to the Proxmox node as `root`.

2. Install `wget` (if not already installed):
   ```bash
   apt install wget

3. Install scripts and run.
   ```bash
   wget https://raw.githubusercontent.com/justmurty/setup_oh_my_posh/refs/heads/proxmox/run_on_all_containers.sh
   wget https://raw.githubusercontent.com/justmurty/setup_oh_my_posh/refs/heads/proxmox/setup_oh_my_posh.sh
   chmod +x setup_oh_my_posh.sh && chmod +x run_on_all_containers.sh
   ./run_on_all_containers.sh
