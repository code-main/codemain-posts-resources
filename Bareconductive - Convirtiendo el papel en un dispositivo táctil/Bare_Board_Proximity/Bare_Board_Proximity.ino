#include <MPR121.h>
#include <Wire.h>

// Inicio del rango personalizado de lectura
#define LOW_DIFF 0

// Fin del rango personalizado de lectura
#define HIGH_DIFF 50

// Valor del filtro (de 0.0f a 1.0f)
// Valor más alto => más suave y lento detectando cambios de proximidad
#define filterWeight 0.2f

// Pin que usaremos para monitorizar los toques
#define SENSOR_PIN 0

// Dirección I2C por defecto en la placa Bare Touch Board
#define MPR121_I2C 0x5C

// Último valor filtrado
float filteredValue = 0;

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

  // Se disminuyen un par de valores base del sensor para evitar falsas detecciones
  MPR121.setRegister(MPR121_NHDF, 0x01);  // noise half delta (falling)
  MPR121.setRegister(MPR121_FDLF, 0x10);  // filter delay limit (falling)
}

void loop() {
  // Se actualizan los datos del sensor
  MPR121.updateAll();

  // Diferencia entre el valor inicial del sensor y el valor actual de lectura de proximidad
  int difference = MPR121.getBaselineData(SENSOR_PIN) - MPR121.getFilteredData(SENSOR_PIN);

  // Se restringe la lectura anterior a nuestros valores límite
  unsigned int value = constrain(difference, LOW_DIFF, HIGH_DIFF);

  // Implementación simple de un filtro IIR lowpass
  // Suaviza la velocidad de detección de proximidad
  filteredValue = (filterWeight * filteredValue) + ((1 - filterWeight) * (float) value);

  // Se mapea la lectura filtrada a un rango de 0 - 255
  // Resolución de 8 bits para poder usar el valor como intensidad del LED
  uint8_t mappedValue = (uint8_t) map(filteredValue, LOW_DIFF, HIGH_DIFF, 0, 255);

  // Se usa el valor filtrado y mapeado como intensidad del LED
  analogWrite(LED_BUILTIN, mappedValue);
}
