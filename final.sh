#!/bin/bash

function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

box_out 'Choose tasks from below options!!!' '1.check if server is ready to host the application.' '2.create a dev user.' '3.create a devops user.' '4.add public key to permit access to server.'

read -p 'Option: ' input

if [ $input == "1" ];
then
        which apache2
        if [ $? -eq 0 ]; then
                echo -e -e "\e[32m apache is installed and version is \e[0m" && apache2 -v
        else
                echo -e -e "\e[1;31m apache is not installed and will be installed now \e[0m"
                sudo apt update
                sudo apt install apache2 -y
                echo -e -e "\e[33m ### adjusting firewall to allow apache ### \e[0m"
                sudo ufw allow 'Apache'
        fi
        which mongod
        if [ $? -eq 0 ]; then
                echo -e "\e[32m mongodb is installed and version is \e[0m" && mongod --version
        else
                echo -e "\e[31m mongodb is not installed and will be installed now \e[0m"
                curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
                echo -e "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
                sudo apt update
                sudo apt install mongodb-org -y
                sudo systemctl start mongod.service
                sudo systemctl enable mongod
                echo -e " ####\e[33m mongodb is successfully installed and the version is given below #### \e[0m"
                mongo --eval 'db.runCommand({ connectionStatus: 1 })'
        fi
        which logrotate
        if [ $? -eq 0 ]; then
                echo -e "\e[32m logrotate is installed and version is \e[0m" && logrotate --version
        else
                echo -e "\e[31m logrotate is not installed and will be installed now \e[0m"
                sudo apt update
                sudo apt-get install logrotate -y
        fi
        which iptables
        if [ $? -eq 0 ]; then
                echo -e "\e[32m iptables is installed and version is \e[0m" && iptables --version
        else
                echo -e "\e[31m iptables is not installed and will be installed now \e[0m"
                sudo apt update
                sudo apt-get install iptables -y
                echo -e "\e[33m ### enabling ssh and application ports alone to secure server #### \e[0m"
                iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
                iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

                iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
                iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

                iptables -A INPUT -i eth0 -p tcp --dport 27017 -m state --state NEW,ESTABLISHED -j ACCEPT
                iptables -A OUTPUT -o eth0 -p tcp --sport 27017 -m state --state ESTABLISHED -j ACCEPT

                echo -e "\e[33m ### enable outbound 80 port alone ###"
                iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
                iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT    
        fi
elif [ $input == "2" ];
then
        read -p "Enter username : " username
        read -s -p "Enter password : " password
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo -e "\e[32m $username exists! \e[0m"
                exit 1

        else
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                useradd -m -p "$pass" "$username"
                sudo adduser "$username" dev
                sudo chgrp -R dev /opt/test/sample-web-app
                sudo chmod -R 775 /opt/test/sample-web-app
                sudo setfacl -dR -m g:dev:rwx /opt/test/sample-web-app
                echo -e " add user to adm  group to access logs \e[0m"
                sudo usermod -aG adm "$username"
                [ $? -eq 0 ] && echo -e "User has been added to system and added to dev group!" || echo -e "Failed to add a user!"
        fi

elif [ $input == "3" ];
then
        read -p "Enter username : " username
        read -s -p "Enter password : " password
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo -e "\e[32m $username exists! \e[0m"
                exit 1
        else
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                useradd -m -p "$pass" "$username"
                sudo passwd --expire "$username"
                sudo adduser "$username" devops
                sudo usermod -aG sudo "$username"
                [ $? -eq 0 ] && echo -e "User has been added to system and added to devops group!" || echo -e "Failed to add a user!"    

        fi
elif [ $input == "4" ];
then    
        echo -e -e "\e[32m adding publickey to the authorized_keys \e[0m"
        read -p "Enter publickey : " publickey
        echo -e "$publickey" >> ~/.ssh/authorized_keys

else
        echo -e "Only root may add a user to the system."
        exit 2
fi
