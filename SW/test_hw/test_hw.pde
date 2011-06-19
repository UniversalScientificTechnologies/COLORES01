#include <OneWire.h>
#include <Stepper.h>
#include <Wire.h>

#define light0 0x44 // A0 = L (I2C light0)
#define light1 0x45 // A0 = H (I2C light0)

const int steps = 200; //3200;  // change this to fit the number of steps
const int sspeed = 100; // stepper motor speed

// initialize the stepper library on pins 
Stepper myStepper(steps, 9,10,11,12);           

// DS18S20 Temperature chip 
OneWire  ds(5);  // 1-Wire
byte addr[8];    // Addres

void setup() 
{
  pinMode(13, OUTPUT);  // LED
  digitalWrite(13, LOW); // LED ON

  // initialize the serial port:
  Serial.begin(9600);
  
  Wire.begin(); // join i2c bus (light0 optional for master)
}


byte sense=0;

void loop() 
{
  byte i;
  byte present = 0;
  byte data[12];
  byte inByte;
  int dd=0;
    
  // if we get a valid byte
  if (Serial.available() > 0) 
  {
    // get incoming byte:
    inByte = Serial.read();
    Serial.print("Prijat znak: ");
    Serial.print( inByte, HEX);
    Serial.println();
  }
  
  //--------------------------------------------------------- Motor
  if(sense)
  {
    digitalWrite(13, LOW); // blik
    // step one revolution  in one direction:
    Serial.println("clockwise");
    myStepper.setSpeed(sspeed/2);
    myStepper.step(30);
    myStepper.setSpeed(sspeed);
    myStepper.step(steps-50);
    myStepper.setSpeed(sspeed/2);
    myStepper.step(20);
    delay(50);
    digitalWrite(9, LOW);
    digitalWrite(10, LOW);
    digitalWrite(11, LOW);
    digitalWrite(12, LOW);
    delay(500);
    sense=0;
  }
  else
  {      
    digitalWrite(13, HIGH);  // blik
     // step one revolution in the other direction:
    Serial.println("counterclockwise");
    myStepper.setSpeed(sspeed/2);
    myStepper.step(-30);
    myStepper.setSpeed(sspeed);
    myStepper.step(-(steps-50));
    myStepper.setSpeed(sspeed/2);
    myStepper.step(-20);
    delay(50);
    digitalWrite(9, LOW);
    digitalWrite(10, LOW);
    digitalWrite(11, LOW);
    digitalWrite(12, LOW);
    delay(500); 
    sense=1;
  }
  
  //--------------------------------------------------------- 1-Wire bus

  // search for DS
  if ( !ds.search(addr)) 
  {
    ds.reset_search();
    delay(250);
    return;
  }

  if ( OneWire::crc8( addr, 7) != addr[7]) 
  {
      Serial.print("CRC is not valid!\n");
      return;
  }
 
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion

  // Delay for measurement, maybe 750ms is enough, maybe not 
  digitalWrite(13, HIGH);   // set the LED on
  delay(500);
  digitalWrite(13, LOW);    // set the LED off
  delay(500);

  present = ds.reset();
  ds.select(addr);    
  ds.write(0xBE);         // Read Scratchpad

  Serial.print("P=");
  Serial.print(present,HEX);
  Serial.print(" ");
  for ( i = 0; i < 9; i++) // we need 9 bytes
  {           
    data[i] = ds.read();
    Serial.print(data[i], HEX);
    Serial.print(" ");
  }
  Serial.print(" CRC=");
  Serial.print( OneWire::crc8( data, 8), HEX);
  Serial.println();            

  Serial.print("Light0: COMMAND=");
  // Setup device
  Wire.beginTransmission(light0); 
  Wire.send(0x00);            // sends light0
  Wire.send(0b11000001);      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement
  digitalWrite(13, HIGH);   // set the LED on
  delay(55);
  digitalWrite(13, LOW);    // set the LED off
  delay(55);

  //  Connect to device and set register light0
  Wire.beginTransmission(light0); 
  Wire.send(0x00);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(light0);
  Wire.requestFrom(light0, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print(" LSB=");
  //  Connect to device and set register light0
  Wire.beginTransmission(light0); 
  Wire.send(0x01);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(light0);
  Wire.requestFrom(light0, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print(" MSB=");  
  //  Connect to device and set register light0
  Wire.beginTransmission(light0);
  Wire.send(0x02);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(light0);
  Wire.requestFrom(light0, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.println(dd, HEX);

  Serial.print("Light1: COMMAND=");
  // Setup device
  Wire.beginTransmission(light1); 
  Wire.send(0x00);            // sends light0
  Wire.send(0b11000001);      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement
  digitalWrite(13, HIGH);   // set the LED on
  delay(55);
  digitalWrite(13, LOW);    // set the LED off
  delay(55);

  //  Connect to device and set register light0
  Wire.beginTransmission(light1); 
  Wire.send(0x00);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(light1);
  Wire.requestFrom(light1, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print(" LSB=");
  //  Connect to device and set register light0
  Wire.beginTransmission(light1); 
  Wire.send(0x01);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(light1);
  Wire.requestFrom(light1, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print(" MSB=");  
  //  Connect to device and set register light0
  Wire.beginTransmission(light1);
  Wire.send(0x02);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(light1);
  Wire.requestFrom(light1, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.println(dd, HEX);

  Serial.print("X=");
  Serial.print(analogRead(A0)-512, DEC);
  Serial.print(" Y=");
  Serial.print(analogRead(A1)-512, DEC);
  Serial.print(" Z=");
  Serial.println(analogRead(A2)-512, DEC);
}



