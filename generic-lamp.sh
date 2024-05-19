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
    #### Check input

    ### Prompt user to confirm if WordPress should be installed
	printf "%s\n" \
	"WordPress install?" \
	"----------------------------------------------------" \
    "Confirm if WordPress should be installed:" \
    "1: Install WordPress" \
    "0: Do NOT install WordPress" \
    "Enter 1 or 0: "
    read wordpressBool
    #### Check input

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
                    ;;
            [Uu]buntu)
                    printf "%s\n" \
                    "Ubuntu" \
                    "----------------------------------------------------" \
                    " "
                    packageManager="apt"
                    ;;
            [Ff]edora)
                    printf "%s\n" \
                    "Fedora" \
                    "----------------------------------------------------" \
                    " "
                    packageManager="dnf"
                    ;;
            [Rr]ocky)
                    printf "%s\n" \
                    "Rocky" \
                    "----------------------------------------------------" \
                    " "
                    packageManager="dnf"
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
