#!/usr/bin/env python3

import boto3
import pandas as pd
import time
import sys
import botocore
import paramiko
import re
import os
import yaml
import subprocess
import ast
import argparse
import json

PATH=os.path.dirname(os.path.abspath(__file__))


def is_json(myjson):
        try:
            json_object = json.loads(myjson)
        except ValueError as e:
            return False
        return True

def launch_emr(cluster_id, c):
    # cluster_id_json=os.popen(command).read()
    # cluster_id=cluster_id_json.split(": \"",1)[1].split("\"\n")[0]
    # print('\nClusterId: '+cluster_id+'\n')

    # Gives EMR cluster information
    client_EMR = boto3.client('emr')

    # Cluster state update
    status_EMR='STARTING'
    time.sleep(5)
    # Wait until the cluster is created
    while (status_EMR!='EMPTY'):
        print('Creating EMR...')
        details_EMR=client_EMR.describe_cluster(ClusterId=cluster_id)
        status_EMR=details_EMR.get('Cluster').get('Status').get('State')
        print('Cluster status: '+status_EMR)
        time.sleep(5)
        if (status_EMR=='WAITING'):
            print('Cluster successfully created! Starting HAIL installation...')
            break
        if (status_EMR=='TERMINATED_WITH_ERRORS'):
            sys.exit("Cluster un-successfully created. Ending installation...")


    # Get public DNS from master node
    master_dns=details_EMR.get('Cluster').get('MasterPublicDnsName')
    # master_IP=re.sub("-",".",master_dns.split(".compute")[0].split("ec2-")[1])
    master_IP=re.sub("-",".",master_dns.split(".compute")[0].split("ec2-")[1].split('.')[0])

    print('\nMaster DNS: '+ master_dns)
    print('Master IP: '+ master_IP)

    print('Copying keys...')
    # Copy the key into the master
    command='scp -o \'StrictHostKeyChecking no\' -i '+c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem '+c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem hadoop@'+master_dns+':/home/hadoop/.ssh/id_rsa'
    # print (command)
    os.system(command)

    command='scp -o \'StrictHostKeyChecking no\' -i '+c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem '+c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem hadoop@'+master_dns+':/home/hadoop/'+ c['config']['KEY_NAME'] + '.pem'
    # print (command)
    os.system(command)

    print('Copying installation script...')
    # Copy the installation script into the master
    # print('PATH:' + PATH)
    command='scp -o \'StrictHostKeyChecking no\' -i '+c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem '+PATH+'/hail_install.sh hadoop@'+master_dns+':/home/hadoop'
    # command2='scp -o \'StrictHostKeyChecking no\' -i '+c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem '+PATH+'/jupyter_pw hadoop@'+master_dns+':/home/hadoop/'
    # print (command)
    os.system(command)
    # os.system(command2)

    print('Installing software...')
    key = paramiko.RSAKey.from_private_key_file(c['config']['PATH_TO_KEY']+ '/' + c['config']['KEY_NAME']+'.pem')
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    client.connect(hostname=master_IP, username="hadoop", pkey=key)
    # Execute a command(cmd) after connecting/ssh to an instance
    stdin, stdout, stderr = client.exec_command('cd /home/hadoop/')
    stdin, stdout, stderr = client.exec_command('chmod +x hail_install.sh')
    stdin, stdout, stderr = client.exec_command('./hail_install.sh %s'% c['config']['KEY_NAME']+'.pem')
    # close the client connection
    client.close()

    
    # TODO Test if the .jar is created before printing done
    # ll /opt/hail-on-EMR/src/hail/hail/build/deploy/hail/
    # Should see file hail-all-spark.jar

    # END
    print('DONE')

