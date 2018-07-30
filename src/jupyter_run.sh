#!/bin/bash

export SPARK_HOME=/usr/lib/spark
export PYSPARK_PYTHON=python3

export PYTHONPATH="/home/hadoop/hail-python.zip:$SPARK_HOME/python:${SPARK_HOME}/python/lib/py4j-src.zip"
echo "PYTHONPATH: ${PYTHONPATH}"

export PYSPARK_PYTHON=python3
echo "PYSPARK_PYTHON: ${PYSPARK_PYTHON}"


JAR_PATH="/home/hadoop/hail-all-spark.jar:/usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly-2.20.0.jar"
export PYSPARK_SUBMIT_ARGS="--conf spark.driver.extraClassPath='$JAR_PATH' --conf spark.executor.extraClassPath='$JAR_PATH' pyspark-shell"
echo "PYSPARK_SUBMIT_ARGS: ${PYSPARK_SUBMIT_ARGS}"

sudo mkdir -p $HOME/.jupyter
cp /opt/hail/HailProxy/src/cluster/v2/jupyter_notebook_config.py $HOME/.jupyter/

sudo mkdir -p $HAILPROXY_HOME/notebook/
cd $HAILPROXY_HOME/notebook/
sudo chown hadoop:hadoop /usr/local/bin/jupyter-notebook

nohup jupyter notebook >/tmp/jupyter_notebook.log 2>&1 &
echo $! > /tmp/jupyter_notebook.pid
echo "Started JupyterNotebook in the background."
