#!/bin/bash


SVNBASE="/home/jozko/svn/repos"
SVNREPO="$1"
GITREPO="$2"
GITREMOTE="git@github.com"
GITTEMP="/tmp/$GITREPO"
SVNARCHIVE="/home/jozko/svn/archive"

#Check if exists - svn, git
isrepo() {
    # Check if svn repo is there as claimed
    svn ls file:///"$SVNBASE"/"$SVNREPO" --depth empty > /dev/null 2>&1 
    EC=$?
    if [ $EC != "0" ]; then
        echo "$SVNBASE/$SVNREPO is not svn repository"
        exit 1
    fi
    
    # Check if git repo is there AND empty
    git ls-remote "$GITREMOTE:$GITREPO" > /dev/null 2>&1
    EC=$?
    if [ $EC != "0" ]; then
        echo "$GITREPO is not git repository"
        exit 1    
    fi
    WC=`git ls-remote "$GITREMOTE:$GITREPO" | wc -l`
    if [ "$WC" != "0" ]; then
        echo "Remote git repo $GITREPO is not empty, quitting!"
        exit 1
    fi
}

# Process local clone of svn repo to local git

migrate() {
    echo "Trieing to migrate stuff from $SVNREPO to $GITREPO"
    git svn clone --no-metadata file:///"$SVNBASE/$SVNREPO" "$GITTEMP"
    cd "$GITTEMP"
    git remote add origin "$GITREMOTE:$GITREPO"
    git push origin master
}

#Pack SVN to archive, remove source repo, clean temp git
wrapup() {
    /usr/bin/svn-hot-backup --num-backups=0 --archive-type=gz "$SVNBASE/$SVNREPO" "$SVNARCHIVE"/ > /dev/null 2>&1
    if [ $? != "0" ]; then
        echo "SVN backup error occured at SVN repo $SVNREPO!"
        exit 1
    fi
    rm -rf "$SVNREPO"
    rm -rf "$GITTEMP"
}

if [ ! $# == 2 ]; then
    echo "Usage: $0 svn-repo git-repo - just repository, without path to one!"
    exit 1
else
    echo "Runing svn to git migration"
    isrepo
    migrate
    wrapup
fi

