#include <MPR121.h>
#include <Wire.h>

// Pin que usaremos para monitorizar los toques
#define SENSOR_PIN 0

// Dirección I2C por defecto en la placa Bare Touch Board
#define MPR121_I2C 0x5C

void setup() {
  // Se inicializa el Serial
  Serial.begin(115200);

  // Se establece el LED incorporado como de salida
  pinMode(LED_BUILTIN, OUTPUT);

  // Se deja apagado el LED al iniciar
  digitalWrite(LED_BUILTIN, LOW);

  // Se inicializa el sensor, y en caso de que falle se gestiona el error
  if (!MPR121.begin(MPR121_I2C)) {
    Serial.println("Error iniciando el sensor MPR121");

    // Se recupera y muestra el error generado
    switch (MPR121.getError()) {
      case NO_ERROR:
        Serial.println("Sin error");
        break;
      case ADDRESS_UNKNOWN:
        Serial.println("Dirección incorrecta");
        break;
      case READBACK_FAIL:
        Serial.println("Error de lectura");
        break;
      case OVERCURRENT_FLAG:
        Serial.println("Sobrecorriente en el pin REXT");
        break;
      case OUT_OF_RANGE:
        Serial.println("Pin fuera de rango");
        break;
      case NOT_INITED:
        Serial.println("No inicializado");
        break;
      default:
        Serial.println("Error desconocido");
        break;
    }
    while(1);
  }

  // Umbral de sensibilidad al pulsar
  // Cuanto más pequeño sea el valor más sensible será el sensor
  MPR121.setTouchThreshold(100);

  // Umbral de sensibilidad al soltar
  // Cuanto más pequeño sea el valor más sensible será el sensor
  // Este valor SIEMPRE deberá ser menor al umbral de pulsación
  MPR121.setReleaseThreshold(90);

  // Se actualizan los datos del sensor al iniciar
  MPR121.updateTouchData();
}

void loop() {
  // Se detecta si ha cambiado el estado de algún pin
  if (MPR121.touchStatusChanged()) {
    // Se actualizan los datos del sensor
    MPR121.updateTouchData();

    // Se comprueba si es un nuevo toque en nuestro pin
    if (MPR121.isNewTouch(SENSOR_PIN)) {
      digitalWrite(LED_BUILTIN, HIGH);  // Se enciende el LED
      Serial.print("Se ha tocado el pin ");
      Serial.println(SENSOR_PIN);
    }
    // Se comprueba si se ha dejado de pulsar sobre nuestro pin
    else if (MPR121.isNewRelease(SENSOR_PIN)) {
      digitalWrite(LED_BUILTIN, LOW);  // Se apaga el LED
      Serial.print("Se ha soltado el pin ");
      Serial.println(SENSOR_PIN);
    }
  }
}
