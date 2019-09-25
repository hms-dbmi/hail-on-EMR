# #!/bin/bash

# export SPARK_HOME=/usr/lib/spark
# export PYSPARK_PYTHON=python3

# export PYTHONPATH="/home/hadoop/hail-python.zip:$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-src.zip"
# echo "PYTHONPATH: ${PYTHONPATH}"

# export PYSPARK_PYTHON=python3
# echo "PYSPARK_PYTHON: ${PYSPARK_PYTHON}"

# export ASSEMBLY_JAR=`ls /usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly*`
# echo $ASSEMBLY_JAR
# JAR_PATH="/home/hadoop/hail-all-spark.jar:${ASSEMBLY_JAR}"
# echo $JAR_PATH
# export PYSPARK_SUBMIT_ARGS="--conf spark.driver.extraClassPath='$JAR_PATH' --conf spark.executor.extraClassPath='$JAR_PATH' pyspark-shell"
# echo "PYSPARK_SUBMIT_ARGS: ${PYSPARK_SUBMIT_ARGS}"

# export JUPYTER_PASSWORD=`cat /home/hadoop/jupyter_pw`
# echo $JUPYTER_PASSWORD
# # In case this is a repeated run
# sudo userdel jupyter
# sudo rm -fR /mnt/incubator-toree
# sudo rm -fR /etc/sbt/conf

# # Run the installer
# #./jupyter_installer.sh \
# #	# --r \
# #	--spark-version "2.3.2" \
# #	--toree \
# #	--ds-packages \
# #	--password "avillach" \
# #	--port 8192 \
# #	--s3fs \
# #	--spark-opts "--jars ${JAR_PATH} --py-files /home/hadoop/hail-python.zip"

# # Run the installer
# ./jupyter_installer.sh \
#         --spark-version "2.4.2" \
#         --toree \
#         --ds-packages \
#         --password "avillach" \
#         --port 8192 \
#         --s3fs \
#         --spark-opts "--jars ${JAR_PATH} --py-files /home/hadoop/hail-python.zip"

	
# # ./jupyter_extraRlibraries_install.sh # Not necessary as they are defined in the jupyter_installer.sh
