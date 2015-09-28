wget=/usr/local/bin/wget
tar=/usr/bin/tar
ZK_ROOT=zookeeper-3.4.6
NUMBER_OF_ZOOKEEPER=3
ZK_WORKING_DIR=/Users/dinesh/projects/softwares/zk

if [ ! -x "$wget" ]; then
  echo "ERROR: No wget." >&2
  exit 1
 elif [ ! -x "$tar" ]; then
  echo "ERROR: tar not found in $tar, update tar path or install tar." >&2
  exit 1
fi



echo "setting up data directory for zookeeper"
for i in $(seq 1 $NUMBER_OF_ZOOKEEPER);
do 
	mkdir -p $ZK_WORKING_DIR/zk-server-$i
	mkdir -p $ZK_WORKING_DIR/data/zk$i
	mkdir -p $ZK_WORKING_DIR/log/zk$i
	echo "1" > $ZK_WORKING_DIR/data/zk$i/myid
done

echo "Downloading zookeer from apache . . . "
wget http://apache.spinellicreations.com/zookeeper/$ZK_ROOT/$ZK_ROOT.tar.gz

# extract archive
if [ ! -f "$ZK_ROOT.tar.gz" ]; then
  echo "ERROR: archive not found" >&2
  exit 1
fi

gzip -dc $ZK_ROOT.tar.gz | tar -xf - -C /tmp

echo "Creating cluster of $NUMBER_OF_ZOOKEEPER zookeeper"

for i in $(seq 1 $NUMBER_OF_ZOOKEEPER); do cp -R /tmp/$ZK_ROOT/* $ZK_WORKING_DIR/zk-server-$i; done
CLIENT_PORT=2181


for i in $(seq 1 $NUMBER_OF_ZOOKEEPER); do 

	echo "# The number of milliseconds of each tick" > $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "tickTime=2000" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# The number of ticks that the initial synchronization phase can take" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "initLimit=10" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg

	echo "" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# The number of ticks that can pass between" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# sending a request and getting an acknowledgement" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "syncLimit=5" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# the directory where the snapshot is stored." >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# Choose appropriately for your environment" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "dataDir=$ZK_WORKING_DIR/data/zk$i" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# the port at which the clients will connect" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	
	echo "" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# the directory where transaction log is stored." >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# this parameter provides dedicated log device for ZooKeeper" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "dataLogDir=$ZK_WORKING_DIR/log/zk$i" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg

	echo "# ZooKeeper server and its port no." >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# ZooKeeper ensemble should know about every other machine in the ensemble" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# specify server id by creating 'myid' file in the dataDir" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	echo "# use hostname instead of IP address for convenient maintenance" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	PORT_1=2887
	PORT_2=3887
	echo "clientPort=$CLIENT_PORT" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
	CLIENT_PORT=`expr $CLIENT_PORT + $i`    
    for j in $(seq 1 $NUMBER_OF_ZOOKEEPER);do
        PORT_1=`expr $PORT_1 + $j`
        PORT_2=`expr $PORT_2 + $j`
        echo "server.$i=localhost:$PORT_1:$PORT_2" >> $ZK_WORKING_DIR/zk-server-$i/conf/zoo.cfg
    done
done

