 #!/bin/bash
 
 #Settings
 SERVICE='forge-1.8-11.14.3.1486-universal.jar' 
 OPTIONS='nogui'
 USERNAME='MinecraftServer'
 WORLD='world'
 MCPATH='/home/MinecraftServer/forge-1.8_sato'
 BACKUPPATH='/home/MinecraftServer/minecraft.backup'
 MAXHEAP=1024
 MINHEAP=512
 HISTORY=1024
 CPU_COUNT=2
 INVOCATION="java -Xmx${MAXHEAP}M -Xms${MINHEAP}M -XX:+UseConcMarkSweepGC \
 -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts \
 -jar $SERVICE $OPTIONS" 
 
 ME=`whoami`
 as_user() {
   if [ "$ME" = "$USERNAME" ] ; then
     bash -c "$1"
   else
     su - "$USERNAME" -c "$1"
   fi
 }
 
 mc_saveoff() {
   if pgrep -u $USERNAME -f $SERVICE > /dev/null
   then
     echo "$SERVICE is running... suspending saves"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"say SERVER BACKUP STARTING. Server going readonly...\"\015'"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"save-off\"\015'"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"save-all\"\015'"
     sync
     sleep 10
   else
     echo "$SERVICE is not running. Not suspending saves."
   fi
 }
 
 mc_saveon() {
   if pgrep -u $USERNAME -f $SERVICE > /dev/null
   then
     echo "$SERVICE is running... re-enabling saves"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"save-on\"\015'"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"say SERVER BACKUP ENDED. Server going read-write...\"\015'"
   else
     echo "$SERVICE is not running. Not resuming saves."
   fi
 }
 
    mc_saveoff
    
    NOW=`date "+%Y-%m-%d_%Hh%M"`
    BACKUP_FILE="$BACKUPPATH/${WORLD}_${NOW}.tar"
    echo "Backing up minecraft world..."
    #as_user "cd $MCPATH && cp -r $WORLD $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"`"
    as_user "tar -C \"$MCPATH\" -cf \"$BACKUP_FILE\" $WORLD"
 
    echo "Backing up $SERVICE"
    as_user "tar -C \"$MCPATH\" -rf \"$BACKUP_FILE\" $SERVICE"
    #as_user "cp \"$MCPATH/$SERVICE\" \"$BACKUPPATH/minecraft_server_${NOW}.jar\""
 
    mc_saveon
 
    echo "Compressing backup..."
    as_user "gzip -f \"$BACKUP_FILE\""
    echo "Done."
