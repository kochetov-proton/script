#!/bin/bash

read_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    read -p "$prompt [$default]: " input
    eval $var_name="${input:-$default}"
}

echo "--- Настройка параметров PostgreSQL ---"
read_with_default "Введите имя базы данных" "forgrafana" DB_NAME
read_with_default "Введите имя пользователя" "user" DB_USER
read_with_default "Введите пароль" "enterenter" DB_PASS
read_with_default "Введите версию PostgreSQL" "16" PG_VERSION

# 1. Установка ключа и репозитория 
sudo apt update
sudo apt install -y curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://postgresql.org

echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] http://postgresql.org $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# 2. Установка
sudo apt update
sudo apt install -y postgresql-$PG_VERSION postgresql-contrib-$PG_VERSION

# 3. Проверка пути и настройка (версии могут иметь разные пути)
CONF_FILE="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

if [ -f "$CONF_FILE" ]; then
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $CONF_FILE
    echo "host    all             all             0.0.0.0/0               scram-sha-256" | sudo tee -a $HBA_FILE
else
    echo "Ошибка: Файл конфигурации не найден. Проверьте установку."
    exit 1
fi

# 4. Создание БД и юзера
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
sudo -u postgres psql -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"

# 5. Финализация
sudo ufw allow 5432/tcp
sudo systemctl restart postgresql

echo -e "\n Установка завершена!"
echo "Host: $(hostname -I | awk '{print $1}')"
echo "Port: 5432"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Password: $DB_PASS"
