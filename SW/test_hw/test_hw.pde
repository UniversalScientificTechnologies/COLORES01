#include <OneWire.h>
#include <Stepper.h>
#include <Wire.h>

#define address 0x44 // A0 = L (I2C address)

const int steps = 200; //3200;  // change this to fit the number of steps


// initialize the stepper library on pins 
Stepper myStepper(steps, 9,10,11,12);           

// DS18S20 Temperature chip 
OneWire  ds(1);  // 1-Wire
byte addr[8];    // Addres

void setup() 
{
  pinMode(13, OUTPUT);  // LED
  digitalWrite(13, LOW); // LED ON

  // initialize the serial port:
  Serial.begin(9600);

  // set the speed 
  myStepper.setSpeed(8);
  
  Wire.begin(); // join i2c bus (address optional for master)

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
  
  if(sense)
  {
    digitalWrite(13, LOW); // blik
    // step one revolution  in one direction:
    Serial.println("clockwise");
    myStepper.step(steps);
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
    myStepper.step(-steps);
    delay(50);
    digitalWrite(9, LOW);
    digitalWrite(10, LOW);
    digitalWrite(11, LOW);
    digitalWrite(12, LOW);
    delay(500); 
    sense=1;
  }
  
  // 1-Wire bus
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion
  delay(1000);     // maybe 750ms is enough, maybe not  
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
  Wire.beginTransmission(address); 
  Wire.send(0x00);            // sends address
  Wire.send(0b11000001);      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement
  digitalWrite(13, HIGH);   // set the LED on
  delay(500);
  digitalWrite(13, LOW);    // set the LED off
  delay(500);


  //  Connect to device and set register address
  Wire.beginTransmission(address); 
  Wire.send(0x00);            // sends address
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(address);
  Wire.requestFrom(address, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print(" LSB=");
  //  Connect to device and set register address
  Wire.beginTransmission(address); 
  Wire.send(0x01);            // sends address
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(address);
  Wire.requestFrom(address, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print(" MSB=");  
  //  Connect to device and set register address
  Wire.beginTransmission(address);
  Wire.send(0x02);            // sends address
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(address);
  Wire.requestFrom(address, 1);
  dd = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  Serial.print(dd, HEX);

  Serial.print("\n");

}



