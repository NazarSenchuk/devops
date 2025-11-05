#!/usr/bin/env python3
"""
Simple Kafka Consumer for testing
"""
from kafka import KafkaConsumer
import json
import time
from datetime import datetime

class SimpleKafkaConsumer:
    def __init__(self, bootstrap_servers, group_id):
        self.consumer = KafkaConsumer(
            bootstrap_servers=bootstrap_servers,
            group_id=group_id,
            value_deserializer=lambda v: json.loads(v.decode('utf-8')),
            key_deserializer=lambda v: v.decode('utf-8') if v else None,
            auto_offset_reset='earliest',  # Start from beginning if no offset
            enable_auto_commit=True,       # Automatically commit offsets
            auto_commit_interval_ms=1000   # Commit every second
        )
        self.message_count = 0
        self.start_time = None
        
    def consume_messages(self, topic, max_messages=None):
        """Consume messages from topic"""
        self.consumer.subscribe([topic])
        self.start_time = time.time()
        
        print(f"👂 Consumer listening to topic '{topic}'")
        print("Press Ctrl+C to stop...\n")
        
        try:
            for message in self.consumer:
                self.message_count += 1
                
                # Print message details
                print(f"📥 Received message #{self.message_count}:")
                print(f"   Partition: {message.partition}")
                print(f"   Offset: {message.offset}")
                print(f"   Key: {message.key}")
                print(f"   Value: {message.value}")
                print(f"   Latency: {self.calculate_latency(message.value)} ms")
                print("-" * 50)
                
                # Simulate processing time (remove for max speed)
                time.sleep(0.01)
                
                # Stop if we've reached max messages
                if max_messages and self.message_count >= max_messages:
                    print(f"🎯 Reached max messages limit: {max_messages}")
                    break
                    
        except KeyboardInterrupt:
            print("\n⏹️  Consumer stopped by user")
        finally:
            self.print_stats()
            
    def calculate_latency(self, message_data):
        """Calculate how long message took to arrive"""
        if 'timestamp' in message_data:
            produced_time = datetime.fromisoformat(message_data['timestamp'])
            current_time = datetime.now()
            latency = (current_time - produced_time).total_seconds() * 1000
            return round(latency, 2)
        return 0
    
    def print_stats(self):
        """Print consumption statistics"""
        if self.start_time:
            duration = time.time() - self.start_time
            print(f"\n📊 Consumer Results:")
            print(f"   📨 Messages received: {self.message_count}")
            print(f"   ⏱️  Duration: {duration:.2f} seconds")
            print(f"   📈 Rate: {self.message_count/duration:.2f} messages/second")
            
    def close(self):
        self.consumer.close()

if __name__ == "__main__":
    # Configuration
    BOOTSTRAP_SERVERS = ['localhost:19092', 'localhost:29092']
    TOPIC = "test-topic"
    CONSUMER_GROUP = "test-consumer-group"
    
    consumer = SimpleKafkaConsumer(BOOTSTRAP_SERVERS, CONSUMER_GROUP)
    
    try:
        # Consume until stopped
        consumer.consume_messages(TOPIC, max_messages=100)  # Remove max_messages for continuous
        
    except Exception as e:
        print(f"❌ Consumer error: {e}")
    finally:
        consumer.close()
