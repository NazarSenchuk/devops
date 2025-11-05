#!/usr/bin/env python3
"""
Fixed Kafka Load Test with Confluent Kafka
"""
from confluent_kafka import Producer, Consumer, KafkaError
import json
import time
import threading
import random
from datetime import datetime

class FixedKafkaLoadTest:
    def __init__(self, bootstrap_servers):
        self.bootstrap_servers = bootstrap_servers
        self.results = {
            'producer': {'sent': 0, 'failed': 0},
            'consumer': {'received': 0}
        }
        self.running = True
        
    def producer_worker(self, topic, num_messages, worker_id):
        """Worker thread for producing messages"""
        producer_config = {
            'bootstrap.servers': self.bootstrap_servers,
            'message.max.bytes': 1000000,  # 1MB max message size
            'socket.timeout.ms': 30000,
            'message.timeout.ms': 30000,
            'retries': 3,
            'batch.size': 16384,  # 16KB batches
            'linger.ms': 10       # Wait up to 10ms to batch
        }
        
        producer = Producer(producer_config)
        
        def delivery_callback(err, msg):
            if err:
                print(f"❌ Producer {worker_id} failed: {err}")
                self.results['producer']['failed'] += 1
            else:
                self.results['producer']['sent'] += 1
        
        try:
            for i in range(num_messages):
                # Create small, simple message
                message = {
                    "worker_id": worker_id,
                    "message_id": i,
                    "timestamp": datetime.now().isoformat(),
                    "random_value": random.randint(1, 1000),
                    "small_payload": "x" * 100  # Fixed small size
                }
                
                # Use different keys for partition distribution
                key = f"key_{worker_id}_{i % 100}"  # Cycle through 100 keys
                
                # Produce message
                producer.produce(
                    topic=topic,
                    key=key,
                    value=json.dumps(message),
                    callback=delivery_callback
                )
                
                # Poll to trigger callbacks
                if i % 100 == 0:
                    producer.poll(0)
                    
                # Small delay to prevent overwhelming
                if i % 1000 == 0:
                    time.sleep(0.01)
                    
        except Exception as e:
            print(f"❌ Producer {worker_id} exception: {e}")
        finally:
            # Wait for all messages to be delivered
            producer.flush(30)  # Wait up to 30 seconds
            print(f"✅ Producer {worker_id} finished")
        
    def consumer_worker(self, topic, group_id, duration_seconds):
        """Worker thread for consuming messages"""
        consumer_config = {
            'bootstrap.servers': self.bootstrap_servers,
            'group.id': group_id,
            'auto.offset.reset': 'earliest',
            'enable.auto.commit': True,
            'auto.commit.interval.ms': 1000,
            'fetch.message.max.bytes': 1000000,
            'max.partition.fetch.bytes': 1000000
        }
        
        consumer = Consumer(consumer_config)
        consumer.subscribe([topic])
        
        start_time = time.time()
        
        try:
            while time.time() - start_time < duration_seconds and self.running:
                msg = consumer.poll(1.0)  # 1 second timeout
                
                if msg is None:
                    continue
                if msg.error():
                    if msg.error().code() != KafkaError._PARTITION_EOF:
                        print(f"❌ Consumer error: {msg.error()}")
                    continue
                
                self.results['consumer']['received'] += 1
                
                # Print progress every 100 messages
                if self.results['consumer']['received'] % 100 == 0:
                    print(f"📥 Consumer received: {self.results['consumer']['received']} messages")
                    
        except Exception as e:
            print(f"❌ Consumer exception: {e}")
        finally:
            consumer.close()
            print("✅ Consumer finished")

def run_safe_load_test():
    """Run safe load test with smaller scale"""
    BOOTSTRAP_SERVERS = "broker-1:9092,broker-2:9092"
    TOPIC = "load-test-config"
    
    print("🚀 Starting SAFE Kafka Load Test")
    print("=" * 50)
    
    test = FixedKafkaLoadTest(BOOTSTRAP_SERVERS)
    
    # SAFER test configuration
    NUM_PRODUCERS = 2           # Reduced from 3
    MESSAGES_PER_PRODUCER = 500 # Reduced from 1000
    CONSUME_DURATION = 20       # seconds
    
    # Create topic first (run this manually)
    print("📝 Please create topic manually first:")
    print(f"docker exec broker-1 kafka-topics.sh --create --topic {TOPIC} --partitions 3 --replication-factor 2 --bootstrap-server broker-1:9092")
    
    print("📨 Starting producers...")
    producer_threads = []
    
    # Start producers
    for i in range(NUM_PRODUCERS):
        thread = threading.Thread(
            target=test.producer_worker,
            args=(TOPIC, MESSAGES_PER_PRODUCER, i),
            daemon=True
        )
        producer_threads.append(thread)
        thread.start()
    
    # Wait for producers to finish
    for thread in producer_threads:
        thread.join(timeout=60)  # 60 second timeout
    
    print("👂 Starting consumer...")
    
    # Start consumer
    consumer_thread = threading.Thread(
        target=test.consumer_worker,
        args=(TOPIC, "load-test-group", CONSUME_DURATION),
        daemon=True
    )
    consumer_thread.start()
    
    # Wait for consumer
    consumer_thread.join(timeout=CONSUME_DURATION + 5)
    
    # Stop consumer
    test.running = False
    
    # Print results
    print("\n" + "=" * 50)
    print("📊 LOAD TEST RESULTS")
    print("=" * 50)
    print(f"📨 PRODUCER:")
    print(f"   Messages sent: {test.results['producer']['sent']}")
    print(f"   Messages failed: {test.results['producer']['failed']}")
    
    print(f"\n👂 CONSUMER:")
    print(f"   Messages received: {test.results['consumer']['received']}")
    
    total_produced = test.results['producer']['sent'] + test.results['producer']['failed']
    delivery_rate = (test.results['consumer']['received'] / total_produced * 100) if total_produced > 0 else 0
    print(f"\n📈 Delivery rate: {delivery_rate:.1f}%")

if __name__ == "__main__":
    run_safe_load_test()
