#!/bin/bash
#
# This script is used for automatic login/logout to p.nju.edu.cn
# You should keep your account and password properly
#

### You can fill your account and password here ###
pNJU_username=""
pNJU_password=""
###########################################


#Define portal URL
pNJU_login_URL="http://p.nju.edu.cn/portal_io/login"
pNJU_logout_URL="http://p.nju.edu.cn/portal_io/logout"


function showHelp
{
    echo "Usage: ./pNJU.sh [-h] [-u USERNAME] [-p PASSWORD] [-i] [-o]"
    echo "Argument:"
    echo "      -h           Show help message"
    echo "      -u USERNAME  Specify your account"
    echo "      -p PASSWORD  Specify your password"
    echo "      -i           Do login"
    echo "      -o           Do logout"
    echo
}

function getReqProg
{
    #Determine program used to make HTTP request
    temp=$(curl --version 2>/dev/null)
    if [ -z "$temp" ]; then
        temp=$(wget --version 2>/dev/null)
        if [ -z "$temp" ]; then
            echo "No download program was found."
            echo "Please install curl or wget first."
            echo
            exit 1
        else
            REQ_PROG="wget -q -O -"
        fi
    else    
        REQ_PROG="curl -s"
    fi
}

function login
{
    getReqProg
    if [ -z "$pNJU_username" -o -z "$pNJU_password" ]; then
        echo "Please specify username and password to login!"
        echo
        return
    fi
    response=$($REQ_PROG "$pNJU_login_URL?username=$pNJU_username&password=$pNJU_password")
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
    getReqProg
    response=$($REQ_PROG "$pNJU_logout_URL")
    retcode=$(echo $response | grep "\"reply_code\":101")
    if [ ! -z "$retcode" ]; then
        echo "Logout successfully!"
    else
        echo "Cannot logout."
    fi
}

has_arg=0
while getopts "hiou:p:" arg
do
    has_arg=1
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

if [ $has_arg -eq 0 ]; then
    showHelp
fi
