$instances = @("i-00000000000000000",
               "i-00000000000000001")

$tempSecGroup = "sg-0000"

foreach ($instance in $instances) {
    
$sgs = aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*]' | ConvertFrom-Json
$allSGs = $sgs.SecurityGroups.GroupId
Write-Output "`r`nCurrent SGs attached to $instance are `r`n $allSGs"
$removeTempSg = $allSGs -replace $tempSecGroup -replace ""
aws ec2 modify-instance-attribute --instance-id $instance --groups $removeTempSg

$removedSgs = aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*]' | ConvertFrom-Json
$allRemovedSGs = $removedSgs.SecurityGroups.GroupId
Write-Output "`r`nNew SGs attached to $instance are `r`n $allRemovedSGs"

}