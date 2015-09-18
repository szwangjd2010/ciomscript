/opt/spark-1.4.0-bin-hadoop2.6/bin/spark-submit \
--master spark://172.17.128.210:7077 \
--executor-memory 3g \
/opt/hs/wordcount.py \
hdfs://172.17.128.210:9000/data/1/acl.c


/opt/spark-1.4.0-bin-hadoop2.6/bin/spark-submit \
--master yarn-master \
--executor-memory 3g \
/opt/hs/wordcount.py \
hdfs://172.17.128.210:9000/data/1/acl.c


/opt/hadoop-2.7.1/bin/hdfs namenode -format
/opt/hadoop-2.7.1/sbin/hadoop-daemon.sh start journalnode
/opt/hadoop-2.7.1/sbin/hadoop-daemon.sh start namenode
/opt/hadoop-2.7.1/sbin/hadoop-daemon.sh start datanode
/opt/hadoop-2.7.1/sbin/hadoop-daemon.sh start zkfc

/opt/hadoop-2.7.1/sbin/start-dfs.sh


./bin/sqoop list-tables \
--connect jdbc:mysql://172.17.128.231/lecai2 \
--username yxt \
--password pwdasdwx

./bin/sqoop list-tables \
--connect jdbc:oracle:thin:@172.17.125.202:1521:yxtdb \
--username elearning \
--password 'password01!'

