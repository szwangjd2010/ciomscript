#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('yxt', 'pwdasdwx')
parameters = pika.ConnectionParameters('10.4.36.230',
                                       5672,
                                       '/',
                                       credentials)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()
channel.queue_declare(queue='hello')
channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!')
print " [x] Sent 'Hello World!'"
connection.close()
