#!/bin/bash

arg="$1"

check_input () {
        params="$1"
        if [ $params = 0 ]      #checks if user has provided an argument
        then
                read -p "Please enter the directory you want to backup: " input
                if [ -d $input ]        #makes sure the argument is a valid directory
                then
                        echo "This is a valid directory"
                        backup_dir $input
                else
                        echo "This is not a valid directory"
                        exit

                fi
        elif [ $params = 1 ]
        then
                if [ -d $arg ]  #checks if the passed argument is a valid directory
                then
                         echo "This is a valid directory"
                        backup_dir $arg
                else
                        echo "This is not a valid directory"
                        exit
                fi
        else
                echo "Too many arguments passed, please only enter one directory name"
                check_input
        fi
}

backup_dir () {
        echo "Backing up $1..."
        tar -czvf "$1".tar.gz $1
        if [ $? = 0 ]
        then
                echo "Successfully archived $1"
        else
                echo "There was a problem when archiving $1. Exiting..."
                exit
        fi
}
check_input $#