$data = Import-Csv ./servers.csv

foreach ($object in $data) {

    ## Define variables
    $serverName = $object.server
    $sgName = $serverName + "-" + "sg"
    $vpcId = "vpc-1111111"

    Write-Output "Creating SG for $serverName..."

    $sgGroupId = (aws ec2 create-security-group --group-name $sgName `
    --description "Security group for EC2 instance - $serverName" `
    --vpc-id $vpcId | ConvertFrom-Json).GroupId

    aws ec2 create-tags `
    --resources $sgGroupId `
    --tags Key=Name,Value=$sgName

    Write-Output "Creating SG rule(s) for $sgName..."

    aws ec2 authorize-security-group-ingress `
    --group-id $sgGroupId `
    --protocol -1 `
    --port -1 `
    --cidr 10.0.0.0/8

}