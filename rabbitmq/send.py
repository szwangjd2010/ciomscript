#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('yunxuetang', 'yunxuetang')
parameters = pika.ConnectionParameters('10.10.118.154',
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
