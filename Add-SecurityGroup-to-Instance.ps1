$instances = @("i-00000000000000000",
               "i-00000000000000001")

$tempSecGroup = "sg-0000"

foreach ($instance in $instances) {
    
$sgs = aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*]' | ConvertFrom-Json
$allSGs = $sgs.SecurityGroups.GroupId
Write-Output "`r`nCurrent SGs attached to $instance are `r`n $allSGs"
$allSGs += $tempSecGroup
aws ec2 modify-instance-attribute --instance-id $instance --groups $allSGs

$newSgs = aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*]' | ConvertFrom-Json
$allNewSGs = $newSgs.SecurityGroups.GroupId
Write-Output "`r`nNew SGs attached to $instance are `r`n $allNewSGs"

}