def main(args):

    c=yaml.load(open(PATH+"/hail02_EMR.yaml"), Loader=yaml.BaseLoader)

    # Create cluster - EBS Volume
    # command='aws emr create-cluster --applications Name=Ganglia Name=Spark Name=Zeppelin --tags \'Project='+c['config']['PROJECT_TAG']+'\' \'Owner='+c['config']['OWNER_TAG']+'\' \'Name='+c['config']['EC2_NAME_TAG']+'\' --ec2-attributes \'{"KeyName":"'+c['config']['KEY_NAME']+'","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"'+c['config']['SUBNET_ID']+'","EmrManagedSlaveSecurityGroup":"'+c['config']['SLAVE_SECURITY_GROUP']+'","EmrManagedMasterSecurityGroup":"'+c['config']['MASTER_SECURITY_GROUP']+'"}\' --service-role EMR_DefaultRole --release-label emr-5.19.0 --log-uri \''+c['config']['S3_BUCKET']+'\' --name \''+c['config']['EMR_CLUSTER_NAME']+'\' --instance-groups \'[{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":1}]},"InstanceGroupType":"MASTER","InstanceType":"'+c['config']['INSTANCE_TYPE']+'","Name":"Master Instance Group"},{"InstanceCount":'+c['config']['CORE_COUNT']+',"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":1}]},"InstanceGroupType":"CORE","InstanceType":"'+c['config']['INSTANCE_TYPE']+'","Name":"Core Instance Group"}]\' --configurations \'[{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"},"Configurations":[]}]\' --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region ap-southeast-1'

    # Create Cluster - Instance Store
    command=(
        'aws emr create-cluster '
        '--applications '
            'Name=Ganglia '
            'Name=Spark '
            'Name=Zeppelin '
            'Name=JupyterHub '
        '--tags '
            '\'Project='+c['config']['PROJECT_TAG']+'\' '
            '\'Owner='+c['config']['OWNER_TAG']+'\' '
            '\'Name='+c['config']['EC2_NAME_TAG']+'\' '
        '--ec2-attributes \'{'
            '"KeyName":"'+c['config']['KEY_NAME']+'",'
            '"InstanceProfile":"EMR_EC2_DefaultRole",'
            '"SubnetId":"'+c['config']['SUBNET_ID']+'",'
            '"EmrManagedSlaveSecurityGroup":"'+c['config']['CORE_SECURITY_GROUP']+'",'
            '"EmrManagedMasterSecurityGroup":"'+c['config']['MASTER_SECURITY_GROUP']+'"}\' '
        '--service-role EMR_DefaultRole '
        '--enable-debugging '
        '--release-label \''+c['config']['RELEASE_LABEL']+'\' '
        '--log-uri \''+c['config']['S3_BUCKET']+'\' '
        '--name \''+c['config']['EMR_CLUSTER_NAME']+'\' '
        '--instance-groups \'[{'
            '"InstanceCount":1,'
            '"InstanceGroupType":"MASTER",'
            '"InstanceType":"'+c['config']['MASTER_INSTANCE_TYPE']+'",'
            '"Name":"Master Instance Group"'
            '},{'
            '"InstanceCount":'+c['config']['CORE_COUNT']+','
            '"InstanceGroupType":"CORE",'
            '"EbsConfiguration":{'
                '"EbsBlockDeviceConfigs":[{'
                    '"VolumeSpecification":{'
                        '"SizeInGB":'+c['config']['CORE_EBS_SIZE']+','
                        '"VolumeType":"gp2"'
                    '},'
                    '"VolumesPerInstance":1'
                '}]'
            '},'
            '"InstanceType":"'+c['config']['CORE_INSTANCE_TYPE']+'",'
            '"Name":"Core Instance Group"'
        '}]\' '
        '--configurations \'[{'
            '"Classification":"spark",'
            '"Properties":{"maximizeResourceAllocation":"true"}'
        '},{'
            '"Classification":"spark-defaults",'
            '"Properties":{'
                '"spark.jars":":/opt/hail/hail-all-spark.jar",'
                '"spark.serializer":"org.apache.spark.serializer.KryoSerializer",'
                '"spark.kryo.registrator":"is.hail.kryo.HailKryoRegistrator",'
                '"spark.driver.extraClassPath":":/opt/hail/hail-all-spark.jar:/usr/lib/hadoop-lzo/lib/*:/usr/lib/hadoop/hadoop-aws.jar:/usr/share/aws/aws-java-sdk/*:/usr/share/aws/emr/emrfs/conf:/usr/share/aws/emr/emrfs/lib/*:/usr/share/aws/emr/emrfs/auxlib/*:/usr/share/aws/emr/goodies/lib/emr-spark-goodies.jar:/usr/share/aws/emr/security/conf:/usr/share/aws/emr/security/lib/*:/usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar:/usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar:/usr/share/aws/sagemaker-spark-sdk/lib/sagemaker-spark-sdk.jar:/usr/share/aws/emr/s3select/lib/emr-s3-select-spark-connector.jar",'
                '"spark.executor.extraClassPath":":/opt/hail/hail-all-spark.jar:/usr/lib/hadoop-lzo/lib/*:/usr/lib/hadoop/hadoop-aws.jar:/usr/share/aws/aws-java-sdk/*:/usr/share/aws/emr/emrfs/conf:/usr/share/aws/emr/emrfs/lib/*:/usr/share/aws/emr/emrfs/auxlib/*:/usr/share/aws/emr/goodies/lib/emr-spark-goodies.jar:/usr/share/aws/emr/security/conf:/usr/share/aws/emr/security/lib/*:/usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar:/usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar:/usr/share/aws/sagemaker-spark-sdk/lib/sagemaker-spark-sdk.jar:/usr/share/aws/emr/s3select/lib/emr-s3-select-spark-connector.jar"'
            '}'
        '},{'
            '"Classification":"spark-env",'
            '"Properties":{'
            '},'
            '"Configurations":[{'
                '"Classification":"export",'
                '"Properties":{'
                    '"PYTHONPATH":"$PYTHONPATH:/opt/hail/python",'
                    '"PYSPARK_PYTHON":"python3"'
                '},'
                '"Configurations":[]'
            '}]'
        '},{'
            '"Classification":"livy-conf",'
            '"Properties":{"livy.server.session.timeout":"8h"}'
        '}]\' '
        '--ebs-root-volume-size 32 '
        '--scale-down-behavior TERMINATE_AT_TASK_COMPLETION '
        '--region '+c['config']['REGION']
    )

    print("\n\nYour AWS CLI export command:\n")
    print(command)
    
    if args.clusterid:
       cluster_id = args.clusterid

    else:
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)

        cluster_id_byte = process.stdout.read()
        
        if is_json(cluster_id_byte):
            cluster_dict = json.loads(cluster_id_byte)
            cluster_id = cluster_dict["ClusterId"]
        else:
            cluster_id = cluster_id_byte.decode("utf-8").rstrip()

        print( "2")

    print('Cluster ID: '+ cluster_id)

    launch_emr(cluster_id, c)

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="EMR workflow")
    parser.add_argument('-c', '--clusterid', required=False)
    parameters = parser.parse_args()
    main(parameters)
