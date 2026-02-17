#!/bin/bash

sudo apt update​
sudo apt install -y curl openssh-server ca-certificates tzdata perl postfix​

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

sudo EXTERNAL_URL= "$(hostname -I | awk '{print $1}')" apt install gitlab-ce​​

sudo cat /etc/gitlab/initial_root_password​
