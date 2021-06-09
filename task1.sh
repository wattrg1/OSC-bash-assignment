#!/bin/bash

input="$1"

check_input () {
        params="$1"
        spaceRegex=" "
        if [ $params = 0 ] #checks if the user has provided a file in command line, if not, asks for one
        then
                read -p "Please provide the .csv file to create users for: " input
                if [[ $input =~ $spaceRegex ]]
                then
                        echo "Please enter either 1 or 0 parameters"
                        check_input $1
                else
                        check_file $input
                fi
        elif [ $params = 1 ]
        then
                check_file $input
        else
                echo "Please enter either 1 or 0 parameters"
                exit
        fi
}

check_file () {
        input="$1"
        linkRegex="^http" #checks if an input begins with http and ends with .csv
        csvRegex="\.csv$"

        if [ -f $input ] && [[ $input =~ $csvRegex ]] #checks to see if the file exists in the directory and is parse-able
        then
                echo "This file exists"
                cp $input users.csv
        elif [[ $input =~ $linkRegex ]] && [[ $input =~ $csvRegex ]]
        then
                ingest_file $input
        else
                echo "This is not a valid link or a file in the directory"
                exit
        fi
}

ingest_file () { #downloads the link if a link is given and checks if it is parse-able
        link="$1"
        wget -O users.csv $link
        check_file users.csv
}

read_csv () { #seperates the csv file into email, birthdate, groups, and shared folder
        users="$1"

        while IFS=';' read -r email birthdate groups sharedFolder; do
                create_user $email $birthdate $groups $sharedFolder
        done < $users
}

create_user () {
        if [[ "$1" != "e-mail" ]] #ignores the column headers
        then
                while IFS='@' read -r name address ;do
                        while IFS='.' read -r first last ;do
                                initial="$(echo $first | head -c 1)"
                                username="$initial$last"        #appends the last name of the user to their first initial to generate a username
                        done <<< "$name"
                done <<< "$1"
                while IFS=',' read -r groupOne groupTwo ;do
                        if ! grep -q $groupOne /etc/group && [[ "$groupOne" != "" ]]    #checks if the user had a group affiliated with it and makes sure the group doesn't exist
                        then
                                sudo groupadd "$groupOne"
                        fi
                        if ! grep -q $groupTwo /etc/group  && [[ "$groupTwo" != "" ]]   #checks for a second group
                        then
                                sudo groupadd "$groupTwo"
                        fi
                done <<< "$3"
                password=$(gen_password $2)

                sudo useradd -d /home/"$username" -m -s /bin/bash -G $3 "$username"     #creates a user
                echo $username:$password | sudo chpasswd        #adds a password to the user
                sudo chage -d 0 $username       #forces the user to change the password on initial login


        fi
}

gen_password () {       #generates an initial password based on the person's birthdate
        while IFS='/' read -r year month day ;do
                password="$month$year"
        done <<< "$1"
        echo "$password"
        return "$password"
}

create_alias () {
        echo "alias off='systemctl poweroff'" >> ~/.bash_aliases
}
check_input $#
read_csv users.csv
create_alias