#!/usr/bin/bash

# Generic Lamp
# BASH script for configuring a generic LAMP stack
# By Nicholas Grogg

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

    ### Prompt user to choose a Database Technology
	printf "%s\n" \
	"${yellow}MySQL or MariaDB?" \
	"----------------------------------------------------" \
    "Choose a Database technology:" \
    "1: MySQL " \
    "2: MariaDB " \
    "Enter 1 or 2: ${normal}"
    read databaseTech

    #### Validation
    while [[ $databaseTech -ne 1 && $databaseTech -ne 0 ]]; do
            printf "%s\n" \
            "${red}ISSUE: Incorrect value passed" \
            "----------------------------------------------------" \
            " " \
            "${yellow}MySQL or MariaDB?" \
            "----------------------------------------------------" \
            "Choose a Database technology:" \
            "1: MySQL " \
            "2: MariaDB " \
            "Enter 1 or 2: ${normal}"
            read databaseTech
    done

    if [[ $databaseTech -eq 1 ]]; then
            databaseString="MySQL"
    else
            databaseString="MariaDB"
    fi

    ### Value confirmation before proceeding
    printf "%s\n" \
    "IMPORTANT: Value confirmation" \
    "----------------------------------------------------" \
    "Server Distro Type: " "$1" \
    " " \
    "Database tech to install: " "$databaseString" \
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
                    sudo apt install python3-certbot-apache certbot apache2 libapache2-mod-security2 -y

                    #TODO: Adjust for use case as needed
                    #### Install commonly used software
                    sudo apt install vim htop net-tools curl wget fail2ban logrotate rsyslog unattended-upgrades bash-completion -y

                    #### Configure unattended upgrades, -p medium should skip low priority questions
                    sudo dpkg-reconfigure -pmedium unattended-upgrades

                    ##### Enable Apache + modsecurity header
                    sudo systemctl enable apache2
                    sudo a2enmod headers
                    sudo systemctl start apache2

                    #### Install/configure MySQL or MariaDB based on databaseTech
                    if [[ $databaseTech -eq 1 ]];then
                            sudo apt install mysql-client mysql-common mysql-server -y

                            ##### Enable MySQL/MariaDB
                            sudo systemctl enable mysql
                            sudo systemctl start mysql

                            ##### Configure MySQL/MariaDB
                            sudo mysql_secure_installation
                    else
                            sudo apt install mariadb-client mariadb-common mariadb-server -y

                            ##### Enable MySQL/MariaDB
                            sudo systemctl enable mariadb
                            sudo systemctl start mariadb

                            ##### Configure MySQL/MariaDB
                            sudo mariadb-secure-installation
                    fi

                    #### Enable fail2ban, by default requires rsyslog
                    sudo systemctl enable rsyslog
                    sudo systemctl start rsyslog
                    sudo systemctl enable fail2ban
                    sudo systemctl start fail2ban

                    #### Install Firewall (ufw for DEB, firewalld for RPM)
                    sudo apt install ufw -y

                    ##### Configure firewall for port 22, 80, 443 and 3306
                    sudo ufw allow 'WWW Full'

                    #### Install PHP + PHP-FPM + basic MySQL library + php Apache library
                    sudo apt install php php-cli php-cgi php-fpm php-common php-mysql libapache2-mod-php
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
                    echo "max_parallel_downloads=10" >> /etc/dnf.conf
                    echo "fastestmirror=True" >> /etc/dnf.conf

                    #### Check for updates
                    sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y

                    #TODO Adjust for use case as needed
                    #### Enable epel repo
                    sudo dnf install epel-release -y

                    #### Install commonly used software
                    sudo dnf install wget curl nmap fail2ban -y

                    #### Install Apache + modsecurity
                    sudo dnf install httpd mod_security -y

                    ##### Enable Apache
                    sudo systemctl enable httpd
                    sudo systemctl start httpd

                    #### Install MySQL or MariaDB based on databaseTech
                    if [[ $databaseTech -eq 1 ]];then
                        sudo dnf install mysql mysql-common mysql-server -y

                        ##### Enable MySQL/MariaDB
                        sudo systemctl enable mysqld
                        sudo systemctl start mysqld

                        ##### Configure MySQL/MariaDB
                        sudo mysql_secure_installation
                    else
                        sudo dnf install mariadb mariadb-common mariadb-server -y

                        ##### Enable MySQL/MariaDB
                        sudo systemctl enable mariadb
                        sudo systemctl start mariadb

                        ##### Configure MySQL/MariaDB
                        sudo mariadb-secure-installation
                    fi

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

                    #### Install PHP + basic MySQL libraries
                    sudo dnf install php php-fpm php-cli php-gd php-mysqlnd -y
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
