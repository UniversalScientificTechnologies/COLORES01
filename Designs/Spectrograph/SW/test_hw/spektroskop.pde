#include <OneWire.h>
#include <Stepper.h>

const int stepsPerRevolution = 3200;  // change this to fit the number of steps per revolution
                                     // for your motor
byte sense=0;

// initialize the stepper library on pins 
Stepper myStepper(stepsPerRevolution, 2,3,4,5);           

// DS18S20 Temperature chip 
OneWire  ds(1);  // 1-Wire
byte addr[8];    // Addres

void setup() 
{
  pinMode(48, OUTPUT);  // Wiring LED
  pinMode(0, OUTPUT);  // LED
  digitalWrite(48, LOW); // Wiring LED

  // set the speed at 60 rpm:
  myStepper.setSpeed(8);
  // initialize the serial port:
  Serial.begin(9600);

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
    
  // if we get a valid byte, read analog ins:
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
      digitalWrite(2, LOW);
      digitalWrite(3, LOW);
      digitalWrite(4, LOW);
      digitalWrite(5, LOW);
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
      digitalWrite(2, LOW);
      digitalWrite(3, LOW);
      digitalWrite(4, LOW);
      digitalWrite(5, LOW);
      delay(500); 
      sense=1;
    }
    
    ds.reset();
    ds.select(addr);
    ds.write(0x44,1);         // start conversion, with parasite power on at the end
  
    delay(1000);     // maybe 750ms is enough, maybe not
    // we might do a ds.depower() here, but the reset will take care of it.
  
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



