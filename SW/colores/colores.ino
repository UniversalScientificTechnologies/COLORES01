#include <OneWire.h>
#include <Stepper.h>
#include <Wire.h>

/*

protokol:

M - motor na jednu stranu
m - motor na druhou stranu
--
a - vypni FW1
A - zapni FW1
--
b - vypni FW2
B - zapni FW2
--
c - vypni FW3
C - zapni FW3
--
i - inicializace: vypni vsechny FW, vytahni motor

*/

#define light0 0x44 // A0 = L (I2C light0)
#define light1 0x45 // A0 = H (I2C light1)

int lights[] = {light0, light1};

//#define LAMP1 13  // Callibration Lamp 1
//#define LAMP2  6  // Callibration Lamp 2


#define FW1    7  // [PD7 - red]    Slit Wheel 1-st from light 
#define FW2    8  // [PB0 - yellow] Grism Wheel 2-nd from light
#define FW3    3  // [PD3 - blue]   Filter Wheel 3-rd from light

int filters[] = {FW1, FW2, FW3};

const int STEPS = 3500;  // change this to fit the number of steps
const int SSPEED = 8000;   // max. 15  // stepper motor speed

// initialize the stepper library on pins 
#define M1  9
#define M2  10
#define M3  11
#define M4  12
Stepper myStepper(200, M1,M2,M3,M4);           

// DS18S20 Temperature chip 
OneWire  ds(5);  // 1-Wire pin
byte addr[2][8];    // 2x 1-Wire Address

char deleni16[16]={'0','1','1','2','3','3','4','4','5','6','6','7','7','8','9','9'};

char serInString[100];                        
int serInIndx = 0;
int in1, in2;

void motor (word arg)
{
  word n;
  word s=SSPEED;
  
/*
  for(n=0;n<2500000/SSPEED;n++)
  {
    digitalWrite(M1, LOW);  
    digitalWrite(M2, HIGH);
    digitalWrite(M1, LOW);  
    digitalWrite(M2, HIGH);
    delayMicroseconds(SSPEED);
    digitalWrite(M1, HIGH);  
    digitalWrite(M2, LOW);
    digitalWrite(M1, HIGH);  
    digitalWrite(M2, LOW);
    delayMicroseconds(SSPEED);
  }
*/

  if(arg==-1)
  { 
    for(n=0;n<STEPS/4;n++)
    {
      digitalWrite(M1, LOW);  
      digitalWrite(M2, HIGH);
//      digitalWrite(M3, LOW);
//      digitalWrite(M4, HIGH); 
      delayMicroseconds(s);
//      digitalWrite(M1, LOW);
//      digitalWrite(M2, HIGH);
      digitalWrite(M3, HIGH);   
      digitalWrite(M4, LOW); 
      delayMicroseconds(s);
      digitalWrite(M1, HIGH);  
      digitalWrite(M2, LOW);
//      digitalWrite(M3, HIGH);
//      digitalWrite(M4, LOW); 
      delayMicroseconds(s);
//      digitalWrite(M1, HIGH);  
//      digitalWrite(M2, LOW);
      digitalWrite(M3, LOW);  
      digitalWrite(M4, HIGH); 
      delayMicroseconds(s);
      if(s>1500)s-=50;
    }
  }
  else
  {
    for(n=0;n<STEPS/4;n++)
    {
//      digitalWrite(M1, HIGH);  
//      digitalWrite(M2, LOW);
      digitalWrite(M3, LOW);  
      digitalWrite(M4, HIGH); 
      delayMicroseconds(s);
      digitalWrite(M1, HIGH);  
      digitalWrite(M2, LOW);
//      digitalWrite(M3, HIGH);
//      digitalWrite(M4, LOW); 
      delayMicroseconds(s);
//      digitalWrite(M1, LOW);
//      digitalWrite(M2, HIGH);
      digitalWrite(M3, HIGH);  
      digitalWrite(M4, LOW); 
      delayMicroseconds(s);
      digitalWrite(M1, LOW);  
      digitalWrite(M2, HIGH);
//      digitalWrite(M3, LOW);
//      digitalWrite(M4, HIGH); 
      delayMicroseconds(s);
      if(s>1500)s-=50;
    }
  }
/*  
  myStepper.setSpeed(1);
  myStepper.step(arg * 10);
  myStepper.setSpeed(sspeed);
  myStepper.step(arg * steps);
*/  
  digitalWrite(M1, LOW);
  digitalWrite(M2, LOW);
  digitalWrite(M3, LOW);
  digitalWrite(M4, LOW); 
}

