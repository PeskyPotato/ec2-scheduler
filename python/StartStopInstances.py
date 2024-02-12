import json
import boto3

def lambda_handler(event, context):
    print(event)
    instance_start = event["start"]
    instance_state = "running"
    if instance_start:
        instance_state = "stopped"
    instance_tag_name = event["tag_name"]
    instance_tag_value = event["tag_value"]

    ec2 = boto3.client('ec2')
    r = ec2.describe_instances(
        Filters = [
            {
                "Name":f"tag:{instance_tag_name}", "Values": [instance_tag_value]
            },
            {
                "Name": "instance-state-name", "Values": [instance_state]
            }
        ]
    )

    instances = []
    for reservation in r["Reservations"]:
        for instance in reservation["Instances"]:
            instances.append(instance["InstanceId"])

    if instance_start:
        r = ec2.start_instances(InstanceIds=instances)
    else:
        r = ec2.stop_instances(InstanceIds=instances)

    print(r)
    return {
        'statusCode': 200,
        'body': json.dumps(r)
    }
