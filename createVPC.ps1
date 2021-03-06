
#---------------------------------
#Requirements
#---------------------------------
#aws sdk and tools
#---------------------------------

#load AWS PS Modules
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"
Add-Type -Path "C:\Program Files (x86)\AWS SDK for .NET\bin\AWSSDK.dll"

#------------------------------------------
#vars
#------------------------------------------
#aws creds
$awsAccessKey = ""
$awsSecretKey = ""

$vpcCIDR = '10.0.0.0/16'
$vpcPrivSub = '10.0.5.0/24'
$vpcPubSub = '10.0.2.0/24'

$vpcName = "PS Created VPC"

#------------------------------------------


#------------------------------------------
#notes
#------------------------------------------
#launch RS NAT vs created NAT
#name, descriptions for  vpc, subnets
#security groups for pub, priv
#------------------------------------------

#create AWS creds
#set default creds
$awsCreds = New-AWSCredentials -AccessKey $awsAccessKey -SecretKey $awsSecretKey
Set-AWSCredentials -Credentials $awsCreds

#create s3 client
$awsClient = New-Object amazon.S3.AmazonS3Client($awsCreds)
$ec2Client = New-Object amazon.EC2.AmazonEC2Client($awsCreds)
#aws client
$awsClientCfg = New-Object Amazon.S3.AmazonS3Config

$reqVPC = New-Object amazon.EC2.Util.LaunchVPCWithPublicAndPrivateSubnetsRequest
$reqVPC.VPCName = $vpcName
$reqVPC.VPCCidrBlock = $vpcCIDR
$reqVPC.PrivateSubnetCiderBlock = $vpcPrivSub
$reqVPC.PublicSubnetCiderBlock = $vpcPubSub

$resVPCReq = [Amazon.EC2.Util.VPCUtilities]::LaunchVPCWithPublicAndPrivateSubnets($ec2Client,$reqVPC)

#create vpc
$awsVPC = New-EC2Vpc -CidrBlock $vpcCIDR
$awsVPCID = $awsVPC.VpcId

Write-Host "New VPC ID`: $awsVPCID"

#tag VPC
$vpcTag = New-Object amazon.ec2.Model.Tag
$vpcTag.key = "PSCreated"
$vpcTag.value = "PSCreatedVal"

New-EC2Tag -ResourceId $awsVPCID -Tag $vpcTag

#create subnets
Write-Host "Pause"
$vpcSubPrivID = New-EC2Subnet -VpcId $awsVPCID -CidrBlock $vpcPrivSub
$vpcSubPubID = New-EC2Subnet -VpcId $awsVPCID -CidrBlock $vpcPubSub

Write-Host "Priv ID`:  $vpcSubPrivID"
Write-Host "Pub ID`:  $vpcSubPubID"

#create IG - created with call above


#create NAT Host - created but didn't work,  used RS nat


#associate - not needed at this point