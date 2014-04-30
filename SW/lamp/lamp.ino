// Lamps controller

#define LAG 400 // dellay in ms between lamp relay switching

int t1 = 2;  // PD2 - trafo for gas lamps
int t2 = 3;  // PD3 - relay for switching between lamps
int t3 = 4;  // PD4 - halogen lamp
int t4 = 5;  // PD5 - focuser
int t5 = 6;  // PD6
int t6 = 7;  // PD7
int t7 = 8;  // PB0
int t8 = 9;  // PB1

int n;

char state;

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
}

// the loop routine runs over and over again forever:
void loop() 
{
  byte inByte;
  
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
          delay(LAG);
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
          delay(LAG);
          state = 'B';
        }
        break;

      case 'a':  // Gas Lamp 1 OFF
        digitalWrite(t1, HIGH); 
        delay(LAG);
        digitalWrite(t2, HIGH);  
        delay(LAG);
        state = 'a';
        break;

      case 'b':  // Gas Lamp 2 OFF
        digitalWrite(t1, HIGH); 
        delay(LAG);
        digitalWrite(t2, HIGH);  
        delay(LAG);
        state = 'b';
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
    
    
    for (n=1;n<=8;n++)    // Send status to serial line
    {
      Serial.print('t');
      Serial.print(n, DEC);
      Serial.print('=');
      Serial.print((~digitalRead(n+1))&1, DEC);
      Serial.print(' ');      
    }
    Serial.println();
    
  }
}
