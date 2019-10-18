# Hail 0.2 on Amazon EMR: `cloudformation` tool

This `cloudformation` tool creates an EMR cluster under an `emr-5.24.0` release using `Spark 2.4.2` and `Hadoop 2.8.5`, with  `Hail 0.2.x` and `JupyterHub 0.9.6` installed.

## Before using this tool (Prerequisites)

This tool requires the following programs to be installed:

* `Conda` environment manager (We suggest [Miniconda3](https://docs.conda.io/en/latest/miniconda.html))
* `Amazon's Command Line Interface` (CLI) utility (Please refer to the [doc](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) to install and configure AWS CLI - this tool do not support profile)

## How to use this tool

* Open a terminal and clone this repository:

```sh
git clone https://github.com/c-BIG/hail-on-EMR.git
```

* Browse to `src` directory

```sh
cd hail-on-EMR/src/
```

* Create the conda environment shipped with the code.

```sh
# Create conda environment
conda env create -f conda-env.yaml
# Activate conda environment
conda activate hail
```

* Create a configuration file named `hail02_EMR.yaml`

```sh
touch hail02_EMR.yaml
```

* Edit the configuration file using your personal key and requirements

```yaml
config:
  EMR_CLUSTER_NAME: "my-hail-02-cluster" # Give a name to the EMR cluster
  EC2_NAME_TAG: "my-hail-EMR" # Tags for the individual EC2 instances
  OWNER_TAG: "emr-owner" # EC2 owner tag
  PROJECT_TAG: "my-project" # Project tag
  REGION: "ap-southeast-1" # AWS Region tag
  S3_BUCKET: "s3n://my-s3-bucket/" # Input your project's S3 bucket
  KEY_NAME: "my-key" # Input your key name DO NOT include the .pem extension
  PATH_TO_KEY: "/full-path/to-key/" # Full path to .pem file
  MASTER_INSTANCE_TYPE: "c5.4xlarge" # Suggested EC2 instances, change as desired
  CORE_INSTANCE_TYPE: "c5.4xlarge" # Suggested EC2 instances, change as desired
  CORE_COUNT: "3" # Number of cores. Additional reference in the EC2 FAQs website
  CORE_EBS_SIZE: "150" #
  SUBNET_ID: "subnet-12345" # Select you private subnet. See the EC2 FAQs website
  CORE_SECURITY_GROUP: "" # Creates a new group by default. You can also add a specific SG. See the SG link in the FAQs section
  MASTER_SECURITY_GROUP: "" # Creates a new group by default. You can also add a specific SG. See the SG link in the FAQs section
  RELEASE_LABEL: "emr-5.24.0"
```

This script is defaulted to region `ap-southeast-1`, instances `c5.4xlarge` : 3 `cores` and 1 `master`. For additional configuration details regarding the `emr-5.24.0` release, visit: <https://console.aws.amazon.com/elasticmapreduce/home?region=ap-southeast-1#quick-create\:>.

|Suggested **`INSTANCE_TYPE`s** |
|:-------------------------:|
| m5.large |
| m5.xlarge |
| m5.2xlarge |
| m5.4xlarge |
| m5.8xlarge |
| m5.12xlarge |
| c5.large |
| c5.xlarge |
| c5.2xlarge |
| c5.4xlarge |
| c4.9xlarge |
| r5.xlarge |
| r5.2xlarge |
| r5.4xlarge |
| r5.8xlarge |

See instance details at: <https://aws.amazon.com/ec2/instance-types/>

* Launch the installation of the EMR

```sh
python install2.py
```

The EMR creation is initiated. The status of the cluster is monitored and will undergo from `STARTING` to `RUNNING` and `WAITING`.

Once the cluster is succesfully created and is in `WAITING` status, the installation of `HAIL` is initiated.

Once the installation of Hail is done, ssh to the master node using the `Master DNS` indicated by the script.

```sh
# Save Master node DNS
export MASTER= # ec2-...compute.amazonaws.com
# Open SSH with a tunnel for JupyterHub
ssh -i path/to/aws_key.pem -L 9443:$MASTER:9443 hadoop@$MASTER
```

We need to wait for `hail` to be installed on all the node. For that we can check the path below:

```sh
ls /opt/hail
# hail-all-spark.jar  python
```

We can now use `pyspark` and `hail` on the master node.

In addition we can create jupyther notebooks on the server using `JupyterHub`.

* Visite `JupyterHub` at <https://localhost:9443/hub/login>
* Enter default username: `jovyan`
* Enter default password: `jupyter`
