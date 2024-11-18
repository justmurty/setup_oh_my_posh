#!/bin/bash

# Извличане на списъка с контейнери
echo "Извличане на списъка с контейнери..."
containers=$(pct list | awk 'NR>1 {print $1}')
if [ -z "$containers" ]; then
  echo "Няма налични контейнери."
  exit 1
fi

echo "Намерени контейнери:"
echo "$containers"

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
