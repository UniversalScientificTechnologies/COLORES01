#include <OneWire.h>
#include <Stepper.h>
#include <Wire.h>

#define light0 0x44 // A0 = L (I2C light0)
#define light1 0x45 // A0 = H (I2C light0)

#define LAMP1 13  // Callibration Lamp 1
#define LAMP2  6  // Callibration Lamp 2
#define FW1    7  // FilterWheel 1
#define FW2    8  // FilterWheel 1
#define FW3    3  // FilterWheel 1

const int steps = 200; //3200;  // change this to fit the number of steps
const int sspeed = 100; // stepper motor speed

// initialize the stepper library on pins 
#define M1  9
#define M2  10
#define M3  11
#define M4  12
Stepper myStepper(steps, M1,M2,M3,M4);           

// DS18S20 Temperature chip 
OneWire  ds(5);  // 1-Wire
byte addr[8];    // Addres
boolean sense;

void setup() 
{
  sense=true;
  
  pinMode(LAMP1, OUTPUT); 
  pinMode(LAMP2, OUTPUT); 
  pinMode(FW1, OUTPUT); 
  pinMode(FW2, OUTPUT); 
  pinMode(FW3, OUTPUT); 

  // initialize the serial port:
  Serial.begin(9600);
  
  Wire.begin(); // join i2c bus (light0 optional for master)
}


void loop() 
{
  byte i,n;
  byte present = 0;
  byte data[12];
  byte inByte;
  int dd=0;
    
  digitalWrite(LAMP1, HIGH); // All outputs OFF
  digitalWrite(LAMP2, HIGH); 
  digitalWrite(FW1, HIGH); 
  digitalWrite(FW2, HIGH); 
  digitalWrite(FW3, HIGH); 
  delay(300);
  digitalWrite(LAMP1, LOW); // blik

  //--------------------------------------------------------- Serial Input
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
  if (sense)
  {
    // step one revolution  in one direction:
    Serial.println("clockwise");
    myStepper.setSpeed(sspeed/2);
    myStepper.step(30);
    myStepper.setSpeed(sspeed);
    myStepper.step(steps-50);
    myStepper.setSpeed(sspeed/2);
    myStepper.step(20);
    delay(50);
    digitalWrite(M1, LOW);
    digitalWrite(M2, LOW);
    digitalWrite(M3, LOW);
    digitalWrite(M4, LOW);
  }
  else
  {      
     // step one revolution in the other direction:
    Serial.println("counterclockwise");
    myStepper.setSpeed(sspeed/2);
    myStepper.step(-30);
    myStepper.setSpeed(sspeed);
    myStepper.step(-(steps-50));
    myStepper.setSpeed(sspeed/2);
    myStepper.step(-20);
    delay(50);
    digitalWrite(M1, LOW);
    digitalWrite(M2, LOW);
    digitalWrite(M3, LOW);
    digitalWrite(M4, LOW);
  }
  sense=!sense;
  digitalWrite(LAMP2, LOW); // blik

  //--------------------------------------------------------- 1-Wire bus 
  ds.reset_search();
  for(n=0;n<2;n++)
  {
      if ( !ds.search(addr)) 
      {
        continue;
      }

      Serial.print("R=");
      for( i = 0; i < 8; i++) 
      {
        Serial.print(addr[i], HEX);
        Serial.print(" ");
      }
    
      if ( OneWire::crc8( addr, 7) != addr[7]) 
      {
          Serial.print("CRC is not valid!\n");
      }
      
      ds.reset();
      ds.select(addr);
      ds.write(0x44,1);         // start conversion, with parasite power on at the end
      
      delay(800);     // maybe 750ms is enough, maybe not
      digitalWrite(FW1, LOW); // blik
      
      present = ds.reset();
      ds.select(addr);    
      ds.write(0xBE);         // Read Scratchpad
    
      Serial.print("P=");
      Serial.print(present,HEX);
      Serial.print(" ");
      for ( i = 0; i < 9; i++) {           // we need 9 bytes
        data[i] = ds.read();
        Serial.print(data[i], HEX);
        Serial.print(" ");
      }
      Serial.print(" CRC=");
      Serial.print( OneWire::crc8( data, 8), HEX);
      Serial.println();
  }

  //------------------------------------------------------- Light 0
  Serial.print("Light0: COMMAND=");
  // Setup device
  Wire.beginTransmission(light0); 
  Wire.send(0x00);            // sends light0
  Wire.send(0b11000001);      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement, maybe 100ms is enough, maybe not
  delay(110); 
  digitalWrite(FW2, LOW); // blik

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

  //------------------------------------------------------- Light 1
  Serial.print("Light1: COMMAND=");
  // Setup device
  Wire.beginTransmission(light1); 
  Wire.send(0x00);            // sends light0
  Wire.send(0b11000001);      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement, maybe 100ms is enough, maybe not
  delay(110); 
  digitalWrite(FW3, LOW); // blik

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

  //-------------------------------------------------- Accelerometer
  Serial.print("X=");
  Serial.print(analogRead(A0)-512, DEC);
  Serial.print(" Y=");
  Serial.print(analogRead(A1)-512, DEC);
  Serial.print(" Z=");
  Serial.println(analogRead(A2)-512, DEC);
}



