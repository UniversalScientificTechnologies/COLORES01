// Lamps controller
#define VERSION  "$Revision$" 


#include <OneWire.h>
#include <EEPROM.h>


#define LAG 400 // dellay in ms between lamp relay switching

// Triacs
int t1 = 2;  // PD2 - trafo for gas lamps
int t2 = 3;  // PD3 - relay for switching between lamps
int t3 = 4;  // PD4 - halogen lamp
int t4 = 5;  // PD5 - focuser
int t5 = 6;  // PD6 - COLORES
int t6 = 7;  // PD7
int t7 = 8;  // PB0
int t8 = 9;  // PB1

// DS18S20 Temperature chip 
OneWire  ds(12);  // PB4 1-Wire pin (needs pull-up to Vcc)
byte addr[8];   // Thermometer address

int n;       // Counter
char state;  // State of Gas Lamps

char deleni16[16]={'0','1','1','2','3','3','4','4','5','6','6','7','7','8','9','9'};

void info ()  // Print an information string
{
  Serial.print("Lamps Controller ");
  Serial.println(VERSION);
  Serial.println("Commands: abcdefghABCDEFGHiS");
}

int temperature ()  // Read temperature from Dallas
{
  int i, temp;
  byte data[12];
  
  if (OneWire::crc8 (addr, 7) != addr[7]) 
  {
    Serial.print("CRC is not valid!\n");
    return 0;
  }
      
  ds.reset();
  ds.select(addr);
  ds.write(0x44, 1);         // start conversion, with parasite power on at the end
      
  delay(800);     // maybe 750ms is enough, maybe not
  
  ds.reset();
  ds.select(addr);    
  ds.write(0xBE);         // Read Scratchpad
    
  for ( i = 0; i < 9; i++)   // we need 9 bytes
  {           
    data[i] = ds.read();
  }
      
  temp = (data[1] << 8) + data[0];   //take the two bytes from the response relating to temperature
  // temp = temp >> 4;  //divide by 16 to get pure celcius readout
  
  return temp;
}

void pstatus()   // Print status to serial line 
{     
  int t;        // Temperature

  t=temperature();                // Read temperature
  Serial.print (t >> 4);
  Serial.print (".");
  Serial.print (deleni16[t & 0xf]);
  Serial.print (' ');
  for (n=1;n<=8;n++)    
  {
    if(digitalRead(n+1))
    {
      Serial.print('t');
    }
    else
    {
      Serial.print('T');
    }
    Serial.print(n, DEC);
    Serial.print(' ');      
  }
  Serial.println();
}


// the setup routine runs once when you press reset:
void setup() 
{                
  // initialize the digital pin as an output and switch off
  digitalWrite(t1, HIGH);
  digitalWrite(t2, HIGH);
  digitalWrite(t3, HIGH);
  digitalWrite(t4, HIGH);
  digitalWrite(t5, HIGH);
  digitalWrite(t6, HIGH);
  digitalWrite(t7, HIGH);
  digitalWrite(t8, HIGH);
  pinMode(t1, OUTPUT);    
  pinMode(t2, OUTPUT);    
  pinMode(t3, OUTPUT);    
  pinMode(t4, OUTPUT);    
  pinMode(t5, OUTPUT);    
  pinMode(t6, OUTPUT);    
  pinMode(t7, OUTPUT);    
  pinMode(t8, OUTPUT);    
  state = 'a';
  
  // initialize the serial port
  Serial.begin(9600);  
  Serial.println();
  Serial.println("Cvak.");
  
  // OneWire init
  ds.reset_search();
  if (!ds.search(addr))  // search for next thermometer
  {
    Serial.println("Thermometer error.");
    ds.reset_search();
    delay(250);
    return;
  }
  
  for (n=1;n<=8;n++)    
  {
    digitalWrite(n+1,EEPROM.read(n));  // Read saved states from EEPROM
  }

  Serial.println("Hmmm....");
  info();
  pstatus();
}

// the loop routine runs over and over again forever:
void loop() 
{
  byte inByte;  // Character from serial line
  
  if (Serial.available() > 0) // wait for a char
  {
    // get incoming byte:
    inByte = Serial.read();
    
    switch (inByte)
    {
      
      case 'A':  // Gas Lamp 1 ON
        if (state != 'A')
        {
          digitalWrite(t1, HIGH); 
          delay(LAG);
          digitalWrite(t2, LOW);  
          delay(LAG);
          digitalWrite(t1, LOW); 
          state = 'A';
        }
        break;

      case 'B':  // Gas Lamp 2 ON
        if (state != 'B')
        {
          digitalWrite(t1, HIGH); 
          delay(LAG);
          digitalWrite(t2, HIGH);  
          delay(LAG);
          digitalWrite(t1, LOW); 
          state = 'B';
        }
        break;

      case 'a':  // Gas Lamp 1 OFF
        digitalWrite(t1, HIGH); 
        delay(LAG);
        digitalWrite(t2, HIGH);  
        state = 'a';
        break;

      case 'b':  // Gas Lamp 2 OFF
        digitalWrite(t1, HIGH); 
        delay(LAG);
        digitalWrite(t2, HIGH);  
        state = 'b';
        break;

      case 'i':  // Print Info
        info();
        break;

      case 'S':  // Save states to EEPROM
        for (n=1;n<=8;n++)    
        {
          EEPROM.write(n,digitalRead(n+1));
        }
        break;
    }
    
    if ( (inByte >= 'c') and (inByte <= 'h'))  // Switch OFF other triacs
    {
      digitalWrite(inByte-'a'+2,HIGH);
    }

    if ( (inByte >= 'C') and (inByte <= 'H'))  // Switch ON other triacs
    {
      digitalWrite(inByte-'A'+2, LOW);
    }
    
    pstatus(); // Print states    
  }
}
