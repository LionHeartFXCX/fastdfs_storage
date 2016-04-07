#!/bin/bash
#set -e

# if the log file exists, delete it to avoid useless log content.
FASTDFS_LOG_FILE="$FASTDFS_BASE_PATH/logs/storaged.log"
NGINX_ERROR_LOG="/usr/local/nginx/logs/error.log"
STORAGE_PID_NUMBER="$FASTDFS_BASE_PATH/data/fdfs_storaged.pid"

if [  -f "$FASTDFS_LOG_FILE" ]; then 
	rm  "$FASTDFS_LOG_FILE"
fi

if [  -f "$NGINX_ERROR_LOG" ]; then 
	rm  "$NGINX_ERROR_LOG"
fi

#create the soft link.
if [ ! -L "/data/M00" ]; then
    ln -s /data /data/M00
fi

echo "start the storage node with nginx..."

# start the storage node.
fdfs_storaged /etc/fdfs/storage.conf start
/usr/local/nginx/sbin/nginx

# wait for pid file(important!),the max start time is 5 seconds,if the pid number does not appear in 5 seconds,storage start failed.
TIMES=5
while [ ! -f "$STORAGE_PID_NUMBER" -a $TIMES -gt 0 ]
do
    sleep 1s
	TIMES=`expr $TIMES - 1`
done

# if the storage node start successfully, print the started time.
if [ $TIMES -gt 0 ]; then
    echo "the storage node started successfully at $(date +%Y-%m-%d_%H:%M)"
	
	# give the detail log address
    echo "please have a look at the log detail at $FASTDFS_LOG_FILE and $NGINX_ERROR_LOG"

    # leave balnk lines to differ from next log.
    echo
    echo
	
	# make the container have foreground process(primary commond!)
    tail -F --pid=`cat $STORAGE_PID_NUMBER` /dev/null
# else print the error.
else
    echo "the storage node started failed at $(date +%Y-%m-%d_%H:%M)"
	echo "please have a look at the log detail at $FASTDFS_LOG_FILE and $NGINX_ERROR_LOG"
	echo
    echo
fi