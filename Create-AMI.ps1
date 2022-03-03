$ec2names = @("server01",
              "server02")

$description = "Prior to Ubuntu 20.04 upgrade"
$env = "test"

foreach ($ec2name in $ec2names) {

    $ec2Object = aws ec2 describe-instances --filters Name=tag-value,Values=$ec2name Name=tag-key,Values=Name Name=tag-value,Values=$env Name=tag-key,Values=Env | ConvertFrom-Json
    $instanceId = $ec2Object.Reservations.Instances.InstanceId
    
    aws ec2 stop-instances --instance-ids $instanceId

} # end foreach

$ec2Status = "stopping"

foreach ($ec2name in $ec2names) {
    
    while ($ec2Status -ne "stopped") {
        Write-Output "$ec2name is $ec2Status..."
        $ec2Status = (aws ec2 describe-instances --filters Name=tag-value,Values=$ec2name Name=tag-key,Values=Name Name=tag-value,Values=$env Name=tag-key,Values=Env | ConvertFrom-Json).Reservations.Instances.State.Name
    } # end while

    Write-Output "$ec2name is $ec2Status"
 
} # end foreach

foreach ($ec2name in $ec2names) {

    $ec2Object = aws ec2 describe-instances --filters Name=tag-value,Values=$ec2name Name=tag-key,Values=Name Name=tag-value,Values=$env Name=tag-key,Values=Env | ConvertFrom-Json
    $instanceId = $ec2Object.Reservations.Instances.InstanceId
    $amiName = $ec2name + "_priortoUbuntu20upgrade_" + $env
    $amiTagName = "ami_" + $ec2name + "_priortoUbuntu20upgrade_" + $env

    ## Create a new AMI from an EC2 Instance
    aws ec2 create-image `
        --instance-id $instanceId `
        --name $amiName `
        --description $description `
        --no-reboot

    $amiId = aws ec2 describe-images --filter "Name=name,Values=$amiName" --query 'Images[*].[ImageId]' --output text

    aws ec2 create-tags --resources $amiId --tags Key=Name,Value=$amiTagName

} # end foreach

foreach ($ec2name in $ec2names) {

    $amiName = $ec2name + "_priortoUbuntu20upgrade_" + $env
    $amiId = aws ec2 describe-images --filter "Name=name,Values=$amiName" --query 'Images[*].[ImageId]' --output text
    $amiState = (aws ec2 describe-images --image-ids $amiId | ConvertFrom-Json).Images.State
    
    while ($amiState -ne "available") {
        
        Write-Output "The status of $amiName is $amiState..."
        Start-Sleep -s 4
        $amiState = (aws ec2 describe-images --image-ids $amiId | ConvertFrom-Json).Images.State
    }
} # end

foreach ($ec2name in $ec2names) {

    $ec2Object = aws ec2 describe-instances --filters Name=tag-value,Values=$ec2name Name=tag-key,Values=Name Name=tag-value,Values=$env Name=tag-key,Values=Env | ConvertFrom-Json
    $instanceId = $ec2Object.Reservations.Instances.InstanceId
    aws ec2 start-instances --instance-ids $instanceId

} # end foreach

foreach ($ec2name in $ec2names) {

    $ec2Status = "pending"

    while ($ec2Status -ne "running") {

        Write-Output "$ec2name is $ec2Status..."
        $ec2Status = (aws ec2 describe-instances --filters Name=tag-value,Values=$ec2name Name=tag-key,Values=Name Name=tag-value,Values=$env Name=tag-key,Values=Env | ConvertFrom-Json).Reservations.Instances.State.Name

    } # end while

    Write-Output "$ec2name is $ec2Status"

} # end foreach