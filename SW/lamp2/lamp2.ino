// Gas Discharge Lamps controller
#define VERSION  "$Revision: 3654 $" 


// Triacs
int t1 = 2;  // PD2 - lamp 1
int t2 = 3;  // PD3 - lamp 2
int t3 = 4;  // PD4 - 
int t4 = 5;  // PD5 - 
int t5 = 6;  // PD6 - 
int t6 = 7;  // PD7
int t7 = 8;  // PB0
int t8 = 9;  // PB1

int n;       // Counter
char state;  // State of Gas Lamps

void info ()  // Print an information string
{
  Serial.print("Gas Discharge Lamps Controller ");
  Serial.println(VERSION);
  Serial.println("Commands: abcdefghABCDEFGHitRS");
  Serial.println("a = OFF lamp 1 / A = ON lamp 1");
  Serial.println("i = info");
  Serial.println("t = telemetry");
  Serial.println("R = reset");
}


void pstatus()   // Print status to serial line 
{     
  for (n=1;n<=8;n++)    
  {
    if(digitalRead(n+1))
    {
      Serial.print((char)('A'+n-1));
    }
    else
    {
      Serial.print((char)('a'+n-1));
    }
  }
  Serial.println();
}


// the setup routine runs once when you press reset:
void setup() 
{                
  // initialize the digital pin as an output and switch off
  digitalWrite(t1, LOW);
  digitalWrite(t2, LOW);
  digitalWrite(t3, LOW);
  digitalWrite(t4, LOW);
  digitalWrite(t5, LOW);
  digitalWrite(t6, LOW);
  digitalWrite(t7, LOW);
  digitalWrite(t8, LOW);
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
  
  Serial.println("Hmmm....");
  info();
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
      case 'i':  // Print Info
        info();
        break;

      case 'R':  // Reset
        asm volatile ("  jmp 0");  
        break;

    }
    
    if ( (inByte >= 'a') and (inByte <= 'h'))  // Switch OFF other triacs
    {
      digitalWrite(inByte-'a'+2,LOW);
    }

    if ( (inByte >= 'A') and (inByte <= 'H'))  // Switch ON other triacs
    {
      digitalWrite(inByte-'A'+2, HIGH);
    }
    
    pstatus(); // Print states    
  }
}
