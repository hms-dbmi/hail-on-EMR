#!/bin/bash
# Dependencies: hail_build.sh, hail_python3.sh, hail_update.sh 
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/cloudcreation_log.out 2>&1
echo $1

echo '### HAIL_INSTALL.SH ###'
echo '### MASTER NODE: Copie keys to SLAVE NODES ###'

for SLAVEIP in `sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2` 
do
   scp -i $1 -o "StrictHostKeyChecking no" ~/.ssh/id_rsa ${SLAVEIP}:/home/hadoop/.ssh/id_rsa
   scp -i $1 ~/.ssh/authorized_keys ${SLAVEIP}:/home/hadoop/.ssh/authorized_keys
done

echo '### MASTER NODE: Clone HAIL-ON-EMR ###'

# Install git
sudo yum install -y git
# Browse to /opt
sudo mkdir -p /opt
sudo chmod 777 /opt/

# Clone hail-on-EMR
cd /opt
git clone --single-branch --branch f-copy-jar  https://github.com/c-BIG/hail-on-EMR.git
cd /opt/hail-on-EMR/src

# Adjust permissions
sudo chown -R hadoop:hadoop /opt
sudo chmod +x hail_python3.sh
sudo chmod +x hail_update.sh
sudo chmod +x hail_build.sh

echo '### MASTER NODE: INSTALLING PYTHON3 & DEPENDANCIES ###'

./hail_python3.sh 

echo '### MASTER NODE: UPDATING HAIL ###'

./hail_update.sh

echo '### LOOPING TO INSTALL PYTHON3 & HAIL IN SLAVE NODES ###'

for SLAVEIP in `sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2`
do
   # Install python3
   scp hail_python3.sh hadoop@${SLAVEIP}:/tmp/hail_python3.sh
   ssh hadoop@${SLAVEIP} "chmod +x /tmp/hail_python3.sh"
   ssh hadoop@${SLAVEIP} "sudo ls -al /tmp/hail_python3.sh"
   ssh hadoop@${SLAVEIP} "sudo /tmp/hail_python3.sh"
   ssh hadoop@${SLAVEIP} "python3 --version"
   # Update Hail
   ssh hadoop@${SLAVEIP} "sudo mkdir -p /opt/hail"
   ssh hadoop@${SLAVEIP} "sudo chmod 777 /opt/hail/"
   scp -r /opt/hail/* hadoop@${SLAVEIP}:/opt/hail/ & wait
   # Done
done
