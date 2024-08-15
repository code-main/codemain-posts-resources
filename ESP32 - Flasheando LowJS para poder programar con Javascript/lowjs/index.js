// Módulo para controlar los pines
const gpio = require('gpio');
// Pin del LED
const PIN = 4;

// Estado del LED
let state = 0;

// Se establece el pin del LED en modo Salida
gpio.pins[PIN].setType(gpio.OUTPUT);
// Se apaga el LED al iniciar
gpio.pins[PIN].setValue(state);

// Cada 500ms se encenderá/apagará el LED
setInterval(() => {
	// Si el LED estaba encendido (state === 1)
	if (state) {
		// Se establece el estado a 0
		state = 0;
		// Se setea el nuevo estado en el LED
		gpio.pins[PIN].setValue(state);
	}
	// Si el LED estaba apagado (state === 0)
	else {
		// Se establece el estado a 1
		state = 1;
		// Se setea el nuevo estado en el LED
		gpio.pins[PIN].setValue(state);
	}
}, 500);