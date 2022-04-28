from logging import exception, info
import pika
import os, ssl
import json


#ENV lambda
url = os.environ['RABBITMQ_HOST']
username = os.environ['USER_NAME']
userpasswd = os.environ['USER_PASS']
exchange = os.environ['EXCHANGE_NAME']
que = os.environ['QUE']


#ENV local
def lambda_handler(event, lambda_context):
    """Send msg to rabbitmq

    Args:
        event (dict): contain msg to send

    Returns:
        status: only 200 for now
    """    
    channel, connection = create_connection(url,username,userpasswd)

    #sending msg to rabbitmq
    try:
        channel.queue_declare(queue=que)
        channel.exchange_declare(exchange=exchange,
            exchange_type='direct')
        channel.queue_bind(exchange=exchange, queue='hello')
        message = event.get("msg")
        channel.basic_publish(exchange=exchange,
            routing_key=que,
            body=message)

        info(" [x] sent ", message)
    except Exception as e:
        raise Exception("Unable to send msg rabbitmq: " + str(e)) 
    finally:
        connection.close()

    return {
        'statusCode': 200,
        'body': json.dumps(" [x] Sent "+ message)
        }


def create_connection(url,username,userpasswd):
    """create connection to rabbitmq

    Args:
        url (str): rabbitmqurl
        username (str): rabbitmq username
        userpasswd (str): rabbitmq passowrd

    Raises:
        Exception: unable to connect

    Returns:
        channel, connection
    """    
    try:
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        ssl_context.set_ciphers('ECDHE+AESGCM:!ECDSA')
        parameters = pika.URLParameters(url)
        parameters.ssl_options = pika.SSLOptions(context=ssl_context)
        parameters.credentials = pika.PlainCredentials(username, userpasswd)
        connection = pika.BlockingConnection(parameters)
        info("connection made to rabbitmq")
        channel = connection.channel()
        return channel,connection

    except Exception as e:
        raise Exception("Unable to connect rabbitmq: " + str(e)) 
   