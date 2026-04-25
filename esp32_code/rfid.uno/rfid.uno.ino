#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include <HTTPClient.h>

// WiFi credentials
const char* ssid     = "Nikhil";
const char* password = "12345678";

// Server endpoint (Servlet mapping: /rfid)
String serverUrl = "http://10.224.14.125:8080/RfidwebApp1/rfid";

// API key must match server filter SECRET
const char* apiKey = "RFID_SECRET_123";

// MFRC522 pins (SPI on VSPI: SCK=18, MISO=19, MOSI=23)
#define SS_PIN  5
#define RST_PIN 22  
MFRC522 mfrc522(SS_PIN, RST_PIN);

void sendToServer(const String& uid) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected");
    return;
  }

  WiFiClient client;
  HTTPClient http;
  if (!http.begin(client, serverUrl)) {
    Serial.println("HTTP begin failed");
    return;
  }

  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  http.addHeader("X-API-Key", apiKey);

  String postData = "uid=" + uid;
  int code = http.POST(postData);
  String resp = http.getString();

  Serial.println("HTTP code: " + String(code));
  Serial.println("Resp: " + resp);

  http.end();
}

void setup() {
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();

  Serial.println("Place your RFID card near the reader...");

  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
}

void loop() {
  if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) return;

  String uidStr;
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) uidStr += "0";
    uidStr += String(mfrc522.uid.uidByte[i], HEX);
  }
  uidStr.toUpperCase();
  Serial.print("Scanned UID: "); Serial.println(uidStr);

  sendToServer(uidStr);

  mfrc522.PICC_HaltA();
  mfrc522.PCD_StopCrypto1();

  delay(1000);
}
