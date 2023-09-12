$instances = Get-Content -path "./startstopinstances.txt"

foreach ($instance in $instances) {

    Write-output("Stopping instance $instance")
    aws ec2 stop-instances --instance-ids $instance --region us-west-2
    
}