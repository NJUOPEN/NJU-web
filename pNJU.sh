#!/bin/bash
#
# This script is used for automatic login/logout to p.nju.edu.cn
# You should keep your account and password properly
#

### You can fill your account and password here ###
pNJU_username=""
pNJU_password=""
###########################################


pNJU_login_URL="http://p.nju.edu.cn/portal_io/login"
pNJU_logout_URL="http://p.nju.edu.cn/portal_io/logout"


function showHelp
{
    echo "Usage: ./pNJU.sh [-h] [-u USERNAME] [-p PASSWORD] [-i] [-o]"
    echo
}

function login
{
    if [ -z "$pNJU_username" -o -z "$pNJU_password" ]; then
        echo "Please specify username and password to login!"
        echo
        return
    fi
    response=$(curl -s "$pNJU_login_URL?username=$pNJU_username&password=$pNJU_password")
    retcode=$(echo $response | grep '"reply_code":1')
    if [ ! -z "$retcode" ]; then
        echo "Login successfully!"
    else
        retcode=$(echo $response | grep '"reply_code":6')
        if [ ! -z "$retcode" ]; then
            echo "You have already logged in!"
        else
            echo "Cannot login."
        fi
    fi
}

function logout
{
    response=$(curl -s "$pNJU_logout_URL")
    retcode=$(echo $response | grep "\"reply_code\":101")
    if [ ! -z "$retcode" ]; then
        echo "Logout successfully!"
    else
        echo "Cannot logout."
    fi
}

while getopts "hiou:p:" arg
do
    case $arg in
        h)
            showHelp
            ;;
        i)
            login
            ;;
        o)
            logout
            ;;
        p)
            pNJU_password=$OPTARG
            ;;
        u)
            pNJU_username=$OPTARG
            ;;
        ?)
            echo "Invalid argument"
            showHelp
            exit 1
            ;;
    esac
done
