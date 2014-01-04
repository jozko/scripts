#!/bin/bash
#
# Simple glassfish log compress and delete older than
# Use with cron
#

LOGDIR="/home/solr/apps/glassfish3/glassfish/domains/domain1/logs"
REMOLD="+7"

function check {
    ls $LOGDIR | egrep '^server.log_[0-9]{4}-[0-9]{2}-[0-9]{2}[A-Z][0-9]{2}-[0-9]{2}-[0-9]{2}$' 
}

function compress {
    for i in `ls $LOGDIR | egrep '^server.log_[0-9]{4}-[0-9]{2}-[0-9]{2}[A-Z][0-9]{2}-[0-9]{2}-[0-9]{2}$'`; do gzip "$LOGDIR/$i"; done;
}


function rotate {
    find "$LOGDIR" -mtime "$REMOLD" -exec rm -f '{}' \; 
}

case "$1" in
        check)
            check
        ;;
         
        compress)
            compress
        ;;

        rotate)
            rotate
        ;;

        *)
            echo "Usage: $0 check | compress | rotate "
esac

