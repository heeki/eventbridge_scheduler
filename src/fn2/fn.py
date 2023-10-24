import boto3
import json
from datetime import datetime
from aws_xray_sdk.core import patch_all

# initialization
session = boto3.session.Session()
client = session.client('sqs')
patch_all()

def handler(event, context):
    output = event
    print(json.dumps(output))
    timestamp = datetime.strptime(event.get("time"), "%Y-%m-%dT%H:%M:%SZ")
    print(json.dumps({"timestamp": timestamp.isoformat()}))
    return output
