#!/usr/bin/bash

# Generic Lamp
# BASH script for configuring a generic LAMP stack
# By Nicholas Grogg

## Help function
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
	"* Takes a Distro as an argument" \
	"Ex. ./generic-lamp.sh configure DISTRO" \
    " " \
    "Accepted Distros: " \
    "* Debian" \
    "* Fedora" \
    "* Rocky " \
    "* Ubuntu" \
    " "
}

## Function to run program
function runProgram(){
	printf "%s\n" \
	"Configure" \
	"----------------------------------------------------" \
    " "

    ### Prompt user to choose a Database Technology
	printf "%s\n" \
	"MySQL or MariaDB?" \
	"----------------------------------------------------" \
    "Choose a Database technology:" \
    "1: MySQL " \
    "2: MariaDB " \
    "Enter 1 or 2: "
    read databaseTech

    #### Validation
    while [[ $databaseTech -ne 1 && $databaseTech -ne 0 ]]; do
            printf "%s\n" \
            " " \
            "ISSUE: Incorrect value passed" \
            "----------------------------------------------------" \
            " " \
            "MySQL or MariaDB?" \
            "----------------------------------------------------" \
            "Choose a Database technology:" \
            "1: MySQL " \
            "2: MariaDB " \
            "Enter 1 or 2: "
            read databaseTech
    done

    if [[ $databaseTech -eq 1 ]]; then
            databaseString="MySQL"
    else
            databaseString="MariaDB"
    fi

    ### Prompt user to confirm if WordPress should be installed
	printf "%s\n" \
	"WordPress install?" \
	"----------------------------------------------------" \
    "Confirm if WordPress should be installed:" \
    "1: Install WordPress" \
    "0: Do NOT install WordPress" \
    " " \
    "IMPORTANT: Will not create/configure Apache vhost!" \
    " " \
    "Enter 1 or 0: "
    read wordpressBool

    #### Validation
    while [[ $wordpressBool -ne 1 && $wordpressBool -ne 0 ]]; do
            printf "%s\n" \
            " " \
            "ISSUE: Incorrect value passed" \
            "----------------------------------------------------" \
            " " \
            "WordPress install?" \
            "----------------------------------------------------" \
            "Confirm if WordPress should be installed:" \
            "1: Install WordPress" \
            "0: Do NOT install WordPress" \
            " " \
            "IMPORTANT: Will not create/configure an Apache vhost!" \
            " " \
            "Enter 1 or 0: "
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
    "Server Distro: " "$1" \
    " " \
    "Database tech to install: " "$databaseString" \
    " " \
    "Install WordPress? " "$wordPressString" \
    " " \
    "If all clear press enter to proceed or ctrl-c to cancel " \
    " "

    read junkInput

    ### Check Distro, make distro specific changes
	printf "%s\n" \
	"Confirming passed Distro" \
	"----------------------------------------------------" \
    " "

    case "$1" in
            [Dd]ebian)
                    printf "%s\n" \
                    "Debian" \
                    "----------------------------------------------------" \
                    " "
                    packageManager="apt"

                    #TODO
                    #### Check for updates
                    sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

                    #### Install Apache + modsecurity
                    sudo apt install python3-certbot-apache certbot apache2

                    ##### Enable Apache
                    sudo systemctl enable apache2

                    #### Install MySQL or MariaDB based on databaseTech
                    ##### Enable MySQL/MariaDB
                    ##### Configure MySQL/MariaDB

                    #### Install Firewall (ufw for apt, firewalld for dnf)
                    sudo apt install ufw -y

                    ##### Configure firewall for port 22, 80, 443 and 3306
                    sudo ufw allow 'WWW Full'

                    #### Install PHP + basic MySQL libraries

                    ;;
            [Uu]buntu)
                    printf "%s\n" \
                    "Ubuntu" \
                    "----------------------------------------------------" \
                    " "
                    packageManager="apt"

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
            [Ff]edora)
                    printf "%s\n" \
                    "Fedora" \
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
            [Rr]ocky)
                    printf "%s\n" \
                    "Rocky" \
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
                    "ISSUE DETECTED - Invalid Distro provided!" \
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

## Check passed flags
case "$1" in
[Hh]elp)
	printf "%s\n" \
	"Running Help function" \
	"----------------------------------------------------" \
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
	"ISSUE DETECTED - Invalid input detected!" \
	"----------------------------------------------------" \
	"Running help script and exiting." \
	"Re-run script with valid input"
	helpFunction
	exit
	;;
esac
