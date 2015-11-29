#!/bin/bash

#setting
OLDSERVER='/home/MinecraftServer/old.server'
NEWSERVER='/home/MinecraftServer/server'

#command
cp $OLDSERVER/server.properties $NEWSERVER
cp $OLDSERVER/whitelist.json $NEWSERVER
cp $OLDSERVER/banned-ips.json $NEWSERVER
cp $OLDSERVER/ops.json $NEWSERVER
cp $OLDSERVER/banned-players.json $NEWSERVER
rsync -a $OLDSERVER/mods/ $NEWSERVER/mods/
rsync -a $OLDSERVER/config/ $NEWSERVER/config/
rsync -a $OLDSERVER/world/ $NEWSERVER/world/
