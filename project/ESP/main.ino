#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ESP8266WebServer.h>

// WiFi credentials
const char* ssid = "S22";
const char* password = "13811381";

// MQTT Broker IP address
const char* mqtt_server = "192.168.39.224";
// const int LED_BUILTIN = 2;

// DHT Sensor
#define DHTPIN 4  // GPIO pin where the data pin is connected
#define DHTTYPE DHT22

// WebServer on port 80
ESP8266WebServer server(80);

WiFiClient espClient;
PubSubClient client(espClient);

unsigned long previousMillis = 0;
long interval = 2000;  // default interval for reading temperature

// HTML code for the web UI
const char* htmlPage = R"rawliteral(
<!DOCTYPE HTML><html>
<head>
  <title>ESP8266 Temperature Control</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { text-align: center; font-family: "Trebuchet MS", Arial; color: orange;}
    .slider { width: 100%; }
  </style>
</head>
<body>
  <h1>Analog Read 0</h1>
  <p>Set the interval:</p>
  <input type="range" min="1" max="60" value="2" class="slider" id="intervalRange">
  <p>Value: <span id="intervalValue">2</span> seconds</p>
  <script>
    var slider = document.getElementById("intervalRange");
    var output = document.getElementById("intervalValue");
    slider.oninput = function() {
      output.innerHTML = this.value;
      var xhr = new XMLHttpRequest();
      xhr.open("GET", "/setInterval?interval=" + this.value, true);
      xhr.send();
    }
  </script>
</body>
</html>
)rawliteral";

void handleRoot() {
  server.send(200, "text/html", htmlPage);
}

void handleSetInterval() {
  String intervalStr = server.arg("interval");
  interval = intervalStr.toInt() * 1000;
  server.send(200, "text/plain", "Interval set to " + intervalStr + " seconds");
}

void setup_wifi() {
  delay(10);
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  setup_wifi();
  client.setServer(mqtt_server, 1883);

  server.on("/", handleRoot);
  server.on("/setInterval", handleSetInterval);

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  server.handleClient();

  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    float t = -5;
    t =  analogRead(A0);
    if (isnan(t)) {
      Serial.println("Failed to read from DHT sensor!");
      return;
    }

    char tempStr[8];
    dtostrf(t, 1, 2, tempStr);
    Serial.print("Publishing temperature: ");
    Serial.println(tempStr);
    client.publish("micro/temp", tempStr);
  }
}