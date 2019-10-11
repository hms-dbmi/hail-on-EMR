#!/bin/bash
echo '### HAIL_UPDATE.SH ###'

# Browse to hail-on-ENR
cd /opt/hail-on-EMR/src

# Build hail
sudo rm -r hail
sudo rm /etc/alternatives/jre/include/include
./hail_build.sh 

# ???
sudo stop hadoop-yarn-resourcemanager; sleep 3; sudo start hadoop-yarn-resourcemanager
