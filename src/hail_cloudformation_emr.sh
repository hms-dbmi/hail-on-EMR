#!/bin/bash
set -x -e

echo "Generating the EMR cluster. See log details at /tmp/cloudcreation_log.out"
# https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
# Log setup
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/cloudcreation_log.out 2>&1

# Check if pip is installed 
PIP=$(which pip)
if [ -z "$PIP" ]; then
	echo "Installing pip..."
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python get-pip.py
	rm get-pip.py
fi 

# Install the AWS command tool
AWS=$(which aws)
if [ -z "$AWS" ]; then
	printf "\n\nInstalling aws command tool...\n\n"
	pip install awscli --upgrade --user -q
fi

# Save the AWS Keys to the default folder 
CREDENTIALS=$(ls  ~/.aws)
if [ -z "$CREDENTIALS" ]; then
	echo "Your AWS configuration file is required!"
	echio "For help visit:"
	echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html"
	echo "See your accessKeys.csv file to find the Access Keys"
	printf "\n\n Your inputs should look like this:\n\n"
	echo "AWS Access Key ID [None]: AKIAIEXAMPLEKEY"
	echo "AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
	echo "Default region name [None]: us-east-1"
	echo "Default output format [None]: json"
	print "\n\n"
	aws configure
else 
	echo "Using existing AWS credentials..."
	echo "To reconfigure run: aws configure"
	echo "For help visit: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html"
fi

echo "Installing required packages..."
pip install boto3 pandas botocore paramiko pyyaml -q #parallel-ssh 
pip install -U pip -q 
pip uninstall -y greenlet -q
pip install -Iv greenlet==0.4.13 -q

echo "Starting EMR cluster..."
# cd /Users/carlos/Desktop/Harvard_2018/Code_and_Notes/AWS/cloudformation_Hail/
# . hail02_EMR.yaml;python3 EMR_deploy_and_install.py
python3 EMR_deploy_and_install.py
