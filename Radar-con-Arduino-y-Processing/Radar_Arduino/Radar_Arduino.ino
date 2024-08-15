#include <Servo.h>
#include <NewPing.h>

#define TRIGGER_PIN  8  // Arduino pin tied to trigger pin on the ultrasonic sensor.
#define ECHO_PIN     9  // Arduino pin tied to echo pin on the ultrasonic sensor.
#define MAX_DISTANCE 200 // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE); // NewPing setup of pins and maximum distance.
Servo radar;

void setup() {
  Serial.begin(9600);
  radar.attach(2);
  radar.write(0);
  delay(2000);
}

void loop() {
  for (int i = 0; i <= 180; i++) {
    radar.write(i);
    int ms = sonar.ping_median(2); // Obtenemos la media de microsegundos de 2 pulsos
    int distancia = sonar.convert_cm(ms); // Convertimos la media de microsegundos en distancia en cm
    delay(10);
    Serial.print(i);
    Serial.print(",");
    Serial.print(distancia);
    Serial.println(".");
    //delay(50);
  }
  delay(50);
  
  for (int i = 179; i >= 0; i--) {
    radar.write(i);
    int ms = sonar.ping_median(2); // Obtenemos la media de microsegundos de 2 pulsos
    int distancia = sonar.convert_cm(ms); // Convertimos la media de microsegundos en distancia en cm
    delay(10);
    Serial.print(i);
    Serial.print(",");
    Serial.print(distancia);
    Serial.println(".");
    //delay(50);
  }
  delay(50);
}
