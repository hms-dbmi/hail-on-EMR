# Hail 0.2 on Amazon EMR: `cloudformation` tool 

This `cloudformation` tool creates an EMR cluster under an **emr-5.10.0** release using `Spark 2.2.0` and `Hadoop 2.73`. In addition, it installs `Hail 0.2` and `JupyterNotebook` in all the instances of the cluster. 

## How to use this tool

 First clone this repository (`git clone https://github.com/hms-dbmi/hail02-on-EMR`) and edit the configuration file `hail02_EMR.yaml` as necessary, see configuration details below; `cd` into the `hail02-on-EMR` folder and execute the `nohup hail_cloudformation_emr.sh &` script. 

 This script is defaulted to region `us-east-1`, instances `c4.8xlarge` : 3 `cores` and 1 `master`. For additional configuration details regarding the **emr-5.10.0** release, visit: <https://console.aws.amazon.com/elasticmapreduce/home?region=us-east-1#quick-create\:>.

## Configuration file details

The configuration file is in `.yaml` format. Edit the variables accordingly:

```yaml
config:
  EMR_CLUSTER_NAME: "my-hail-02-cluster" # Give a name to the EMR cluster
  KEY_NAME: "my-key.pem" # Input your key name
  PATH_TO_KEY: "/full-path/to-key/"
  INSTANCE_TYPE: "c4.8xlarge" # Select the instance type
  CORE_COUNT: "3" # Number of cores. Additional reference in the EC2 FAQs website 
  SUBNET_ID: "subnet-12345" # Select you private subnet. See the EC2 FAQs website
  SLAVE_SECURITY_GROUP: "sg-fromYourPemKey" # PEM key specific. See the EC2 key pairs website
  MASTER_SECURITY_GROUP: "sg-fromYourPemKey" # PEM key specific. See the EC2 key pairs website
  EC2_NAME_TAG: "my-hail-EMR" # Tags for the individual EC2 instances
  OWNER_TAG: "emr-owner" # EC2 owner tag
  PROJECT_TAG: "my-project" # Project tag
  S3_BUCKET: "s3n://my-s3-bucket/" # Input your project's S3 bucket

```


### FAQs and troubleshooting 

* EC2 FAQs website: https://aws.amazon.com/ec2/faqs/#How_many_instances_can_I_run_in_Amazon_EC2

* EC2 key pairs website: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

* If the EMR cluster does not start, make sure that your AWS credentials are properly setup: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html



