$data = Import-Csv ./servers.csv

$obj = New-Object -TypeName psobject

foreach ($object in $data) {

    $serverName = $object.server
    $instance = aws ec2 describe-instances --filters "Name=tag:Name,Values=$serverName" | ConvertFrom-json
    $instanceId = $instance.Reservations.Instances.InstanceId
    $vpcId = $instance.Reservations.Instances.NetworkInterfaces.VpcId
    $avZone = $instance.Reservations.Instances.Placement.AvailabilityZone
    $iamRoleArn = $instance.Reservations.Instances.IamInstanceProfile.Arn
    $iamRoleName = $iamRoleArn.Split("/")[1]

    $privIps = $null
    $privateIps = $instance.Reservations.Instances.NetworkInterfaces.PrivateIpaddresses.PrivateIPaddress
    foreach ($ip in $privateIps) {
        $privIps += $ip += ", "
        
    }

    $sgGroups = $null
    $securityGroups = $instance.Reservations.Instances.NetworkInterfaces.Groups.GroupName
    foreach ($group in $securityGroups) {
        $sgGroups += $group += ", "
        
    }

    $tKeys = $null
    $tagKeys = $instance.Reservations.Instances.Tags.Key
    foreach ($key in $tagKeys) {
        $tKeys += $key += ", "
        
    }

    $tValues = $null
    $tagValues = $instance.Reservations.Instances.Tags.Value
    foreach ($value in $tagValues) {
        $tValues += $value += ", "
        
    }
    
    $subnetId = $instance.Reservations.Instances.NetworkInterfaces.SubnetId
    $instanceType = $instance.Reservations.Instances.InstanceType
    $termProtectionStatus = (aws ec2 describe-instance-attribute --instance-id $instanceId --attribute disableApiTermination | ConvertFrom-Json).DisableApiTermination.Value

$obj = New-Object PSObject -Property @{
    Server = $serverName
    InstanceID = $instanceId
    Private_IP = $privIps
    SG_Names = $sgGroups
    IAM_Role = $iamRoleName
    VPC_ID = $vpcId
    Subnet_ID = $subnetId
    Availability_Zone = $avZone
    Instance_Type = $instanceType
    Termination_Protection_Enabled = $termProtectionStatus
    Tag_Keys = $tKeys
    Tag_Values = $tValues
}
   
$obj | Select-Object Server, InstanceID, Private_IP, SG_Names, IAM_Role, VPC_ID, Subnet_ID, Availability_Zone, Instance_Type, Termination_Protection_Enabled, Tag_Keys, Tag_Values | Format-Table
$obj | Select-Object Server, InstanceID, Private_IP, SG_Names, IAM_Role, VPC_ID, Subnet_ID, Availability_Zone, Instance_Type, Termination_Protection_Enabled, Tag_Keys, Tag_Values | export-CSV '.\ServerInfo.csv' -Append

}