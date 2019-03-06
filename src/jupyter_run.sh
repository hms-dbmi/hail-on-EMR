#!/bin/bash

export SPARK_HOME=/usr/lib/spark
export PYSPARK_PYTHON=python3
export HAIL_HOME=/opt/hail-on-EMR
export HOME=/home/hadoop

export PYTHONPATH="/home/hadoop/hail-python.zip:$SPARK_HOME/python:${SPARK_HOME}/python/lib/py4j-src.zip"
echo "PYTHONPATH: ${PYTHONPATH}"

export PYSPARK_PYTHON=python3
echo "PYSPARK_PYTHON: ${PYSPARK_PYTHON}"


JAR_PATH="/home/hadoop/hail-all-spark.jar:/usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly-2.28.0.jar"
export PYSPARK_SUBMIT_ARGS="--conf spark.driver.extraClassPath='$JAR_PATH' --conf spark.executor.extraClassPath='$JAR_PATH' pyspark-shell"
echo "PYSPARK_SUBMIT_ARGS: ${PYSPARK_SUBMIT_ARGS}"

sudo mkdir -p $HOME/.jupyter
cp /opt/hail-on-EMR/src/jupyter_notebook_config.py $HOME/.jupyter/

sudo mkdir -p $HOME/notebook/
sudo chmod -R 777 $HOME/notebook
cd $HOME/notebook/

JUPYTERPID=`cat /tmp/jupyter_notebook.pid`
kill $JUPYTERPID
nohup jupyter notebook >/tmp/jupyter_notebook.log 2>&1 &
echo $! > /tmp/jupyter_notebook.pid
echo "Started JupyterNotebook in the background."
