#define TRIG_PIN1 10
#define ECHO_PIN1 13
#define TRIG_PIN2 3
#define ECHO_PIN2 2

void setup() {
  Serial.begin(9600);
  pinMode(TRIG_PIN1, OUTPUT);
  pinMode(ECHO_PIN1, INPUT);
  pinMode(TRIG_PIN2, OUTPUT);
  pinMode(ECHO_PIN2, INPUT);
}

void loop() {
  // Send a short pulse to trigger
  digitalWrite(TRIG_PIN1, LOW);
  digitalWrite(TRIG_PIN2, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN1, HIGH);
  digitalWrite(TRIG_PIN2, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN1, LOW);
  digitalWrite(TRIG_PIN2, LOW);

  // Read the echo time
  long duration1 = pulseIn(ECHO_PIN1, HIGH);
  long duration2 = pulseIn(ECHO_PIN2, HIGH);

  // Calculate distance in cm
  float distance1 = duration1 * 0.034 / 2;
  float distance2 = duration2 * 0.034 / 2;

  Serial.print("DistanceB: ");
  Serial.println(distance1);

  Serial.print("DistanceG: ");
  Serial.println(distance2);

  delay(500);
}


