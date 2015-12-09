#!/usr/bin/env python
import pika
credentials = pika.PlainCredentials('starfish', 'mLjhKmZ4')
parameters = pika.ConnectionParameters('10.10.118.154',
                                       5672,
                                       '/',
                                       credentials)
#credentials = pika.PlainCredentials('yunxuetang', 'yunxuetang')
#parameters = pika.ConnectionParameters('10.4.39.162',
#                                       5672,
#                                       'yxtmq',
#                                       credentials)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()
channel.queue_declare(queue='sdfsdafsdfabv')
channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!')
print " [x] Sent 'Hello World!'"
connection.close()
