#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('yxt', '8cc3fbeea7a8ec58f550f2eb31ec8a071e1ae077971a7a470f7e36f8f4ba8437')
parameters = pika.ConnectionParameters('10.10.106.125',
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
