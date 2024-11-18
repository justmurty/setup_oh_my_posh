#!/bin/bash

echo "Първо трябва да го направим на Proxmox node, за да работи за контейнерите."

read -p "Искате ли да продължите и да го настроим на Proxmox node? (Y/n): " confirm
confirm=${confirm:-Y} # Задава Y по подразбиране, ако е празно

if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "Продължаваме с настройките на Proxmox node..."
else
  echo "Настройката не може да продължи без да се изпълни на Proxmox node."
  echo "Скриптът спира."
  exit 1
fi

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
  source ~/.bash_profile
else
  echo "PATH вече е добавен в ~/.bash_profile."
  source ~/.bash_profile
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
echo "Изберете тема от списъка:"
echo "Може да проверите темите тук: https://ohmyposh.dev/docs/themes"
if [ ! -d "$HOME/posh-thems" ]; then
  echo "Клонирам oh-my-posh теми..."
  git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/posh-thems"
else
  echo "oh-my-posh темите вече са клонирани."
fi

# Показване на списъка с теми и избор
echo "Изберете тема от списъка:"
theme_dir="$HOME/posh-thems/themes"
themes=($(ls "$theme_dir"))

PS3="Изберете номер на тема: "
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo "Избрахте тема: $theme"
    break
  else
    echo "Невалиден избор. Опитайте отново."
  fi
done

# Добавяне или актуализиране на eval в ~/.bash_profile
eval_line="eval \"\$(oh-my-posh init bash --config $theme_dir/$theme)\""
if grep -q 'oh-my-posh init bash --config' "$HOME/.bash_profile" 2>/dev/null; then
  echo "Актуализирам eval командата в ~/.bash_profile..."
  sed -i "/oh-my-posh init bash --config/c\\$eval_line" "$HOME/.bash_profile"
else
  echo "Добавям eval команда в ~/.bash_profile..."
  echo "$eval_line" >> "$HOME/.bash_profile"
fi

# Приложение на промените
echo "Прилагам промените..."
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
  echo "Промените са приложени. За да сте сигурни, рестартирайте терминала или изпълнете: source ~/.bash_profile"
else
  echo "~/.bash_profile не съществува. Уверете се, че сте създали профила."
fi

echo "Готови сме с Proxmox node, сега започваме за всичките контейнери."
echo -n "Ще започнем след 5 секунди: "
echo ""

# Показва прогрес бар за 5 секунди
progress_bar="===================================================================="
for ((i=1; i<=70; i++)); do
  echo -ne "${progress_bar:0:$i}\r"
  sleep 0.07
done

echo -e "\nПродължаваме..."

# Избиране на тема за всички контейнери
echo "Изберете тема от списъка:"
echo "Може да проверите темите тук: https://ohmyposh.dev/docs/themes"
themes_dir="/root/posh-thems/themes"  # Коригиран път към темите
themes=($(ls "$themes_dir"))
PS3="Изберете номер на тема: "
select theme in "${themes[@]}"; do
  if [ -n "$theme" ]; then
    echo "Избрахте тема: $theme"
    selected_theme="$themes_dir/$theme"
    break
  else
    echo "Невалиден избор. Опитайте отново."
  fi
done

# Извличане на списъка с контейнери
echo "Извличане на списъка с контейнери..."
containers=$(pct list | awk 'NR>1 {print $1}')
if [ -z "$containers" ]; then
  echo "Няма налични контейнери."
  exit 1
fi

echo "Намерени контейнери:"
echo "$containers"

# Избор на действие
echo ""
echo "Изберете какво искате да направите:"
echo "1) Приложи към всички контейнери"
echo "2) Приложи към специфичен контейнер"
read -p "Въведете номера на избора си (1/2): " choice

case $choice in
  1)
    echo "Избрано е: Приложи към всички контейнери."
    for container in $containers; do
      echo "Обработка на контейнер $container..."
      pct exec $container -- bash -c "chmod +x /root/setup_oh_my_posh.sh && /root/setup_oh_my_posh.sh $selected_theme"
      echo "Обработката на контейнер $container завърши."
    done
    ;;
  2)
    read -p "Въведете ID на контейнера: " container
    if [[ "$containers" == *"$container"* ]]; then
      echo "Обработка на контейнер $container..."
      pct exec $container -- bash -c "chmod +x /root/setup_oh_my_posh.sh && /root/setup_oh_my_posh.sh $selected_theme"
      echo "Обработката на контейнер $container завърши."
    else
      echo "Контейнер с ID $container не е намерен."
    fi
    ;;
  *)
    echo "Невалиден избор. Скриптът приключва."
    exit 1
    ;;
esac

echo "Скриптът приключи."
