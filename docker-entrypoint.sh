#!/bin/bash
set -e

# Set Emby variables
echo "EMBY_USER=duser" > /etc/emby-server.conf
echo "EMBY_GROUP=users" >> /etc/emby-server.conf
echo "EMBY_DATA=/config" >> /etc/emby-server.conf
echo "EMBY_PIDFILE=/config/emby-server.pid" >> /etc/emby-server.conf
echo "MONO_THREADS_PER_CPU=250" >> /etc/emby-server.conf
echo "MONO_GC_PARAMS=nursery-size=128m" >> /etc/emby-server.conf

exec emby-server start
