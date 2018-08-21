#!/bin/bash -x -e

echo "Generating the EMR cluster. See log details at /tmp/cloudcreation_log.out"

# Check if python3 is installed 
BREW=$(which brew)
	if [ -z "$BREW" ]; then
		echo "\n\nInstalling Homebrew..."
		sleep 1
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
PYTH==$(which python3)

if [ -z "$PYTH" ]; then
	echo "\n\nInstalling Python3..."
	sleep 1
	brew install python3
fi

python3 -m pip install --upgrade pip

# Install the AWS command tool
brew install awscli


# Save the AWS Keys to the default folder 
CREDENTIALS=$(ls  ~/.aws)
if [ -z "$CREDENTIALS" ]; then
	echo "Your AWS configuration file is required!"
	echo "For help visit:"
	echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html"
	echo "See your accessKeys.csv file to find the Access Keys"
	echo "\n\n Your inputs should look like this:\n\n"
	echo "AWS Access Key ID [None]: AKIAIEXAMPLEKEY"
	echo "AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
	echo "Default region name [None]: us-east-1"
	echo "Default output format [None]: json"
	echo "\n\n"
	aws configure
else 
	echo "Using existing AWS credentials..."
	echo "To reconfigure run: aws configure"
	echo "For help visit: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html"
	read -n 1 -s -r -p "Press any key to continue cloudformation"
fi

echo "\n\nInstalling required packages..."
pip3 install boto3 pandas botocore paramiko pyyaml -q #parallel-ssh 
# pip install -U pip -q 
# pip uninstall -y greenlet -q
# pip install -Iv greenlet==0.4.13 -q

echo "Starting EMR cluster..."
python3 EMR_deploy_and_install.py
