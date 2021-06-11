# View instances and their names/private IPs
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`],PrivateIpAddress]' \
    --filters "Name=instance-state-name,Values=running" "Name=tag-key,Values=Name" "Name=tag-value,Values=*$name_tag*" \
    --output text

# Detach volume
aws ec2 detach-volume --volume-id $volumeid

# Show volumes for instances matching particular product tag
aws --profile ${aws_profile} ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
        "Name=tag-key,Values=product" \
        "Name=tag-value,Values=some-product" \
    --query 'Reservations[*].Instances[*].[[BlockDeviceMappings[*].Ebs.VolumeId],[Tags[?Key==`Name`].Value]]' \
    --output text

# Get instance metadata
wget -q -O - http://169.254.169.254/latest/meta-data/instance-id

# Get instance tags
aws ec2 describe-tags --filters "Name=resource-id,Values=i-12345" --region us-east-1

# Get tags from within an instance
aws ec2 describe-tags \
    --filter Name=resource-id,Values=$(curl \
        --silent http://169.254.169.254/latest/meta-data/instance-id) | grep "aws_role" | awk '{ print $2 }' | sed 's/\"//g'

# Run individual cloud-init modules
cloud-init -d init
cloud-init -d modules
cloud-init -d single -n growpart

# List the names and creation dates for AMIs in your account
aws ec2 describe-images \
    --owners self \
    --filters "Name=tag:Name,Values=some_ami**" \
    --query 'Images[*].{ID:Name,Date:CreationDate}'

# Specify a different profile
aws ec2 --profile $profile-name  --region=us-east-1

# In python:
>>> session = boto3.Session(profile_name='organization')
>>> ec2 = session.client('ec2', region_name='us-east-1')

# Stress test CPU on an AWS EC2 instance:
sysbench --test=cpu --cpu-max-prime=20000 run

# View IAM user policies
aws iam list-user-policies --user-name sysop 

# Provision a Service Catalog product (Remember that provisioning-artifact-id is the version number of the product's CF template):
aws servicecatalog provision-product \
    --product-id prod-emxq4fiicciey \
    --provisioning-artifact-id "pa-artifact-id" \
    --provision-token "test01" \
    --provisioned-product-name "some_product" \
    --region us-east-1

# Describe a Service Catalog product:
aws servicecatalog --region us-east-1 describe-record --id "rec-123456"

# Copy files to S3 and encrypt them at rest
aws s3 cp test_file_20170718 s3://bucket-input/ \
    --sse aws:kms \
    --sse-kms-key-id "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"

# Activate a file gateway
aws storagegateway activate-gateway \
    --gateway-name "aws_file_gateway" \
    --gateway-timezone "GMT-5:00" \
    --gateway-region "us-east-1" \
    --gateway-type "FILE_S3" \
    --activation-key "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"

# Mount an S3 bucket using file/storage gateway
aws storagegateway create-nfs-file-share \
    --kms-encrypted --kms-key "arn:aws:kms:us-east-1:01234567890:key/lolololol" \
    --role "arn:aws:iam::1234567890:role/storage-gateway-role" \
    --default-storage-class "S3_STANDARD" \
    --nfs-file-share-defaults "FileMode=0666,DirectoryMode=0777,GroupId=10255,OwnerId=29704" \
    --gateway-arn "arn:aws:storagegateway:us-east-1:01234567890:gateway/sgw-lolololol" \
    --client-list "10.0.0.0/23" \
    --client-token "bucket-input" \
    --location-arn "arn:aws:s3:::bucket-input" \
    --region us-east-1

# Get ActivationID of a File/Storage Gateway appliance
curl -X GET http://10.114.4.253:80 -I -L -k

# Update DynamoDB item and its attribute
aws dynamodb update-item \
    --table-name $table_name \
    --key '{"hostname": {"S": $(hostname -f)}}' \
    --expression-attribute-values '{":val": {"S": "false"}}' \
    --update-expression "SET attribute_name = :val" \
    --reorganization-values UPDATED_NEW \
    --region us-east-1

# Show IP address info for instances with specific tag
aws ec2 describe-instances \
    --filters Name=tag:product,Values="some_product_tag" \
    --color on \
    --query 'Reservations[*].Instances[*].[ImageId,PrivateIpAddress]'

# Show security groups for an instance
aws ec2 describe-instances \
    --filters Name=tag:Name,Values="some-server11.some.domain.com" \
    --color on \
    --query 'Reservations[*].Instances[*].[ImageId,SecurityGroups[*]]'

# Show instances with IPv4 address
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --color on \
    --query 'Reservations[*].Instances[*].[[Tags[?Key==`Name`].Value],PrivateIpAddress]' \
    --output table

# Show instances that belong to some-product-value tag-value
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" "Name=tag-value,Values=some-product-value" \
    --color on \
    --query 'Reservations[*].Instances[*].{name: Tags[?Key==`Name`] | [0].Value, product: Tags[?Key==`product`] | [0].Value,IPv4: PrivateIpAddress}' \
    --output table

# Resource groups
aws resource-groups list-group-resources \
    --group-name lab-some-product-value \
    --query ResourceIdentifiers[*].ResourceArn

# SSM - Send Command
aws ssm send-command \
    --instance-ids i-12345 \
    --document-name "AWS-RunShellScript" \
    --parameters '{"commands":["whoami;echo hello world"], "executionTimeout":["120"]}' \
    --timeout-seconds 600

# SSM - Get Command Results
aws ssm get-command-invocation \
    --instance-id i-12345 \
    --command-id 56c1e560-3059-41fe-a57d-6daef7bc3368

# Get instance hostname
aws --profile profile-name ec2 describe-tags \
    --filters "Name=resource-id,Values=i-12345" \
    --query 'Tags[?Key==`fqdn`].Value' \
    --output text

# Get STS token details
aws sts get-caller-identity

# Query images newer than specific date
datestamp=$(date +%Y-%m-%d)
aws ec2 describe-images \
    --owners self \
    --filters "Name=tag:Name,Values=GOLDEN_AMI*" \
    --query "Images[?CreationDate >= \`${datestamp}\`].ImageId" \
    --output text

# Launch an instance
cat <<EOF > userdata.sh
#!/bin/bash
yum install -y nginx
systemctl enable nginx && systemctl start nginx
bash starorganizationp.sh | tee /var/tmp/ami_tests.out
EOF
aws ec2 run-instances \
    --image-id ${image_id} \
    --key-name "" \
    --instance-type "t2.small" \
    --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=ami-testing},{Key=owner,Value=sysop},{Key=product,Value=infra},{Key=unit,Value=infra-team}]" \
    --security-group-ids "sg-12345" \
    --subnet-id "subnet-12345" \
    --count 1 \
    --iam-instance-profile "Name=instance-profile-name" \"
    --user-data file://userdata.sh
aws ec2 run-instances \
    --image-id ami-12345 \
    --key-name "" \
    --instance-type "t2.small" \
    --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=ami-testing},{Key=owner,Value=sysop},{Key=product,Value=infra},{Key=unit,Value=infra-team}]" \
    --security-group-ids "sg-12345" \
    --subnet-id "subnet-12345" \
    --count 1 \
    --iam-instance-profile "Arn=arn:aws:iam::01234567890:instance-profile/secrets-mgmt-dev-aws-bastion-ssm-instance-profile" \
    --region us-east-1

# Get VPN organizationnnel details
aws ec2 describe-vpn-connections \
    --query "VpnConnections[].[[Tags[?Key=='Name'].Value],VgwTelemetry,CustomerGatewayId,VpnGatewayId]" \
    --output text \
    --region us-east-1

# Describe VPN gateways
$ aws ec2 describe-vpn-gateways \
    --vpn-gateway-ids $(aws ec2 describe-vpn-connections \
        --query "VpnConnections[].VpnGatewayId" \
        --output text \
        --region us-east-1) \
    --query "VpnGateways[].[[VpnGatewayId,Tags[?Key=='Name'].Value]]" \
    --region us-east-1 \
    --output text

# List objects with storage classes within an S3 bucket
aws s3api list-objects --bucket ${bucket_name} --query 'Contents[].[Key,[?StorageClass=`GLACIER`]]'
