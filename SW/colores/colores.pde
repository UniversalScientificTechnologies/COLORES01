#include <OneWire.h>
#include <Stepper.h>
#include <Wire.h>

#define light0 0x44 // A0 = L (I2C light0)
#define light1 0x45 // A0 = H (I2C light1)

int lights[] = {light0, light1};

#define LAMP1 13  // Callibration Lamp 1
#define LAMP2  6  // Callibration Lamp 2

int lamps[] = {LAMP1, LAMP2};

#define FW1    7  // FilterWheel 1
#define FW2    8  // FilterWheel 1
#define FW3    3  // FilterWheel 1

int filters[] = {FW1, FW2, FW3};

int motors[] = {-1, 1};

const int steps = 200; //3200;  // change this to fit the number of steps
const int sspeed = 100; // stepper motor speed

// initialize the stepper library on pins 
#define M1  9
#define M2  10
#define M3  11
#define M4  12
Stepper myStepper(steps, M1,M2,M3,M4);           

// DS18S20 Temperature chip 
OneWire  ds(5);  // 1-Wire pin
byte addr[2][8];    // 2x 1-Wire Address

char serInString[100];                        
int serInIndx = 0;
int in1, in2;

void setup() 
{
  pinMode(LAMP1, OUTPUT); 
  pinMode(LAMP2, OUTPUT); 
  pinMode(FW1, OUTPUT); 
  pinMode(FW2, OUTPUT); 
  pinMode(FW3, OUTPUT); 
  
  digitalWrite(LAMP1, HIGH); // All outputs OFF
  digitalWrite(LAMP2, HIGH); 
  digitalWrite(FW1, HIGH); 
  digitalWrite(FW2, HIGH); 
  digitalWrite(FW3, HIGH); 

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
}

void motor (int arg)
{
  myStepper.setSpeed(sspeed/2);
  myStepper.step(arg * 30);
  myStepper.setSpeed(sspeed);
  myStepper.step(arg * (steps-50));
  myStepper.setSpeed(sspeed/2);
  myStepper.step(arg * 20);
  delay(50);
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
  Wire.send(0x00);            // command register
  Wire.send(0b11000001);      // setup (eye light sensing; measurement range 2 [4000 lx])
  Wire.endTransmission();     // stop transmitting

  // Delay for measurement, maybe 100ms is enough, maybe not
  delay(110);

  // LSB
  Wire.beginTransmission(lights[arg]); 
  Wire.send(0x01);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(lights[arg]);
  Wire.requestFrom(lights[arg], 1);
  LSB = Wire.receive();
  Wire.endTransmission();
  
  // MSB
  Wire.beginTransmission(lights[arg]);
  Wire.send(0x02);            // sends light0
  Wire.endTransmission();     // stop transmitting
  //  Connect to device and request one byte
  Wire.beginTransmission(lights[arg]);
  Wire.requestFrom(lights[arg], 1);
  MSB = Wire.receive();
  Wire.endTransmission();     // stop transmitting
  
  return ((MSB << 8) + LSB);  
}

int temperature (int arg)
{
  int i, Temp;
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
      
  Temp = (data[1] << 8) + data[0];   //take the two bytes from the response relating to temperature
  Temp = Temp >> 4;  //divide by 16 to get pure celcius readout

  return Temp;
}

void accelerometer ()
{
  Serial.print("X=");
  Serial.print(analogRead(A0)-512, DEC);
  Serial.print(" Y=");
  Serial.print(analogRead(A1)-512, DEC);
  Serial.print(" Z=");
  Serial.println(analogRead(A2)-512, DEC);
}

void readSerialString () 
{
  if(Serial.available()) 
  {
    while (Serial.available())
    {
      serInString[serInIndx] = Serial.read();
      serInIndx++;
    }
  }
}

void loop() 
{ 
  readSerialString();
  
  if( serInIndx > 0)
  {   
    in1 = serInString[1] - '0'; 
     
    switch (serInString[0])
    {
      case '?':
        Serial.println ("Device queries:");
        Serial.println (" l[0,1] light in luxes");
        Serial.println (" t[0,1] temperature in Celsius degrees");
        Serial.println (" F[0,1][0|1] switch filter wheel on (1) or off (0)");
        Serial.println (" F[0,1]? check state of filter wheel");
        Serial.println (" L[0,1][0|1] switch calibration lamp on (1) or off (0)");
        Serial.println (" L[0,1]? check state of calibration lamp");
        Serial.println (" M[0|1] motor rotation clockwise (1) or counterclockwise (0)");
        break;
      case 't':
        Serial.println (temperature (in1));
        break;
      case 'l':
        Serial.println (light (in1));
        break;
      case 'L':
        if (serInString[2] == '?')
        {
          Serial.println (digitalRead (lamps[in1]) ? '0' : '1'); 
        }
        else
        {
          in2 = serInString[2] - '0'; 
          digitalWrite(lamps[in1], in2 ? LOW : HIGH);
        }
        break;
      case 'F':
        if (serInString[2] == '?')
        {
          Serial.println (digitalRead (filters[in1]) ? '0' : '1'); 
        }
        else
        {
          in2 = serInString[2] - '0'; 
          digitalWrite(filters[in1], in2 ? LOW : HIGH);
        }
        break;
      case 'M':
        motor (motors[in1]);
        break;
    }
    for (serInIndx = 100; serInIndx > 0; serInIndx--)
      serInString[serInIndx] = ' ';
    
    Serial.flush ();
  }
  
  delay(100);
}



