#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('starfish', 'mLjhKmZ4')
parameters = pika.ConnectionParameters('10.10.118.154',
                                       5672,
                                       '/',
                                       credentials)
connection = pika.BlockingConnection(parameters)

channel = connection.channel()

channel.queue_declare(queue='hello')

print ' [*] Waiting for messages. To exit press CTRL+C'

def callback(ch, method, properties, body):
    print " [x] Received %r" % (body,)

channel.basic_consume(callback,
                      queue='hello',
                      no_ack=True)

channel.start_consuming()