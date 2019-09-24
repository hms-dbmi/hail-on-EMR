# Hail 0.2 on Amazon EMR: `cloudformation` tool 

This `cloudformation` tool creates an EMR cluster under an **emr-5.24.0** release using `Spark 2.4.2` and `Hadoop 2.8.3`, with  `Hail 0.2` and `JupyterNotebook` installed. 

## Before using this tool (Prerequisites)

This tool requires the following programs to be installed <!-- (if any of them is missing, they will be installed for you !) --> : 

* Amazon's `Command Line Interface (CLI)` utility
* `Conda` environment manager ( We suggest [Miniconda3](https://docs.conda.io/en/latest/miniconda.html))

## How to use this tool

This tool is executed from the terminal using Amazon's `CLI` utility. Before getting started, make sure you have: 

a) **A valid EC2 key pair**. For additional details on how to create and use your key, visit: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

b) **A configured `CLI` account**. If your `CLI` account has been previously configured, the tool will use it. If you want to re-configure a to use under a specific account or a different user, at the terminal type `aws configure`

Then open your terminal and clone this repository: `git clone https://github.com/c-BIG/hail-on-EMR.git`.

### Environment manager

A conda environment file is shipped with the repository. It will ensure that additional dependencies are installed on your system.

Create a conda environment based on `hail-on-EMR/src/conda-env.yaml` and activate it.

```sh
conda env create -f hail-on-EMR/src/conda-env.yaml
conda activate hail
```

### EMR `cloudformation`

1. `cd` into the `hail02-on-EMR/src` folder and with the text editor of your preference open the configuration file: `hail02_EMR.yaml`. This file will be used to provide information necessary to create the cluster. Fill in the fields as necessary using your personal key and security groups (SG) information and save your changes. See configuration details below:

```yaml
config:
  EMR_CLUSTER_NAME: "my-hail-02-cluster" # Give a name to the EMR cluster
  EC2_NAME_TAG: "my-hail-EMR" # Tags for the individual EC2 instances
  OWNER_TAG: "emr-owner" # EC2 owner tag
  PROJECT_TAG: "my-project" # Project tag
  SUBPROJECT_TAG: "my-sub-project" # Sub-project tag
  REGION: "ap-southeast-1" # AWS Region tag
  S3_BUCKET: "s3n://my-s3-bucket/" # Input your project's S3 bucket
  KEY_NAME: "my-key" # Input your key name DO NOT include the .pem extension
  PATH_TO_KEY: "/full-path/to-key/" # Full path to .pem file
  MASTER_INSTANCE_TYPE: "c4.4xlarge" # Suggested EC2 instances, change as desired
  SLAVE_INSTANCE_TYPE: "c4.4xlarge" # Suggested EC2 instances, change as desired
  CORE_COUNT: "3" # Number of cores. Additional reference in the EC2 FAQs website
  CORE_EBS_SIZE: "150" #
  SUBNET_ID: "subnet-12345" # Select you private subnet. See the EC2 FAQs website
  SLAVE_SECURITY_GROUP: "" # Creates a new group by default. You can also add a specific SG. See the SG link in the FAQs section
  MASTER_SECURITY_GROUP: "" # Creates a new group by default. You can also add a specific SG. See the SG link in the FAQs section
  RELEASE_LABEL: "emr-5.24.0"
```

This script is defaulted to region `ap-southeast-1`, instances `c4.4xlarge` : 3 `cores` and 1 `master`. For additional configuration details regarding the **emr-5.24.0** release, visit: <https://console.aws.amazon.com/elasticmapreduce/home?region=ap-southeast-1#quick-create\:>. 

|Suggested **`INSTANCE_TYPE`s** |
|:-------------------------:| 
| m4.2xlarge | 
| m4.4xlarge | 
| m4.10xlarge | 
| m4.16xlarge | 
| c4.2xlarge | 
| c4.4xlarge | 
| c4.8xlarge | 
| r4.2xlarge | 
| r4.4xlarge | 
| r4.8xlarge | 

See additional instance details at: https://aws.amazon.com/ec2/instance-types/

2. Execute the command: `python install2.py`. The EMR creation is initiated. The status of the cluster is monitored and will undergo from `STARTING` to `RUNNING` and `WAITING`. <!-- The EMR creation takes between 5-7 minutes. The installation log file is located at `tail -f /tmp/cloudcreation_log.out`; the logs are available, under the same path, at both the local installation computer and at the master node of your EMR -->
3. Once the cluster is succesfully created and is in `WAITING` status, the installation of `HAIL` is initiated.
<!-- You can check the status of the EMR creation at: https://console.aws.amazon.com/elasticmapreduce/home?region=ap-southeast-1. The EMR is successfully created once it gets the status `Waiting`. After created, allow ~20 minutes for all the programs to install. All the programs are installed automatically-->
4. Once the installation of Hail is done, ssh to the master node using the `Master DNS` indicated by the script.
<!-- To obtain the **DNS** (to `ssh` in to the master node) and the **public IP** of the Master node (required to connect to the `JupyterNotebook`), from the terminal execute: 
```bash
tail -4 /tmp/cloudcreation_log.out | head -2
```
-->

## Launching the `JupyterNotebook` with `Hail 0.2`

To launch the  `JupyterNotebook` you need the Master IP address (IPv4) that can be obtained from 1) the terminal by executing: `tail -3 /tmp/cloudcreation_log.out | head -1` or by 2) going to the AWS Management Console website and under `EC2 > Instances` selecting the corresponding `master` node then select the `description tab > Security Groups > view inbound rules`.

Paste the IP in a browser followed by a `:` and port 8192: `PUBLIC_IP_ADDRESS_MASTER_NODE:8192`; use password: *`avillach`* to login. And you are all set! 

### FAQs and troubleshooting 

* EC2 FAQs website: https://aws.amazon.com/ec2/faqs/#How_many_instances_can_I_run_in_Amazon_EC2

* EC2 security groups: https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html#emr-def-sec-groups

* EC2 instance types: https://aws.amazon.com/ec2/instance-types/
