import boto3
from PIL import Image
from io import BytesIO
import os

s3 = boto3.client('s3')
dest_bucket = os.environ['DEST_BUCKET']

def lambda_handler(event, context):
    for record in event['Records']:
        src_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        obj = s3.get_object(Bucket=src_bucket, Key=key)
        img = Image.open(obj['Body'])

        # Strip EXIF
        buffer = BytesIO()
        img.save(buffer, format='JPEG')
        buffer.seek(0)

        s3.upload_fileobj(buffer, dest_bucket, key)

    return {"statusCode": 200, "body": "EXIF removed"}