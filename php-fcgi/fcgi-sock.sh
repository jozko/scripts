#!/bin/bash

#
# Simple start/stop init script for starting php fastcgi
# Requires installation of spawn-fcgi package, tested on Ubuntu
# Set important stuff
#
PHP_FCGI_MAX_REQUESTS=500
PIDFILE="/var/run/fcgi-sock.pid"
SPAWN="/usr/bin/spawn-fcgi"
SOCK="/var/run/php.sock"
NUMCHILD="4"
USER="www-data"
GROUP="www-data"


if [ $EUID != "0" ]; then
    echo "Need to use root privileges."
    exit 1
fi

# Set FCGI max request number
export PHP_FCGI_MAX_REQUESTS

function start {
    if [ -f $PIDFILE ]; then
        echo "$PIDFILE present, is fastcgi already running?"
    exit 1
    fi
    
    $SPAWN -s "$SOCK" -P "$PIDFILE" -C "$NUMCHILD" -u "$USER"  -f /usr/bin/php5-cgi

}

function stop {
    if ! [ -f $PIDFILE ]; then
                echo "$PIDFILE not present, fastcgi already stopped."
        exit 1
        fi

    kill $(<$PIDFILE)
    rm -f "$PIDFILE"
}

case "$1" in
        start)
            start
        ;;
         
        stop)
            stop
        ;;

        *)
            echo "Usage: $0 start | stop "
esac

