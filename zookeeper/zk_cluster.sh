ZK_ROOT=zookeeper-3.4.6
NUMBER_OF_ZOOKEEPER=3
ZK_WORKING_DIR=/Users/dinesh/projects/softwares/zk

echo "starting zookeeper server cluster"

case $1 in
start)
    cur_dir=`pwd`
    for i in $(seq 1 $NUMBER_OF_ZOOKEEPER);
    do 
	cd $ZK_WORKING_DIR/zk-server-$i/	
	$ZK_WORKING_DIR/zk-server-$i/bin/zkServer.sh start
	cd $cur_dir
    done
;;
stop)
    for i in $(seq 1 $NUMBER_OF_ZOOKEEPER);
    do  
        $ZK_WORKING_DIR/zk-server-$i/bin/zkServer.sh stop
    done
;;
restart)
    shift
    "$0" stop ${@}
    sleep 3
    "$0" start ${@}
;;
status)
   echo "start"
    for i in $(seq 1 $NUMBER_OF_ZOOKEEPER);
    do
        $ZK_WORKING_DIR/zk-server-$i/bin/zkServer.sh status
    done   
   ;;
*)  
echo "Usage: $0 {start|stop|restart|status}" >&2
esac

