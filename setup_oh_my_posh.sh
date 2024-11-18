#!/bin/bash

# Проверка за аргумент за тема
if [ -z "$1" ]; then
  echo "Не е предоставена тема. Използвайте: ./setup_oh_my_posh.sh <path_to_theme>"
  exit 1
fi

theme="$1"

# Инсталиране на необходимите пакети
echo "Инсталирам необходими пакети: curl, git, zip..."
apt update
apt install -y curl git zip fontconfig

# Проверка и създаване на директория ~/bin
if [ ! -d "$HOME/bin" ]; then
  echo "Създавам директория ~/bin..."
  mkdir -p "$HOME/bin"
else
  echo "Директория ~/bin вече съществува."
fi

# Инсталиране на oh-my-posh
if [ ! -f "$HOME/bin/oh-my-posh" ]; then
  echo "Инсталирам oh-my-posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
else
  echo "oh-my-posh вече е инсталиран."
fi

# Проверка за ~/.bash_profile и добавяне на PATH
if ! grep -q 'export PATH=$PATH:~/bin' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Добавям PATH в ~/.bash_profile..."
  echo 'export PATH=$PATH:~/bin' >> "$HOME/.bash_profile"
fi

# Проверка и инсталиране на шрифт JetBrainsMono
font_installed=$(fc-list | grep -i "JetBrainsMono" | wc -l)
if [ "$font_installed" -eq 0 ]; then
  echo "Инсталирам шрифт JetBrainsMono..."
  oh-my-posh font install JetBrainsMono
else
  echo "Шрифтът JetBrainsMono вече е инсталиран."
fi

# Клониране на oh-my-posh теми
if [ ! -d "$HOME/posh-thems" ]; then
  echo "Клонирам oh-my-posh теми..."
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo "oh-my-posh темите вече са клонирани."
fi

# Добавяне или актуализиране на eval в ~/.bash_profile
eval_line="eval \"\$(oh-my-posh init bash --config $theme)\""
if grep -q 'oh-my-posh init bash --config' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Актуализирам eval командата в ~/.bash_profile..."
  sed -i "/oh-my-posh init bash --config/c\\$eval_line" "$HOME/.bash_profile"
else
  echo "Добавям eval команда в ~/.bash_profile..."
  echo "$eval_line" >> "$HOME/.bash_profile"
fi

echo "Конфигурацията на oh-my-posh е обновена с тема: $theme."

# Приложение на промените
echo "Прилагам промените..."
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
  echo "Промените са приложени. За да сте сигурни, рестартирайте терминала или изпълнете: source ~/.bash_profile"
else
  echo "~/.bash_profile не съществува. Уверете се, че сте създали профила."
fi
