import json
from logging import log, info
import base64
def lambda_handler(event, context):
    """get msg from rabbitmq

    Args:
        event (dict): contain msg from rabbitmq
    Returns:
        200 : for now
    """    
    info("Event received by invoke lambda: ", event)
    if 'rmqMessagesByQueue' not in event:
        info("Invalid event data")
        return {
            'statusCode': 404
        }
    print(f'Div Data received from event source: ')

    for queue in event["rmqMessagesByQueue"]:
        messageCnt = len(event['rmqMessagesByQueue'][queue])
        print(f'Total messages received from event source: {messageCnt}' )
        for message in event['rmqMessagesByQueue'][queue]:
            data = base64.b64decode(message['data'])
            print(data)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }