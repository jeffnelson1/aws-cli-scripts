$instances = Get-Content -path "./startstopinstances.txt"

foreach ($instance in $instances) {

    Write-output("Starting instance $instance")
    aws ec2 start-instances --instance-ids $instance --region us-west-2
    
}