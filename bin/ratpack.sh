#!/bin/bash

# David Brady - david.brady@leadmediapartners.com
# 
# Copyright (c) 2009 Lead Media Partners LLC
# 
# ratpack - Startup script for sinatra cluster
# 
# description: This little service handles starting and stopping
# sinatra apps on the server.
#  
# How it works: In the config directory is a file for each app
# containing the path to the application's startup file
# 
# When the ruby file is run, a PID file is created for it in the
# PID_DIR.
# 
# This script is loosely based on the mongrel_cluster scripts written
# by Bradley Taylor (bradley@railsmachine.com).

CONF_DIR=/etc/ratpack
PID_DIR=/var/run/ratpack

if [ "$2x" == "x" ]; then
    echo "ratpack <start|stop|restart> <app>"
    exit 1
fi

# Check for config dir and app file in it
if ! [ -d "$CONF_DIR" ]; then
    echo "Hey! Config dir doesn't exist: $CONF_DIR"
    exit 2
fi

if ! [ -e "$CONF_DIR/$2.cfg" ]; then
    echo "Config file for app is missing: '$CONF_DIR/$2.cfg' does not exist"
    exit 3
fi

case "$1" in
    start)
      # Create pid directory
        mkdir -p $PID_DIR
        ls $CONF_DIR | while read config_file; do
            cat $CONF_DIR/$config_file | while read app_file; do
                ratpack_ctl $app_file $PID_DIR/$app_file.pid
            done
        done
        ;;
    stop)
        for pidfile in $PID_DIR/*.pid; do
            kill `cat $PID_DIR/$pidfile`
        done
        ;;
    restart)
        # Kids, please don't copy and paste like I just did
        mkdir -p $PID_DIR
        ls $CONF_DIR | while read config_file; do
            cat $CONF_DIR/$config_file | while read app_file; do
                ratpack_ctl $app_file $PID_DIR/$app_file.pid
            done
        done
        for pidfile in $PID_DIR/*.pid; do
            kill `cat $PID_DIR/$pidfile`
        done
        ;;
    *)
        echo "Usage: ratpack {start|stop|restart}"
        exit 4
        ;;
esac      

