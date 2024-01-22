import json
import os
import boto3
import csv

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        bucket_name = "input-api-bucket"
        file_name = "Book1.csv"

        # Get the CSV file from S3
        s3_response = s3_client.get_object(Bucket='input-api-bucket', Key='Book1.csv')
        csv_content = s3_response["Body"].read().decode('utf-8')

        # Convert CSV to JSON
        csv_rows = csv.reader(csv_content.splitlines())
        headers = next(csv_rows)
        json_data = [dict(zip(headers, row)) for row in csv_rows]

        # Print the JSON data
        print(json.dumps(json_data, indent=2))

        # Return a Lambda proxy integration response
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
            },
            'body': json.dumps(json_data, indent=2)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        # Return an error response
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
            },
            'body': json.dumps({'error': str(e)})
        }
