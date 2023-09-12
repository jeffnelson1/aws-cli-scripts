$instances = Get-Content -path "./instances.txt"

foreach ($instance in $instances) {

    Write-output("Changing instance type on $instance")
    aws ec2 modify-instance-attribute --instance-id $instance --instance-type "t3.small" --region us-west-2
    
}