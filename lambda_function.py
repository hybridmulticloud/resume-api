import json
import boto3
import logging

# Setup logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('VisitorCount')

def lambda_handler(event, context):
    logger.info("Lambda invoked with event: %s", json.dumps(event))

    try:
        response = table.update_item(
            Key={'id': 'count'},
            UpdateExpression='SET visits = visits + :inc',
            ExpressionAttributeValues={':inc': 1},
            ReturnValues='UPDATED_NEW'
        )
        visits = int(response['Attributes']['visits'])
        logger.info("Visit count updated successfully: %d", visits)

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'visits': visits})
        }

    except Exception as e:
        logger.error("Error updating visit count: %s", str(e), exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal Server Error'})
        }
