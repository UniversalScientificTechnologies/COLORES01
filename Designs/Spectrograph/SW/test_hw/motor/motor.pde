#include <OneWire.h>
#include <Stepper.h>

const int stepsPerRevolution = 3200;  // change this to fit the number of steps per revolution
                                     // for your motor
byte sense=0;

// initialize the stepper library on pins 
Stepper myStepper(stepsPerRevolution, 9,10,11,12);           

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

void loop() 
{
  byte i;
  byte present = 0;
  byte data[12];
  byte inByte;
    
  // if we get a valid byte
//!!!  if (Serial.available() > 0) 
  {
    // get incoming byte:
//!!!    inByte = Serial.read();

    if(sense)
    {
      digitalWrite(0, LOW); // blik
      // step one revolution  in one direction:
      Serial.println("clockwise");
      myStepper.step(stepsPerRevolution);
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
      digitalWrite(0, HIGH);  // blik
       // step one revolution in the other direction:
      Serial.println("counterclockwise");
      myStepper.step(-stepsPerRevolution);
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
  }
}



