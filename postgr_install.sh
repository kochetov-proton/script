#!/bin/bash

# Функция чтения
read_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    read -p "$prompt [$default]: " input
    eval $var_name="${input:-$default}"
}

echo "--- Настройка параметров PostgreSQL ---"

read_with_default "Введите имя базы данных" "my_database" DB_NAME
read_with_default "Введите имя пользователя" "my_user" DB_USER
read_with_default "Введите пароль" "StrongPassword123" DB_PASS
read_with_default "Введите версию PostgreSQL" "16" PG_VERSION

sudo apt update && sudo apt install -y gnupg wget
wget --quiet -O - https://postgresql.org | sudo apt-key add -
echo "deb http://postgresql.org $(lsb_release -cs)-pgdg main" | sudo tee /etc/postgresql/apt.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-$PG_VERSION postgresql-contrib-$PG_VERSION

# Настройка конфигов
CONF_FILE="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $CONF_FILE

echo "host    all             all             0.0.0.0/0               scram-sha-256" | sudo tee -a $HBA_FILE

sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
sudo -u postgres psql -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"

# Разрешаем подключение, если есть фаервол
sudo ufw allow 5432/tcp
sudo systemctl restart postgresql

echo -e "\n Параметры подключения:"
echo "Host: $(hostname -I | awk '{print $1}')"
echo "Port: 5432"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Password: $DB_PASS"
