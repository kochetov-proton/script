#!/bin/bash

sudo apt update
sudo apt install -y curl openssh-server ca-certificates tzdata perl postfix

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

#  Установка с автоматическим определением IP (БЕЗ пробела после =)
CURRENT_IP=$(hostname -I | awk '{print $1}')
sudo EXTERNAL_URL="http://$CURRENT_IP" apt install gitlab-ce

echo "--------------------------------------------------------"
echo "Установка завершена! Логин: root"
echo "Ваш временный пароль находится ниже:"
sudo cat /etc/gitlab/initial_root_password
