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
