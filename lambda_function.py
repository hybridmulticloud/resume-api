import boto3
import os

def lambda_handler(event, context):
    table_name = os.environ['TABLE_NAME']
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)

    response = table.update_item(
        Key={'id': 'visitor-count'},
        UpdateExpression='ADD visits :inc',
        ExpressionAttributeValues={':inc': 1},
        ReturnValues='UPDATED_NEW'
    )

    return {
        'statusCode': 200,
        'headers': { "Access-Control-Allow-Origin": "*" },
        'body': f'{{"visits": {int(response["Attributes"]["visits"])}}}'
    }