int light (int arg)
{
  int LSB = 0, MSB = 0;  // data from light
  
  // Setup device
  Wire.beginTransmission(lights[arg]); 
  Wire.write(byte(0x00));            // command register
  Wire.write(byte(0b11000001));      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement, maybe 100ms is enough, maybe not
  delay(110);

  // LSB
  Wire.beginTransmission(lights[arg]); 
  Wire.write(byte(0x01));            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(lights[arg]);
  Wire.requestFrom(lights[arg], 1);
  LSB = Wire.read();
  Wire.endTransmission();
  
  // MSB
  Wire.beginTransmission(lights[arg]);
  Wire.write(byte(0x02));            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(lights[arg]);
  Wire.requestFrom(lights[arg], 1);
  MSB = Wire.read();
  Wire.endTransmission();     // stop transmitting
  
  return ((MSB << 8) + LSB);  
}

int temperature (int arg)
{
  int i, temp;
  byte data[12];
  
  if (OneWire::crc8 (addr[arg], 7) != addr[arg][7]) 
  {
    Serial.print("CRC is not valid!\n");
    return 0;
  }
      
  ds.reset();
  ds.select(addr[arg]);
  ds.write(0x44, 1);         // start conversion, with parasite power on at the end
      
  delay(800);     // maybe 750ms is enough, maybe not
  
  ds.reset();
  ds.select(addr[arg]);    
  ds.write(0xBE);         // Read Scratchpad
    
  for ( i = 0; i < 9; i++)   // we need 9 bytes
  {           
    data[i] = ds.read();
  }
      
  temp = (data[1] << 8) + data[0];   //take the two bytes from the response relating to temperature
  // temp = temp >> 4;  //divide by 16 to get pure celcius readout
  
  return temp;
}

void inicializace ()
{
  // vysune se motor
  motor (1);
  // vsechny vystupy off
  // digitalWrite(LAMP1, LOW); 
  // digitalWrite(LAMP2, LOW); 
  digitalWrite(FW1, LOW); 
  digitalWrite(FW2, LOW); 
  digitalWrite(FW3, LOW);  
}

void setup() 
{
  // pinMode(LAMP1, OUTPUT); 
  // pinMode(LAMP2, OUTPUT); 
  pinMode(FW1, OUTPUT); 
  pinMode(FW2, OUTPUT); 
  pinMode(FW3, OUTPUT); 

pinMode(6, OUTPUT); 
//analogWrite(6, 254);
digitalWrite(6, HIGH);  
    
  // initialize the serial port:
  Serial.begin(9600);
  
  Wire.begin(); // join i2c bus 
  
  // OneWire 
  ds.reset_search();
  if (!ds.search(addr[0]))  // search for next thermometer
  {
    Serial.print ("1st thermometer error.");
    ds.reset_search();
    delay(250);
    return;
  }
  if (!ds.search(addr[1]))  // search for next thermometer
  {
    Serial.print ("2nd thermometer error.");
    ds.reset_search();
    delay(250);
    return;
  }
  
  inicializace ();
}

void telemetrie ()
{
  int t;
  Serial.print ("FW1=");
  Serial.print (digitalRead (filters[0]) ? '1' : '0');
  Serial.print (",FW2=");
  Serial.print (digitalRead (filters[1]) ? '1' : '0');
  Serial.print (",FW3=");
  Serial.print (digitalRead (filters[2]) ? '1' : '0');
  Serial.print (",T1=");
  t=temperature(0);
  Serial.print (t >> 4);
  Serial.print (".");
  Serial.print (deleni16[t & 0xf]);
  Serial.print (",T2=");
  t=temperature(1);
  Serial.print (t >> 4);
  Serial.print (".");
  Serial.print (deleni16[t & 0xf]);
  Serial.print (",L1=");
  Serial.print (light (0));
  Serial.print (",L2=");
  Serial.print (light (1));
  Serial.println ();
}

void readSerialString () 
{
  serInIndx=0;
  do
  {
    while(Serial.available()==0);
    serInString[serInIndx] = Serial.read();
    Serial.print(serInString[serInIndx]);
    serInIndx++;
  } while ((serInString[serInIndx-1]!='\n')&&(serInString[serInIndx-1]!='.'));
  Serial.print("\r\n=");
}

void loop() 
{ 
  // readSerialString();
  
  if (Serial.available())
  {
    switch (Serial.read())
    {
      case 'i':	// inicializace
        inicializace ();
        break;
      case 'm':
        motor (-1);
        break;
      case 'M':
        motor (1); // vysunuto
        break;

      case 'x':
  myStepper.setSpeed(100);
  myStepper.step(3000);
        break;
      case 'y':
  myStepper.setSpeed(10.0);
  myStepper.step(-3000);
        break;

      case 'A':
        digitalWrite(FW1, HIGH);
        break;
      case 'a':
        digitalWrite(FW1, LOW);
        break;
      case 'B':
        digitalWrite(FW2, HIGH);
        break;
      case 'b':
        digitalWrite(FW2, LOW);
        break;
      case 'C':
        digitalWrite(FW3, HIGH);
        break;
      case 'c':
        digitalWrite(FW3, LOW);
        break;
    }
    telemetrie ();
    Serial.flush ();
    // /for (serInIndx = 100; serInIndx > 0; serInIndx--)
    //  serInString[serInIndx] = ' ';
  }
  
  // delay(100);
}
