/*

********************************
***    Lights Manager        ***
***                          ***
*** By Jorge Calleja Arteaga ***
*** and Luis Carlos López   ****
********************************


STATUS:

DONE:
---------------------------------------
- Auto Mode: 
Depending on current light level, arduino can switch on 0,1,2,3, or 4 lights (Pins D8,D9,D10,D11 and A3 for light level input)
If in AutoMode one additional led (pin D6) should turn on.

- If an SMS is recieved, and it has '0', all lights should turn off even "auto mode indicator" (Pin D6)
- If an SMS is recieved, and it has '1','2','3', or '4' arduino should turn on as many ligthts as current number recieved
- If an SMS is recieved, and it has a higher number than 4, then AUTO MODE should be activated again turning of led in D6


TODO:
--------------------------------------------
- Allow to recieve messages using full text inputs like "AUTO", and  "OFF".
- Save last configuration to EEPROM to prevent resets by power down energy supply.
- Allow to recieve a message request using "STATUS" and then Arduino sends a status message with values of current luminosity detected,
, current lights switched on, and AUTO status (Auto mode On/Auto mode Off):
Example:

"Current Status: Auto Mode ON, Current Luminosity: 456, 2 light ON"
*/

#include <ClientGSM.h>
#include <GSM.h>
#include <inetGSM.h>
#include <LOG.h>
#include <QuectelM10.h>
#include <ServerGSM.h>
#include <Streaming.h>
#include <UDPGSM.h>
#include <WideTextFinder.h>

#include "QuectelM10.h"
#include <NewSoftSerial.h>

int sensorValue = 0;
int led1Val = 200;
int led2Val = 400;
int led3Val = 600;
int led4Val = 800;
int led5Val = 950;

int fixedValue=0;
unsigned long lastInboxCheck = 0;

boolean autoMode = true;
// GSM Module:
// ------------------
char msg[200];
int numdata;

void setup()
{
  
  pinMode(A3,INPUT);
  
  pinMode(8,OUTPUT);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  pinMode(11,OUTPUT);
  
  pinMode(6,OUTPUT);
  
  Serial.begin(9600);
  
  // GSM Module:
  // ------------------
  Serial.println("GSM Shield testing.");
  //Start configuration.
  if (gsm.begin())
    Serial.println("\nstatus=READY");
  else Serial.println("\nstatus=IDLE");
  
  //if (gsm.sendSMS("620026695", "SMS Service On"))
    //Serial.println("\nSMS sent OK");
}

void loop()
{
  // Leer GSM:
  // ------------------
  char smsbuffer[160];
  char n[20];
  
  //  Check SMS for each 5 seconds
  if ((millis() - lastInboxCheck) > 5000)
  {
    Serial.println("CHECKING SMSs");
    lastInboxCheck = millis();
    
    if(gsm.readSMS(smsbuffer, 160, n, 20))
    {
      Serial.println(n);
      Serial.println(smsbuffer);
      
      String smsStr = String(smsbuffer);
   
      
      if (gsm.sendSMS("620026695", "SMS Recieved"))
      Serial.println("\nSMS sent OK");
    
      if (smsStr.toUpperCase().compareTo("AUTO")==0)
      {
        autoMode = true;
        Serial.println("automode enabled AUTO");
      }
      else if (smsStr.toUpperCase().compareTo("OFF")==0)
      {
        autoMode = false;
        fixedValue = 0;
        Serial.println("automode disabled OFF");
        
      }
      else if (smsStr.toUpperCase().compareTo("STATUS")==0)
      {
        //TODO
      }
      else
      {

        int valueSMS = int(smsbuffer[0])-48;
        Serial.println(valueSMS);
        switch(valueSMS)
        {
          case 0:
            autoMode = false;
            Serial.println("automode disabled 0");
            fixedValue = valueSMS;
          break;
          case 1:
            autoMode = false;
            Serial.println("automode disabled 1");
            fixedValue = valueSMS;
          break;
          case 2:
            autoMode = false;
            Serial.println("automode disabled 2");
            fixedValue = valueSMS;
          break;
          case 3:
            autoMode = false;
            Serial.println("automode disabled 3");
            fixedValue = valueSMS;
          break;
          case 4:
            autoMode = false;
            Serial.println("automode disabled 4");
            fixedValue = valueSMS;
          break;
          default:
            autoMode = true;
            Serial.println("automode enabled DEFAULT");
          break;
        }
      }
    }
  }
  
  
  Serial.println("PROCESSING");
  if (autoMode)
  {
    
      digitalWrite(6,HIGH);
  
    // LEDs
    // ------------------
    sensorValue = analogRead(A3);
    Serial.println(sensorValue);
    
    
    // LED MINIMO
    if (sensorValue > led1Val)
    {
      digitalWrite(8,HIGH);
    }
    else
    {
      digitalWrite(8,LOW);
    }
    
     // LED MEDIO
    if (sensorValue > led2Val)
    {
      digitalWrite(9,HIGH);
    }
    else
    {
      digitalWrite(9,LOW);
    }
    
     // LED ALTO
    if (sensorValue > led3Val)
    {
      digitalWrite(10,HIGH);
    }
    else
    {
      digitalWrite(10,LOW);
    }
    
     // LED MAXIMO
    if (sensorValue > led4Val)
    {
      digitalWrite(11,HIGH);
    }
    else
    {
      digitalWrite(11,LOW);
    }

  }
  else // No auto
  {
    digitalWrite(6,LOW);
    
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    
    if (fixedValue>0) digitalWrite(8,HIGH);
    if (fixedValue>1) digitalWrite(9,HIGH);
    if (fixedValue>2) digitalWrite(10,HIGH);
    if (fixedValue>3) digitalWrite(11,HIGH);
  
  }
  delay(300);
}
