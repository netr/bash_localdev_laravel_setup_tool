#!/bin/bash

OPTIONS="SSL SSLGen HTTP Quit"
RED='\033[0;31m'
NC='\033[0m' # No Color
YLW='\033[1;33m'
BLUE='\033[0;34m'

function project()
{
    local  __resultvar=$1
    echo "What is the domain of your local project (i.e. laravel.test)"
    read myresult
    eval $__resultvar="'$myresult'"
}

function directory()
{
    local  __resultvar=$1
    echo "What is the folder name in your /var/www/html"
    read myresult
    eval $__resultvar="'$myresult'"
}

function movessl() {
    for file in *
    do
        if [[ -f $file ]]; then
            if [[ $file == *"key.pem" && $file == *"$proj"* ]]; then
                {
                    sudo mv "$DIR/$file" "/etc/ssl/$proj.key"
                } || {
                    clear
                    echo -e "\nERROR:\t${RED}Failed to move SSL's key file!"
                    exit
                }
                continue
            fi

            if [[ $file == *".pem" && $file == *"$proj"* ]]; then
                {
                    sudo mv "$DIR/$file" "/etc/ssl/$proj.pem"
                } || {
                    clear
                    echo -e "\nERROR:\t${RED}Failed to move SSL's pem file!"
                    exit
                }
                continue
            fi
        fi
    done
}


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
filename='nginxssl'


select opt in $OPTIONS; do

    if [ "$opt" = "Quit" ]; then
        echo Goodbye
        exit
    elif [ "$opt" = "SSL" ]; then
        project proj
        directory dir
        echo Creating SSL file for Nginx
    elif [ "$opt" = "SSLGen" ]; then
        project proj
        directory dir
        echo Generating an SSL File and Nginx File

        {
            mkcert -install "$proj" ""*.$proj""
        } || {
            echo -e "\nERROR:\t${RED}Failed to create certs with mkcert"
            exit
        }

        movessl

    elif [ "$opt" = "HTTP" ]; then
        project proj
        directory dir
        filename='nginxhttp'
        echo Creating an HTTP file for Nginx
    else 
        clear
        echo Invalid option
        exit
    fi

    rm -rf "$proj"

    old_IFS=$IFS # save the field separator
    IFS=$'\n' # new field separator, the end of line
    for line in $(cat $filename)
    do
        newline="${line/\[\[DOMAIN\]\]/$proj}"
        newline="${newline/\[\[DIRECTORY\]\]/$dir}"
        echo "$newline" >> "$proj"
    done
    IFS=$old_IFS # restore default field separator

    sudo mv "$DIR/$proj" "/etc/nginx/sites-available/$proj"
    sudo ln -s "/etc/nginx/sites-available/$proj" "/etc/nginx/sites-enabled/$proj"
    ngxres

    clear
    echo "==============================================="
    echo ""
    echo -e "Successfully created ${RED}$proj${NC}'s nginx files/certs!\n"
    if [[ $filename == "nginxssl" ]]; then
        echo -e "Your certs are listed below:\n"
        echo -e "${YLW}Key:${NC}\t/etc/ssl/$proj.key"
        echo -e "${YLW}Pem:${NC}\t/etc/ssl/$proj.pem"
        echo -e ""
    fi
    echo -e "Your nginx file is:\n"
    echo -e "/etc/nginx/${BLUE}sites-available${NC}/$proj"
    echo ""
    echo "==============================================="
    
    found=0
    for line in $(sudo cat /etc/hosts)
    do
        if [[ $line == *"$proj"* ]]; then 
            found=1
        fi
    done

    if [[ $found == 0 ]]; then
        echo ""
        echo -e "Appended to ${YLW}/etc/hosts${NC} with new domain:\n"
        echo -e "127.0.0.1\t$proj" | sudo tee -a /etc/hosts
        echo ""
        echo "==============================================="
    fi
    exit

done
