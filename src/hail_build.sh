#!/bin/bash
echo '### HAIL_BUILD.SH ###'

OUTPUT_PATH=""
HAIL_VERSION="master"
SPARK_VERSION="2.4.2"
IS_MASTER=false
export CXXFLAGS=-march=native

if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
  IS_MASTER=true
fi

while [ $# -gt 0 ]; do
    case "$1" in
    --output-path)
      shift
      OUTPUT_PATH=$1
      ;;
    --hail-version)
      shift
      HAIL_VERSION=$1
      ;;
    --spark-version)
      shift
      SPARK_VERSION=$1
      ;;
    -*)
      error_msg "unrecognized option: $1"
      ;;
    *)
      break;
      ;;
    esac
    shift
done

if [ "$IS_MASTER" = true ]; then
  sudo yum update -y
  sudo yum install g++ cmake git -y
  sudo /usr/bin/pip install --upgrade pip
  # Fixes issue of missing lz4 
  sudo yum install -y lz4
  sudo yum install -y lz4-devel
  git clone --single-branch --branch 5.24  https://github.com/broadinstitute/hail.git
  cd hail/hail/
	
	# src/scripts/context.py
	sudo ln -s /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.*.amzn1.x86_64/include /etc/alternatives/jre/include

# Compile Spark 2.4.2
if [ $SPARK_VERSION = "2.4.2" ]; then
  ./gradlew -Dspark.version=$SPARK_VERSION -Dbreeze.version=0.13.2 -Dpy4j.version=0.10.7 shadowJar archiveZip	
else  ./gradlew -Dspark.version=$SPARK_VERSION shadowJar archiveZip
fi

cp $PWD/build/distributions/hail-python.zip $HOME
cp $PWD/build/libs/hail-all-spark.jar $HOME
  
fi
