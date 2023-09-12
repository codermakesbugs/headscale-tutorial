#!/usr/bin/env bash

# -e Exit immediately if a pipeline was failed.
# -o Set the option corresponding to option-name. 
# pipefail If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
# -u Treat unset variables and parameters other than the special parameters @’ or ‘*’, or array variables subscripted with ‘@’ or ‘*’ as an error when performing parameter expansion.
set -u -Ee -o pipefail

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if required command existed.
REQUIRED_COMMANDS="butane aws"
for i in $REQUIRED_COMMANDS
do
  if ! command -v "$i" > /dev/null; then
    echo "$i command not found."
    exit 1
  fi
done

# Convert Butane config to Ignition config.
butane --pretty --strict "$SCRIPT_DIRECTORY/headscale.bu" \
    > "$SCRIPT_DIRECTORY/headscale.ign"

# Provision AWS EC2 instance
NAME="headscale-server"
SSH_KEY=""                                      # the name of your SSH key: `aws ec2 describe-key-pairs`
IMAGE="ami-02acaf802ebcfdfde"                                     # the AMI ID found on the latest CoreOS version https://fedoraproject.org/coreos/download/?stream=stable&arch=x86_64#download_section
ROOT_DISK="16"                                                    # the size of the root disk
APPS_DISK="16"                                                    # the size of the apps disk
TYPE=""                                                           # the instance type
REGION=""                                                         # the target region
SUBNET=""                                                         # Subnet ID of `sub:/aps1/c/pub`. Obtained from `aws ec2 describe-subnets`
SECURITY_GROUPS=""                                                # Security Group ID of `sg:/aps1/vpn`. Obtained from `aws ec2 describe-security-groups`
USERDATA="$SCRIPT_DIRECTORY/headscale.ign"                        # path to your Ignition config
TAGS="[                                                               \
  {Key=Name, Value=$NAME},                                            \
]"
INSTANCE_ID="$(aws ec2 run-instances                        \
    --region "$REGION"                                      \
    --image-id "$IMAGE"                                     \
    --instance-type "$TYPE"                                 \
    --key-name "$SSH_KEY"                                   \
    --subnet-id "$SUBNET"                                   \
    --security-group-ids "$SECURITY_GROUPS"                 \
    --user-data "file://$USERDATA"                          \
    --associate-public-ip-address                           \
    --tag-specifications "ResourceType=instance,Tags=$TAGS" \
    --block-device-mappings "DeviceName=/dev/xvda,Ebs={VolumeSize=$ROOT_DISK,VolumeType=gp3,DeleteOnTermination=true}" "DeviceName=/dev/xvdb,Ebs={VolumeSize=$APPS_DISK,VolumeType=gp3,DeleteOnTermination=true,Encrypted=true}" \
    --query "Instances[].InstanceId" \
    --output text)"

echo "Creating the AWS EC2 instance was successful. INSTANCE_ID = $INSTANCE_ID"