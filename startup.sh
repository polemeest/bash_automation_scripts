#!/bin/bash


# Принт справки помощи
usage() {
  echo "Usage: $0 -p projectname [-s servername] [-c] [-help]"
  echo "  -s servername     Set the server name (default: project)"
  echo "  -p projectname    Set the project name"
  echo "  -c                Include Celery service setup"
  echo "  -h             Print this help message"
  exit 1
}

# Парсит переданные аргументы
CELERY=false
while getopts "cs:p:" opt; do
  case $opt in
    c)
      CELERY=true
      ;;
    s)
      SERVERNAME=$OPTARG
      ;;
    p)
      PROJECTNAME=$OPTARG
      ;;
    h)
      usage
      ;;
    ?)
      usage
      ;;
  esac
done


# Объявление переменных для подстановки
PROJECTFOLDER=$(pwd)
PROJECTNAME=${PROJECTNAME:-project}
SERVERNAME=${SERVERNAME:-_}


# Шаг 0: Конфигурация русской локали
if ! grep -q '^ru_RU.UTF-8' /etc/locale.gen; then
    echo "ru_RU locale is not configured. Configuring..."
    echo 'ru_RU.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen
    sudo locale-gen
    echo "ru_RU locale configured successfully."
else
    echo "ru_RU locale is already configured."
fi

# Шаг 1: Создание юнита для запуска портала
sudo tee /etc/systemd/system/$PROJECTNAME.service > /dev/null <<EOL
[Unit]
Description=Gunicorn instance to serve $PROJECTNAME
After=network.target

[Service]
User=$USER
WorkingDirectory=$PROJECTFOLDER/src
ExecStart=$PROJECTFOLDER/bin/start_gunicorn.sh
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL

# Шаг 2: Создание юнита для запуска селери
if [[ $CELERY = true ]]; then
  sudo tee /etc/systemd/system/celery_$PROJECTNAME.service > /dev/null <<EOL
[Unit]
Description=Celery instance to serve $PROJECTNAME
After=network.target
After=$SERVICE_NAME.service

[Service]
User=$USER
WorkingDirectory=$PROJECTFOLDER/src
ExecStart=$PROJECTFOLDER/bin/start_celery.sh
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL
fi

# Шаг 3: Обновить конфигурацию системного демона
sudo systemctl daemon-reload

# Шаг 4: Установить и обновить конфигурацию Nginx
sudo apt-get install -y nginx

sudo tee /etc/nginx/sites-enabled/$PROJECTNAME > /dev/null <<EOL
server {
    listen 80;
    listen [::]:80;

    root /var/www/html;
    server_name $SERVERNAME;

    location /static/ {
        autoindex on;
        root $PROJECTFOLDER/src;
    }

    location /media/ {
        autoindex on;
        root $PROJECTFOLDER/src;
    }
    
    location / {
        proxy_pass http://127.0.0.1:8005;
        proxy_set_header X-Forwarded-Host \$server_name;
        proxy_set_header X-Real-IP \$remote_addr;
        add_header P3P 'CP="ALL DSP COR PSAa PSDa OUR NOR ONL UNI COM NAV"';
        add_header Access-Control-Allow-Origin *;
    }
}
EOL

sudo systemctl restart nginx

# Шаг 5: Задание прав на выполненияе для скриптов запуска селери и гуникорна
chmod +x ./bin/*

# Шаг 6: Установка сервера редис (очереди для задач)
sudo apt-get update
sudo apt-get install -y redis-server python3-venv

# Шаг 7: создание и запуск виртуального окружения python
python3 -m venv ./venv
source ./venv/bin/activate

# Шаг 8: Устоновка необходимых зависимостей
python -m pip install -r requirements.txt

# Шаг 9: Подстановка пользователя и директории в исполняемые файлы
sed -i "s|<projectfolder>|$PROJECTFOLDER|g" ./bin/start_gunicorn.sh
sed -i "s|<projectfolder>|$PROJECTFOLDER|g" ./bin/start_celery.sh
sed -i "s|<projectfolder>|$PROJECTFOLDER|g" ./src/gunicorn_config.py
sed -i "s|<user>|$USER|g" ./src/gunicorn_config.py

# Шаг 10: Запуск миграций джанго на пустую базу данных
cd ./src
python manage.py makemigrations
python manage.py migrate
python manage.py loaddata fixtures/initial.json
python manage.py collectstatic --noinput

# Шаг 11: Запуск проекта с помощью юнита
sudo systemctl enable celery_$PROJECTNAME
sudo systemctl enable $PROJECTNAME
sudo systemctl start $PROJECTNAME
sudo systemctl start celery_$PROJECTNAME
