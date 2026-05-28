String inputString = "";
unsigned long val1, val2;
int val3, val4, val5;

void setup() {
  Serial.begin(115200);      // For Serial Monitor
  Serial1.begin(115200);    // For communication with Mega
  Serial.println("Ready to receive...");
}

void loop() {
  if (Serial1.available()) {
    char c = Serial1.read();
    if (c == '\n') {
      // Full line received → parse it
      parseData(inputString);
      inputString = "";
    } else {
      inputString += c;
    }
  }
}

void parseData(String data) {
  int comma1 = data.indexOf(',');
  int comma2 = data.indexOf(',', comma1 + 1);
  int comma3 = data.indexOf(',', comma2 + 1);
  int comma4 = data.indexOf(',', comma3 + 1);

  if (comma1 > 0 && comma2 > 0 && comma3 > 0) {
    val1 = data.substring(0, comma1).toInt();
    val2 = data.substring(comma1 + 1, comma2).toInt();
    val3 = data.substring(comma2 + 1, comma3).toInt();
    val4 = data.substring(comma3 + 1, comma4).toInt();
    val5 = data.substring(comma4 + 1).toInt();

    Serial.print(val1);
    Serial.print(",");
    Serial.print(val2);
    Serial.print(",");
    Serial.print(val3);
    Serial.print(",");
    Serial.print(val4);
    Serial.print(",");
    Serial.println(val5);
  }
}
