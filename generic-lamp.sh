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
    " "
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
            "Enter 1 or 2: ${yellow}"
            read databaseTech
    done

    if [[ $databaseTech -eq 1 ]]; then
            databaseString="MySQL"
    else
            databaseString="MariaDB"
    fi

    ### Prompt user to confirm if WordPress should be installed
	printf "%s\n" \
	"${yellow}WordPress install?" \
	"----------------------------------------------------" \
    "Confirm if WordPress should be installed:" \
    "1: Install WordPress" \
    "0: Do NOT install WordPress" \
    " " \
    "IMPORTANT: Will not create/configure Apache vhost!" \
    " " \
    "Enter 1 or 0: ${normal}"
    read wordpressBool

    #### Validation
    while [[ $wordpressBool -ne 1 && $wordpressBool -ne 0 ]]; do
            printf "%s\n" \
            "${red}ISSUE: Incorrect value passed" \
            "----------------------------------------------------" \
            " " \
            "${yellow}WordPress install?" \
            "----------------------------------------------------" \
            "Confirm if WordPress should be installed:" \
            "1: Install WordPress" \
            "0: Do NOT install WordPress" \
            " " \
            "IMPORTANT: Will not create/configure an Apache vhost!" \
            " " \
            "Enter 1 or 0: ${normal}"
            read wordpressBool
    done

    if [[ $wordpressBool -eq 1 ]]; then
            wordPressString="yes"
    else
            wordPressString="no"
    fi

    ### Value confirmation before proceeding
    printf "%s\n" \
    "IMPORTANT: Value confirmation" \
    "----------------------------------------------------" \
    "Server Distro Type: " "$1" \
    " " \
    "Database tech to install: " "$databaseString" \
    " " \
    "Install WordPress? " "$wordPressString" \
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
                    packageManager="apt"

                    #TODO
                    #### Check for updates
                    sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

                    #### Install Apache + modsecurity
                    sudo apt install python3-certbot-apache certbot apache2

                    #### Install commonly used software
                    sudo apt install vim htop net-tools curl wget git fail2ban rsyslog unattended-upgrades bash-completion -y

                    #### Configure unattended upgrades
                    sudo dpkg-reconfigure -plow unattended-upgrades

                    ##### Enable Apache
                    sudo systemctl enable apache2

                    #### Install MySQL or MariaDB based on databaseTech
                    ##### Enable MySQL/MariaDB
                    ##### Configure MySQL/MariaDB

                    #### Enable fail2ban
                    sudo systemctl enable rsyslog
                    sudo systemctl start rsyslog
                    sudo systemctl enable fail2ban
                    sudo systemctl start fail2ban

                    #### Install Firewall (ufw for apt, firewalld for dnf)
                    sudo apt install ufw -y

                    ##### Configure firewall for port 22, 80, 443 and 3306
                    sudo ufw allow 'WWW Full'

                    #### Install PHP + basic MySQL libraries

                    ;;
            [Rr][Pp][Mm])
                    printf "%s\n" \
                    "RPM based distro" \
                    "----------------------------------------------------" \
                    " "
                    packageManager="dnf"

                    #TODO
                    #### Check for updates
                    #### Install Apache + modsecurity
                    ##### Enable Apache
                    #### Install MySQL or MariaDB based on databaseTech
                    ##### Enable MySQL/MariaDB
                    ##### Configure MySQL/MariaDB
                    #### Install Firewall (ufw for apt, firewalld for dnf)
                    ##### Configure firewall for port 22, 80, 443 and 3306
                    #### Install PHP + basic MySQL libraries

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

    #### Install WordPress based on wordpressBool
    ##### Create docroot
    ##### Install WordPress files
    ##### Create upload folder
    ##### Prompt user for next steps

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
