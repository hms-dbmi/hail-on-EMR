#!/bin/bash
# Dependencies: hail_install_python3.sh, setup.sh, jupyter_build.sh, jupyter_run.sh
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/cloudcreation_log.out 2>&1
# Download the publicly available DBMI Hail builds

echo $1
# curl --output hail-all-spark.jar https://s3.amazonaws.com/avl-hail-73/hail_0.2_emr_5.10_spark_2.2.0/hail-all-spark.jar
# curl --output hail-python.zip https://s3.amazonaws.com/avl-hail-73/hail_0.2_emr_5.10_spark_2.2.0/hail-python.zip
for SLAVEIP in `sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2` 
do
   # Distribute keys to slaves for hadoop account
   scp -i $1 -o "StrictHostKeyChecking no" ~/.ssh/id_rsa ${SLAVEIP}:/home/hadoop/.ssh/id_rsa
   scp -i $1 ~/.ssh/authorized_keys ${SLAVEIP}:/home/hadoop/.ssh/authorized_keys
   # Distribute the freshly built Hail files
done

echo 'Keys successfully copied to NODES'

# Add hail to the master node
sudo mkdir -p /opt
sudo chmod 777 /opt/
sudo chown hadoop:hadoop /opt
cd /opt
sudo yum install -y git  # In case git is not installed 
#git clone https://github.com/hms-dbmi/hail-on-EMR.git
git clone https://github.com/Jack-Ow/hail-on-EMR.git
export HAIL_HOME=/opt/hail-on-EMR

# Update Python 3.6 in all the nodes in the cluster
# First for the master node
cd $HAIL_HOME/src/
sudo chmod +x hail_build.sh
sudo chmod +x update_hail.sh
sudo chmod +x jupyter_build.sh
sudo chmod +x jupyter_run.sh
sudo chmod +x jupyter_installer.sh
sudo chmod +x hail_install_python3.sh

./update_hail.sh

./hail_install_python3.sh 

cd $HAIL_HOME/src
# cd $HOME
# wget -O hail-all-spark.jar https://storage.googleapis.com/hail-common/builds/devel/jars/hail-devel-ae9e34fb3cbf-Spark-2.2.0.jar
# wget -O hail-python.zip https://storage.googleapis.com/hail-common/builds/devel/python/hail-devel-ae9e34fb3cbf.zip
# cd $HAIL_HOME/src
# Then for the slaves\core nodes
for SLAVEIP in `sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2`
do
   scp -r /home/hadoop/hail-* $SLAVEIP:/home/hadoop/
   scp hail_install_python3.sh hadoop@${SLAVEIP}:/tmp/hail_install_python3.sh
   ssh hadoop@${SLAVEIP} "chmod +x /tmp/hail_install_python3.sh"
   ssh hadoop@${SLAVEIP} "sudo ls -al /tmp/hail_install_python3.sh"
   ssh hadoop@${SLAVEIP} "sudo /tmp/hail_install_python3.sh"
   ssh hadoop@${SLAVEIP} "python3 --version"
done

# Set the time zone for cronupdates 
sudo cp /usr/share/zoneinfo/America/New_York /etc/localtime
# setup crontab for daily updates @ 4 am ET
echo "00  4  *  *  * /opt/hail-on-EMR/src/update_hail.sh >> /tmp/cloudcreation_log.out 2>&1 # min hr dom month dow" | crontab -


# sudo chmod +x jupyter_extraRlibraries_install.sh. 
# sudo chown hadoop:hadoop /usr/local/bin/jupyter-notebook

./jupyter_build.sh
./jupyter_run.sh

./VEP_run.sh

