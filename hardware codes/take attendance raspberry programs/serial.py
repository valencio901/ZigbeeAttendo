import paho.mqtt.client as mqtt

# MQTT Broker details
BROKER = "public.cloud.shiftr.io"  # Your MQTT broker
PORT = 1883  # Default MQTT port
USERNAME = "public"  # MQTT username
PASSWORD = "public"  # MQTT password
TOPIC = "/zigbee/logs"  # The topic to subscribe to

# Callback when connected to broker
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Connected to MQTT Broker!")
        client.subscribe(TOPIC)  # Subscribe to the topic
    else:
        print(f"❌ Failed to connect. Error code: {rc}")

# Callback when message is received
def on_message(client, userdata, msg):
    print(f"📩 Message received: {msg.topic} -> {msg.payload.decode()}")

# Create MQTT client
client = mqtt.Client()

# Set credentials
client.username_pw_set(USERNAME, PASSWORD)

# Set callback functions
client.on_connect = on_connect
client.on_message = on_message

# Connect to broker
client.connect(BROKER, PORT, 60)

# Keep listening for messages
print(f"📡 Listening for messages on topic: {TOPIC}")
client.loop_forever()
