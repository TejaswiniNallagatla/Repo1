#!/bin/bash

MASTER=$1
SNN=$2
DN1=$3
DN2=$4
KEY=$5

cd /etc

HOST_CONTENT=$MASTER

sed -i '/127.0.0.1 localhost/i\'"$HOST_CONTENT" hosts

##Updating ubuntu operating system
sudo apt-get update

##Installating JRE
sudo apt-get install default-jre

##Installing JDK
sudo apt-get install default-jdk

##Downloading Hadoop tar file from Apache Hadoop Repo
wget http://mirrors.advancedhosters.com/apache/hadoop/common/hadoop-2.8.1/hadoop-2.8.1.tar.gz

##Untar the Hadoop file
tar -xzvf hadoop-2.8.1.tar.gz

##Move Hadoop untar file to Hadoop file
mv hadoop-2.8.1 hadoop

##Creating temp directory
mkdir hdfstmp

##Add Hadoop bin/ directory to PATH
export PATH=$PATH:$HOME/hadoop/bin

##Set Hadoop-related environment variables
export HADOOP_HOME=$HOME/hadoop
export HADOOP_CONF_DIR=$HOME/hadoop/etc/hadoop
export HADOOP_MAPRED_HOME=$HOME/hadoop
export HADOOP_COMMON_HOME=$HOME/hadoop
export HADOOP_HDFS_HOME=$HOME/hadoop
export YARN_HOME=$HOME/hadoop
 
##Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
export PATH=$PATH:$JAVA_HOME/bin

chmod 644 .ssh/authorized_keys
chmod 400 $KEY

##Adding ssh agent to local machine
eval `ssh-agent -s`

##Adding ".pem" file to ssh agent
ssh-add $KEY

##Navigating to configuration folder
cd /home/ubuntu/hadoop/etc/hadoop

##Adding configuration parameters to core-site.xml
CORE_CONTENT='<property>\
<name>fs.default.name</name>\
<value>hdfs://'$MASTER':8020</value>\
</property>\
<property>\
<name>hadoop.tmp.dir</name>\
<value>/home/ubuntu/hdfstmp</value>\
</property>'

sed -i '/<\/configuration>/i\'"$CORE_CONTENT" core-site.xml

##Adding configuration parameters to hdfs-site.xml
HDFS_CONTENT='<property>\
<name>dfs.replication</name>\
<value>2</value>\
</property>\
<property>\
<name>dfs.permissions</name>\
<value>false</value>\
</property>'

sed -i '/<\/configuration>/i\'"$HDFS_CONTENT" hdfs-site.xml

##Adding configuration parameters to mapred-site.xml
MAPRED_CONTENT='<property>\
<name>mapred.job.tracker</name>\
<value>hdfs://'$MASTER':8021</value>\
</property>'

sed -i '/<\/configuration>/i\'"$MAPRED_CONTENT" mapred-site.xml


##Configure Master and Slaves
MASTER_CONTENT=$Master'\'
$SNN

sed -i '//i\'"$MASTER_CONTENT" master

SLAVE_CONTENT=$DN1'\'
$DN2

sed -i '//i\'"$SLAVE_CONTENT" master

##formatting the namenode
#hadoop namenode -format

#cd /home/ubuntu/hadoop/sbin

##Starting services
#bash start-all.sh