#!/bin/bash

export $HAIL_HOME=/opt/hail-on-EMR
cd $HAIL_HOME/src

sudo rm -r hail
sudo ./hail_build.sh

for SLAVEIP in `sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2` 
do
	scp /home/hadoop/hail-* $SLAVEIP:/home/hadoop/
done

sudo stop hadoop-yarn-resourcemanager; sleep 3; sudo start hadoop-yarn-resourcemanager
