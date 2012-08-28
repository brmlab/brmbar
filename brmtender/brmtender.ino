/*
  BrmTender
  System for dispensing and mixing (non-)alcoholic beverages
 */

void setup() {                
  Serial.begin(9600);
  pinMode(3, OUTPUT);     
  pinMode(12, OUTPUT);     
  digitalWrite(3, HIGH);
}

void loop() {
  while(Serial.available() == 0) Serial.read();
  digitalWrite(12, HIGH);   // set the LED on
  delay(3000);              // w
  ait for a second
  digitalWrite(12, LOW);    // set the LED off
  while(Serial.available() > 0) Serial.read();
}
