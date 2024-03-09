#!/bin/bash

#Variables
Region="ap-south-1"
VPC_cidr_block="10.0.0.0/26"
subnet_cidr_block="10.0.0.0/28"
Availability_Zone="ap-south-1a"
SecurityGroup="MySecurityGroup"
AMI_ID="ami-03bb6d83c60fc5f7c"
Key="kp_aws_mumbai"
Instance_Type="t2.micro"


echo " Your VPC is created successfully"
#aws ec2 describe-vpcs --query "Vpcs[*].[CidrBlock]" --output table
Vpc_ID=$(aws ec2 create-vpc --cidr-block $VPC_cidr_block --region $Region --query "Vpc.[VpcId]"  --output text)

echo "Your subnet created successfully"
Subnet_ID=$(aws ec2 create-subnet --vpc-id $Vpc_ID --cidr-block $subnet_cidr_block --availability-zone $Availability_Zone --query "Subnet.[SubnetId]" --output text)

echo "Your Internet Gateway created successfully"
IGW=$(aws ec2 create-internet-gateway --query "InternetGateway.[InternetGatewayId]" --output text)

echo "Internet gateway attched successfully to VPC"
aws ec2 attach-internet-gateway --internet-gateway-id $IGW --vpc-id $Vpc_ID

echo " Route table creted successfully"
Route_table=$(aws ec2 create-route-table --vpc-id $Vpc_ID --query "RouteTable.[RouteTableId]" --output text)

echo "Associates subnet with your rouble table successfully"
aws ec2 associate-route-table --route-table-id $Route_table --subnet-id $Subnet_ID

echo "Created Internet Gateway route in route table successfully"
aws ec2 create-route --route-table-id $Route_table --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW

echo "Security Group created successfully"
Security_Group=$(aws ec2 create-security-group --group-name $SecurityGroup --vpc-id $Vpc_ID --description "My security Group" --output text)

echo "Inbound rule successfully set for security Group"
aws ec2 authorize-security-group-ingress --group-id $Security_Group --protocol tcp --port 22 --cidr 0.0.0.0/0

echo " EC2 instance created successfully"
aws ec2 run-instances --image-id $AMI_ID --instance-type $Instance_Type --key-name $Key --security-group-ids $Security_Group --subnet-id $Subnet_ID --associate-public-ip-address
