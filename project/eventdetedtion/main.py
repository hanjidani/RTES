import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
import csv
from scipy.io import wavfile
import pyaudio
import soundfile as sf
CHUNK = 1024
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 16000
RECORD_SECONDS = 10
import time
import psutil
import requests
import paho.mqtt.client as mqtt
# mqtt publish

broker_address = "localhost"  # or the IP address of your broker
broker_port = 1883

# Define the topic you want to publish to
topic = "SED/label"
client = mqtt.Client()
client.connect(broker_address, broker_port, 60)
def add_event(filename, time, event_name, file_path):
    url = 'http://localhost:8080/add'  # Replace with your server address
    params = {
    'filename': filename,
    'time': time,
    'event_name': event_name
    }
    # Read wave data from a file
    with open(file_path, 'rb') as f:
        wave_data = f.read()

    # Make a GET request to the /add endpoint
    try:
        response = requests.get(url, params=params, data=wave_data)
        if response.status_code == 200:
            print("File added successfully")
        else:
            print("Failed to add file. Status code:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("Error:", e)
def add_status():
    url = 'http://localhost:8080/status'  # Replace with your server address
    params = {
    'cpu_usage': str(psutil.cpu_percent(interval=1)),
    'ram_usage': str(psutil.virtual_memory().used),
    'time': str(int(time.time()))
    }

    # Make a GET request to the /add endpoint
    try:
        response = requests.get(url, params=params)
        if response.status_code == 200:
            print("Status added successfully")
        else:
            print("Failed to add file. Status code:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("Error:", e)
    
  # Find the name of the class with the top score when mean-aggregated across frames.
def class_names_from_csv(class_map_csv_text):
  """Returns list of class names corresponding to score vector."""
  class_names = []
  with tf.io.gfile.GFile(class_map_csv_text) as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
      class_names.append(row['display_name'])

  return class_names
def ensure_sample_rate(original_sample_rate, waveform,
                       desired_sample_rate=16000):
  """Resample waveform if required."""
  if original_sample_rate != desired_sample_rate:
    desired_length = int(round(float(len(waveform)) /
                               original_sample_rate * desired_sample_rate))
    waveform = scipy.signal.resample(waveform, desired_length)
  return desired_sample_rate, waveform
# Load the model.
model = hub.load('https://tfhub.dev/google/yamnet/1')
class_map_path = model.class_map_path().numpy()
class_names = class_names_from_csv(class_map_path)

# wav_file_name = 'speech_whistling2.wav'
# # wav_file_name = 'miaow_16k.wav'
# sample_rate, wav_data = wavfile.read(wav_file_name, 'rb')
# sample_rate, wav_data = ensure_sample_rate(sample_rate, wav_data)

# # Show some basic information about the audio.
# duration = len(wav_data)/sample_rate
# print(f'Sample rate: {sample_rate} Hz')
# print(f'Total duration: {duration:.2f}s')
# print(f'Size of the input: {len(wav_data)}')

# Record sound
p = pyaudio.PyAudio()
stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                frames_per_buffer=CHUNK)
frames = []
for i in range(3):
  data = stream.read(CHUNK)
  frames.append(data)
# print(frames)
while True:
    try:
        data = stream.read(CHUNK)
        # print("start")
        frames.append(data)
        # print()
        bb = b''.join(frames[-3:])
        waveform = np.frombuffer(bb, dtype=np.int16)
        waveform = np.array(waveform, dtype=np.float32)
        waveform = waveform / tf.int16.max
        tim = time.time()
        scores, embeddings, spectrogram = model(waveform)
        scores_np = scores.numpy()
        spectrogram_np = spectrogram.numpy()
        max_score = scores_np.mean(axis=0).max()
        # print(np.shape(scores_np))
        infered_class = class_names[scores_np.argmax()]
        print(infered_class, max_score)
        # and infered_class != "Speech" and infered_class != "Silence"
        if max_score > 0.5 and infered_class != "Silence":
            frames_to_save = frames[-int(RATE / CHUNK * RECORD_SECONDS):]
            audio_data = np.frombuffer(b''.join(frames_to_save), dtype=np.int16)
            fname = str(tim) +".wav"
            sf.write("out/"+fname, audio_data, RATE)
            add_event(fname, str(int(tim)), infered_class, "out/"+fname)
            add_status()
            client.publish(topic, infered_class)
            print(infered_class)
    except Exception as e:
        print(e)
        stream.stop_stream()
        stream.close()
        p.terminate()
        time.sleep(2)
        p = pyaudio.PyAudio()
        stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                frames_per_buffer=CHUNK)
        continue
client.disconnect()