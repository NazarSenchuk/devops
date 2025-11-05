#!/usr/bin/env python3
"""
Simple Kafka Producer for load testing
"""
from kafka import KafkaProducer
import json
import time
import random
from datetime import datetime

class SimpleKafkaProducer:
    def __init__(self, bootstrap_servers):
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            key_serializer=lambda v: str(v).encode('utf-8') if v else None,
            batch_size=16384,  # 16KB batches
            linger_ms=10,      # Wait up to 10ms to batch messages
            acks='all'         # Wait for all replicas to acknowledge
        )
        
    def send_messages(self, topic, num_messages=1000, delay_ms=0):
        """Send multiple messages with optional delay"""
        print(f"🚀 Sending {num_messages} messages to topic '{topic}'")
        
        start_time = time.time()
        successful = 0
        failed = 0
        
        for i in range(num_messages):
            try:
                # Create sample message with different keys for distribution
                user_id = f"user_{random.randint(1, 1000)}"
                message = {
                    "message_id": i,
                    "user_id": user_id,
                    "timestamp": datetime.now().isoformat(),
                    "data": f"Sample message content {i}",
                    "random_value": random.randint(1, 1000)
                }
                
                # Send with key for partitioning
                future = self.producer.send(
                    topic=topic,
                    key=user_id,  # Same key = same partition
                    value=message
                )
                
                # Optional: Wait for confirmation (slower but more reliable)
                # future.get(timeout=10)
                
                successful += 1
                
                if i % 100 == 0:
                    print(f"📨 Sent {i} messages...")
                
                if delay_ms > 0:
                    time.sleep(delay_ms / 1000)
                    
            except Exception as e:
                print(f"❌ Failed to send message {i}: {e}")
                failed += 1
        
        # Wait for any outstanding messages to be delivered
        self.producer.flush()
        
        end_time = time.time()
        duration = end_time - start_time
        
        print(f"\n📊 Producer Results:")
        print(f"   ✅ Successful: {successful}")
        print(f"   ❌ Failed: {failed}")
        print(f"   ⏱️  Duration: {duration:.2f} seconds")
        print(f"   📈 Rate: {successful/duration:.2f} messages/second")
        
    def close(self):
        self.producer.close()

if __name__ == "__main__":
    # Configuration
    BOOTSTRAP_SERVERS = ['localhost:19092', 'localhost:29092']
    TOPIC = "test-topic"
    
    producer = SimpleKafkaProducer(BOOTSTRAP_SERVERS)
    
    try:
        # Test scenarios - uncomment the one you want:
        
        # 1. Quick burst (100 messages)
        producer.send_messages(TOPIC, num_messages=100, delay_ms=0)
        
        # 2. Load test (10,000 messages)
        # producer.send_messages(TOPIC, num_messages=10000, delay_ms=0)
        
        # 3. Steady stream (1 message per second)
        # producer.send_messages(TOPIC, num_messages=60, delay_ms=1000)
        
    except KeyboardInterrupt:
        print("\n⏹️  Producer stopped by user")
    finally:
        producer.close()
