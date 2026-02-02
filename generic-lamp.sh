#!/usr/bin/bash

# Generic Lamp
# BASH script for configuring a generic LAMP stack
# By Nicholas Grogg
# Revision: 20260201

# Set exit on error
set -e

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)

# Help function
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "configure/Configure" \
    "* Configure generic LAMP stack" \
    "* Takes a DEB or RPM as an argument" \
    "Ex. ./generic-lamp.sh configure DEB" \
    " " \
    "User will need root (sudo) perms"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Configure" \
    "----------------------------------------------------" \
    " "

    ### Value confirmation before proceeding
    printf "%s\n" \
    "IMPORTANT: Value confirmation" \
    "----------------------------------------------------" \
    "Server Distro Type: " "$1" \
    " " \
    "If all clear press enter to proceed or ctrl-c to cancel " \
    " "

    read junkInput

    ### Check Distro type, make distro specific changes
    printf "%s\n" \
    "Confirming passed Distro" \
    "----------------------------------------------------" \
    " "

    case "$1" in
            [Dd][Ee][Bb])
                    printf "%s\n" \
                    "DEB based distro" \
                    "----------------------------------------------------" \
                    " "

                    #### Validation, check for apt
                    if [[ ! -f /usr/bin/apt ]]; then
                        printf "%s\n" \
                        "${red}ISSUE DETECTED: Apt not found!" \
                        "----------------------------------------------------" \
                        "Review server or double check passed arguments"
                        exit 1
                    fi

                    #### Check for updates
                    sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

                    #### Install Apache + certbot for SSL + modsecurity
                    sudo apt install -y \
                        apache2 \
                        certbot \
                        libapache2-mod-security2 \
                        python3-certbot-apache

                    #TODO: Adjust for use case as needed
                    #### Install commonly used software
                    sudo apt install -y \
                        bash-completion \
                        curl \
                        fail2ban \
                        htop \
                        logrotate \
                        net-tools \
                        rsyslog \
                        unattended-upgrades \
                        vim \
                        vim-nox \
                        wget

                    #### Configure unattended upgrades, -p medium should skip low priority questions
                    sudo dpkg-reconfigure -pmedium unattended-upgrades

                    ##### Enable Apache + modsecurity header
                    sudo systemctl enable apache2
                    sudo a2enmod headers
                    sudo systemctl start apache2

                    #### Install/configure MariaDB
                    sudo apt install -y \
                        mariadb-client \
                        mariadb-common \
                        mariadb-server

                    ##### Enable MariaDB
                    sudo systemctl enable mariadb
                    sudo systemctl start mariadb

                    ##### Configure MariaDB
                    sudo mariadb-secure-installation

                    #### Enable fail2ban, by default requires rsyslog
                    sudo systemctl enable rsyslog
                    sudo systemctl start rsyslog
                    sudo systemctl enable fail2ban
                    sudo systemctl start fail2ban

                    #### Install Firewall
                    sudo apt install ufw -y

                    ##### Configure firewall for port 22, 80, 443 and 3306
                    sudo ufw allow 'WWW Full'

                    #### Install PHP + PHP-FPM + basic MariaDB library + php Apache library
                    sudo apt install -y \
                        libapache2-mod-php \
                        php \
                        php-cgi \
                        php-cli \
                        php-common \
                        php-fpm \
                        php-mysql

                    sudo systemctl enable php-fpm
                    sudo a2enmod php
                    sudo systemctl restart apache2

                    ;;
            [Rr][Pp][Mm])
                    printf "%s\n" \
                    "RPM based distro" \
                    "----------------------------------------------------" \
                    " "
                    #### Validation, check for dnf
                    if [[ ! -f /usr/bin/dnf ]]; then
                        printf "%s\n" \
                        "${red}ISSUE DETECTED: DNF not found!" \
                        "----------------------------------------------------" \
                        "Review server or double check passed arguments"
                        exit 1
                    fi

                    #### DNF enable parallel downloads
                    echo "max_parallel_downloads=20" >> /etc/dnf.conf
                    echo "fastestmirror=True" >> /etc/dnf.conf

                    #### Check for updates
                    sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y

                    #TODO Adjust for use case as needed
                    #### Enable repos
                    ##### Enable EPEL repo
                    sudo dnf install epel-release -y

                    #### Install commonly used software
                    sudo dnf install -y \
                        curl \
                        dnf-automatic \
                        fail2ban \
                        firewalld \
                        nmap \
                        vim \
                        wget

                    #### Install Apache + modsecurity
                    sudo dnf install -y \
                        httpd \
                        mod_security

                    ##### Enable Apache
                    sudo systemctl enable httpd
                    sudo systemctl start httpd

                    #### Install  or MariaDB based on databaseTech
                    sudo dnf install mariadb mariadb-common mariadb-server -y

                    ##### Enable MariaDB
                    sudo systemctl enable mariadb
                    sudo systemctl start mariadb

                    ##### Configure MariaDB
                    sudo mariadb-secure-installation

                    #### Install Firewall (ufw for DEB, firewalld for RPM)
                    sudo dnf install firewalld -y
                    sudo dnf enable firewalld

                    ##### Configure firewall for port 22, 80, 443 and 3306
                    sudo firewall-cmd --zone=public --permanent --add-port=22/tcp
                    sudo firewall-cmd --zone=public --add-service=http --permanent
                    sudo firewall-cmd --zone=public --add-service=https --permanent
                    sudo firewall-cmd --zone=public --permanent --add-port=3306/tcp
                    sudo firewall-cmd --reload

                    #### Start/enable fail2ban
                    sudo systemctl enable fail2ban
                    sudo systemctl start fail2ban

                    #### Install PHP + basic MariaDB libraries
                    sudo dnf install -y \
                        php \
                        php-cli \
                        php-fpm \
                        php-gd \
                        php-mysqlnd

                    sudo systemctl enable php-fpm
                    sudo systemctl restart php-fpm
                    sudo systemctl restart httpd

                    ;;
            *)
                    printf "%s\n" \
                    "ISSUE DETECTED - Invalid Distro type provided!" \
                    "----------------------------------------------------" \
                    "Running help script and exiting." \
                    "Re-run script with valid input"
                    helpFunction
                    ;;
    esac

    #### Prompt user for next steps
    printf "%s\n" \
    "${green}Script complete" \
    "----------------------------------------------------" \
    "Check the following:" \
    "* Failed Services" \
    "* Service configurations" \
    "* Packages" \
    "* Logrotate" \
    "* Update settings" \
    "* Logging${normal}"

}

## Main, read passed flags
printf "%s\n" \
"Generic Lamp" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    helpFunction
    exit
    ;;
[Cc]onfigure)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
