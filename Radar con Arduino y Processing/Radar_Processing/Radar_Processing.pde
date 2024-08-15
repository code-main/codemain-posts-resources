import processing.serial.*;

Serial myPort;

String angle=""; // Variable que almacenara el angulo en el que se encuentra el servo en String
String distance=""; // Variable usada para almacenar la distancia en cm del objeto al sensor en String
String data=""; // Variable que almacena el mensaje enviado desde el Arduino a traves del Serial
String noObject; // Texto que mostrara si el/los objeto/s detectado/s estan en rango o no
float pixsDistance; // Variable que almacenara la distancia convertida de cm a px
int iAngle, iDistance; // Variables que almacenaran las variables 'angle' y 'distance' convertidas de String a int
int index1; // Variable que almacenara el index del splitter (separador) del mensaje enviado desde Arduino (',')
int rc = 10; // Codigo ASCII del retorno de carro, sera usado para guardar el mensaje de Arduino hasta el salto de linea


void setup() {
  // Aqui se especifican las dimensiones de la ventana
  // podeis cambiarlo, ya que el codigo esta optimizado para ajustar las medidas de los elementos automaticamente
  size(1920, 1080);
  //println(Serial.list()); // Lista todos los puertos series
  myPort = new Serial(this, Serial.list()[1], 9600); // Establece un puerto serie
  myPort.bufferUntil(rc); // Almacena en el bufer hasta llegar un retorno de carro
}

void draw() {
  // Simula desenfoque de movimiento (motion blur) y decoloracion lenta (slow fade) de la linea de movimiento verde
  noStroke();
  fill(0, 2.5); 
  rect(0, 0, width, height-height*0.05);
  drawRadar(); // Dibuja las lineas del radar
  drawLine();  // Dibuja las lineas verdes del radar
  drawObject(); // Dibuja las lineas rojas del radar en base a si se ha detectado un objeto y su distancia de nosotros
  drawText(); // Dibuja el texto del radar
  
  println(iAngle + " " + iDistance);  // Imprime por consola el angulo y distancia del objeto con formato 'Angulo Distancia'
}

// Obtenemos los valores del puerto Serial
void serialEvent (Serial myPort) {
  data = myPort.readStringUntil(rc); // Leemos el mensaje enviado desde Arduino con formato 'Angulo,Distancia.'
  data = data.substring(0,data.length()-1); // Eliminamos el '.' del mensaje
  
  index1 = data.indexOf(','); // Almacenamos la posicion del splitter (',')
  angle= data.substring(0, index1); // Almacenamos los caracteres desde la posicion 0 hasta el splitter (sin incluir)
  distance= data.substring(index1+1, data.length()); // Almacenamos los caracteres desde la posicion del splitter+1 hasta el final
  
  // Convertimos los Strings obtenidos en Integers
  iAngle = int(angle);
  iDistance = int(distance);
}

void drawRadar() {
  pushMatrix();
  translate(width/2,height-height*0.074); // Movemos la matriz al punto desde el que se dibujaran las lineas y arcos del radar
  noFill();
  strokeWeight(0.1);
  stroke(98,245,31); // Color verde
  // Dibujamos los arcos del radar
  arc(0,0,(width-width*0.0625),(width-width*0.0625),PI,TWO_PI);
  arc(0,0,(width-width*0.27),(width-width*0.27),PI,TWO_PI);
  arc(0,0,(width-width*0.479),(width-width*0.479),PI,TWO_PI);
  arc(0,0,(width-width*0.687),(width-width*0.687),PI,TWO_PI);
  // Dibujamos las lineas de los angulos
  line(-width/2,0,width/2,0);
  line(0,0,(-width/2)*cos(radians(30)),(-width/2)*sin(radians(30)));
  line(0,0,(-width/2)*cos(radians(60)),(-width/2)*sin(radians(60)));
  line(0,0,(-width/2)*cos(radians(90)),(-width/2)*sin(radians(90)));
  line(0,0,(-width/2)*cos(radians(120)),(-width/2)*sin(radians(120)));
  line(0,0,(-width/2)*cos(radians(150)),(-width/2)*sin(radians(150)));
  line((-width/2)*cos(radians(30)),0,width/2,0);
  popMatrix();
}
void drawObject() {
  pushMatrix();
  translate(width/2,height-height*0.074); // Movemos la matriz al punto desde el que se dibujaran las lineas rojas del radar del objeto detectado (si se ha detectado)
  strokeWeight(12.5);
  stroke(255,10,10); // Color rojo
  pixsDistance = iDistance*((height-height*0.1666)*0.025); // Convertimos la distancia del sensor de cm a px
  // Limitamos el rango de deteccion del sensor a 40cm
  if(iDistance<=40){
    // Dibujamos el objeto en base al angulo y la distancia
    line(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)),(width-width*0.505)*cos(radians(iAngle)),-(width-width*0.505)*sin(radians(iAngle)));
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(11);
  stroke(88, 255, 109); // Color verde
  translate(width/2,height-height*0.074); // Movemos la matriz al punto desde el que se dibujaran las lineas verdes del radar
  line(0,0,(height-height*0.12)*cos(radians(iAngle)),-(height-height*0.12)*sin(radians(iAngle))); // Dibujamos la linea verde en base al angulo
  popMatrix();
}

void drawText() {
  pushMatrix();
  if(iDistance>40) {
    // Si la distancia excede de 40cm cambiamos el valor del String noObject a 'Fuera de Rango'
    noObject = "Fuera de Rango";
  }
  else {
    // Sino significa que el objeto esta en rango por lo que el String contendra 'En Rango'
    noObject = "En Rango";
  }
  fill(0);
  noStroke();
  rect(0, height-height*0.072, width, height);
  fill(98,245,31);
  
  /*********************     Dibujamos todo el texto que aparece en la ventana     *********************/
  
  text("10cm",width-width*0.3854,height-height*0.0833);
  text("20cm",width-width*0.281,height-height*0.0833);
  text("30cm",width-width*0.177,height-height*0.0833);
  text("40cm",width-width*0.0729,height-height*0.0833);
  // Tamaño del texto para el pie de programa (objeto, angulo, distancia)
  textSize(15);
  text("Objeto: " + noObject, width-width*0.975, height-height*0.0277);
  text("Ángulo: " + iAngle +"°", width-width*0.525, height-height*0.0277);
  text("Distancia: ", width-width*0.1, height-height*0.0277);
  if(iDistance<200) {
    text(iDistance +" cm", width-width*0.04, height-height*0.0277);
  }
  // Tamaño del texto para los numeros del radar
  //textSize(15);
  fill(98,245,60);
  translate((width-width*0.4994)+width/2*cos(radians(30)),(height-height*0.0907)-width/2*sin(radians(30)));
  rotate(-radians(-60));
  text("30°",0,0);
  resetMatrix();
  translate((width-width*0.503)+width/2*cos(radians(60)),(height-height*0.0888)-width/2*sin(radians(60)));
  rotate(-radians(-30));
  text("60°",0,0);
  resetMatrix();
  translate((width-width*0.507)+width/2*cos(radians(90)),(height-height*0.0833)-width/2*sin(radians(90)));
  rotate(radians(0));
  text("90°",0,0);
  resetMatrix();
  translate(width-width*0.513+width/2*cos(radians(120)),(height-height*0.07129)-width/2*sin(radians(120)));
  rotate(radians(-30));
  text("120°",0,0);
  resetMatrix();
  translate((width-width*0.5104)+width/2*cos(radians(150)),(height-height*0.0574)-width/2*sin(radians(150)));
  rotate(radians(-60));
  text("150°",0,0);
  
  popMatrix(); 
}