import serial
import paho.mqtt.client as mqtt

# HiveMQ public broker
broker = "broker.hivemq.com"  # HiveMQ broker URL
port = 1883  # Standard MQTT port (non-secure)
topic = "esp32/TYBCA A"  # MQTT topic to publish to

# Create MQTT client and connect to the broker
client = mqtt.Client()
client.connect(broker, port, 60)

# Open the serial port to read data from ESP32 (update this for your system)
ser = serial.Serial('COM14', 115200)  # Adjust COM3 if necessary

while True:
    if ser.in_waiting > 0:  # If data is available to read
        data = ser.readline().decode('utf-8').strip()  # Read and decode the data
        print(f"Publishing: {data}")
        client.publish(topic, data)  # Publish data to the MQTT broker
