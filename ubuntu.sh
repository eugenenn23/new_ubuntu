#!/bin/bash

start=`date +%s`
Nc='\033[0m'     # Text Reset
Red='\033[0;31m'  # Red
Green='\033[0;32m' # Green

echo -e "\n${Green} sudo apt update && sudo apt upgrade -y ${Nc}\n"
sleep 1
sudo apt update && sudo apt upgrade -y

echo -e "\n ${Green} sudo apt install mc htop fail2ban screen sysbench -y ${Nc}\n"
sleep 1
sudo apt install mc htop fail2ban screen sysbench -y

# https://blog.programs74.ru/configure-history-in-linux/
echo -e "\n${Green} Configure history ${Nc}\n"
sed -i "s/^HISTSIZE=.*/HISTSIZE=9000/" ~/.bashrc
sed -i "s/^HISTFILESIZE=.*/HISTFILESIZE=9000/" ~/.bashrc
echo "PROMPT_COMMAND='history -a'" >> ~/.bashrc
source ~/.bashrc
sleep 1


echo -e "\n${Green} Create file /etc/fail2ban/jail.local ${Nc}\n"
sudo tee <<EOF >/dev/null /etc/fail2ban/jail.local
[sshd]
enabled   = true
maxretry  = 3
findtime  = 1d
bantime   = 40w
ignoreip  = 127.0.0.1/8
EOF
echo -e "\n${Green} systemctl status fail2ban ${Nc}\n"
systemctl enable fail2ban
sleep 1
systemctl restart fail2ban
sleep 1
echo -e "\n${Green} fail2ban-client status sshd ${Nc}\n"
fail2ban-client status sshd
sleep 1


echo -e "\n${Green} Configure journalctl ${Nc}\n"
journalctl --verify
journalctl --vacuum-size=100M
sed -i 's/^#SystemMaxUse=.*$/SystemMaxUse=100M/' /etc/systemd/journald.conf
systemctl restart systemd-journald
sleep 1


echo -e "\n${Green} curl -sL yabs.sh | bash -s -- -ig ${Nc}\n"
curl -sL yabs.sh | bash -s -- -ig
sysbench cpu run | grep "Number of threads\|events per second"
sysbench cpu run --threads=32| grep "Number of threads\|events per second"


end=`date +%s`
runtime=$((end-start))
echo "runtime         | $runtime"

