 
// A lamp controller

#define LAG 400 // dellay in ms between switching

int trafo = 6;   // PD6 - trafo for a lamp
int rele  = 8;   // PB0 - relay for switching between lamps
char state;

// the setup routine runs once when you press reset:
void setup() 
{                
  // initialize the digital pin as an output and switch off
  digitalWrite(trafo, HIGH);
  digitalWrite(rele, HIGH);
  pinMode(trafo, OUTPUT);    
  pinMode(rele, OUTPUT);    
  state = 'o';
  
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
      case 'a':  // Argon lamp ON
        if (state != 'a')
        {
          digitalWrite(trafo, HIGH); 
          delay(LAG);
          digitalWrite(rele, LOW);  
          delay(LAG);
          digitalWrite(trafo, LOW); 
          delay(LAG);
          state = 'a';
        }
        break;

      case 'x':  // Xenon lamp ON
        if (state != 'x')
        {
          digitalWrite(trafo, HIGH); 
          delay(LAG);
          digitalWrite(rele, HIGH);  
          delay(LAG);
          digitalWrite(trafo, LOW); 
          delay(LAG);
          state = 'x';
        }
        break;
        
      default:  // OFF all lamps
        state = 'o';
        digitalWrite(trafo, HIGH); 
        delay(LAG);
        digitalWrite(rele, HIGH);  
        break;
    }              
    Serial.write(inByte); // echo char
  }
}
