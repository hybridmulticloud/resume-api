import json
import boto3

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor_count')

def lambda_handler(event, context):
    response = table.update_item(
        Key={'id': 'count'},
        UpdateExpression='SET visits = visits + :inc',
        ExpressionAttributeValues={':inc': 1},
        ReturnValues='UPDATED_NEW'
    )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'visits': int(response['Attributes']['visits'])
        })
    }
