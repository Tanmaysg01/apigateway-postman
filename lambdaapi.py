import json
import boto3
 
def lambda_handler(event, context):
    # Your S3 bucket and file name
    bucket_name = 'out-input-api-bucket'
    file_key = 'output.csv'
 
    # Your JSON data
    json_data = {
        "get" : 1,
        "put" : 2,
        "post" : 3,
        # Add more key-value pairs as needed
    }
 
    # Convert the JSON data to a string
    json_string = json.dumps(json_data, indent=2)
 
    # Create an S3 client
    s3 = boto3.client('s3')
 
    # Put the JSON string into the specified S3 object
    s3.put_object(Body=json_string, Bucket=bucket_name, Key=file_key)
 
    return {
        'statusCode': 200,
        'body': json.dumps('JSON data written to S3 successfully!')
    }