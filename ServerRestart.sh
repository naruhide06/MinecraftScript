#!/bin/bash
 
#Settings
SERVICE='forge-1.8-11.14.4.1563-universal.jar' 
OPTIONS='nogui'
USERNAME='MinecraftServer'
WORLD='world'
MCPATH='/home/MinecraftServer/server/'
BACKUPPATH='/home/MinecraftServer/minecraft.backup'
MAXHEAP=1024
MINHEAP=512
HISTORY=1024
CPU_COUNT=2
INVOCATION="java -Xmx${MAXHEAP}M -Xms${MINHEAP}M -XX:+UseConcMarkSweepGC \
 -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts \
 -jar $SERVICE $OPTIONS"
OVERVIEWER='/home/MinecraftServer/overviewer/overviewer.config'

ME=`whoami`
as_user() {
	if [ "$ME" = "$USERNAME" ] ; then
		bash -c "$1"
	else
		su - "$USERNAME" -c "$1"
	fi
}

mc_start() {
	if  pgrep -u $USERNAME -f $SERVICE > /dev/null
	then
		echo "$SERVICE is already running!"
	else
		echo "Starting $SERVICE..."
		cd $MCPATH
		as_user "cd $MCPATH && screen -h $HISTORY -dmS minecraft $INVOCATION"

		sleep 7

		if pgrep -u $USERNAME -f $SERVICE > /dev/null
		then
			echo "$SERVICE is now running."
		else
			echo "Error! Could not start $SERVICE!"
		fi
	fi
}

mc_stop() {
	if pgrep -u $USERNAME -f $SERVICE > /dev/null
	then
		echo "Stopping $SERVICE"
		as_user "screen -p 0 -S minecraft -X eval 'stuff \"say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map...\"\015'"
		as_user "screen -p 0 -S minecraft -X eval 'stuff \"save-all\"\015'"
		sleep 10
		as_user "screen -p 0 -S minecraft -X eval 'stuff \"stop\"\015'"
		sleep 7
	else
		echo "$SERVICE was not running."
	fi

	if pgrep -u $USERNAME -f $SERVICE > /dev/null
	then
		echo "Error! $SERVICE could not be stopped."
	else
		echo "$SERVICE is stopped."
	fi
} 
 
mc_backup() {
	NOW=`date "+%Y-%m-%d_%Hh%M"`
	BACKUP_FILE="$BACKUPPATH/${WORLD}_${NOW}.tar"
	echo "Backing up minecraft world..."
	#as_user "cd $MCPATH && cp -r $WORLD $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"`"
	as_user "tar -C \"$MCPATH\" -cf \"$BACKUP_FILE\" $WORLD"
 
	echo "Backing up $SERVICE"
	as_user "tar -C \"$MCPATH\" -rf \"$BACKUP_FILE\" $SERVICE"
	#as_user "cp \"$MCPATH/$SERVICE\" \"$BACKUPPATH/minecraft_server_${NOW}.jar\""
 
	echo "Compressing backup..."
	as_user "gzip -f \"$BACKUP_FILE\""
	echo "Done."
}

mc_overviewer() {
	if pgrep -u $USERNAME -f $SERVICE > /dev/null
	then
		echo "$SERVICE is now running."
		echo "Skip overviewer"
	else
		echo "Starting overviewer"
		sudo overviewer.py --config=$OVERVIEWER
		sudo overviewer.py --config=$OVERVIEWER --genpoi
		echo "Done"
	fi
}

mc_stop
mc_backup
mc_overviewer
mc_start
