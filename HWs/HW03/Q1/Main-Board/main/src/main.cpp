// include the library code:
#include <LiquidCrystal.h>
#include <Arduino.h>
#include <AltSoftSerial.h>

// these part is coupied from internet
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

AltSoftSerial altSerial1;
void setup() {
  altSerial1.begin(9600); // RX pin: 8, TX pin: 9
  Serial.begin(9600);

  // initialize LCD and set up the number of columns and rows:
  lcd.begin(20, 4);
}

void loop()
{
  float hum = 0 ;
  float temp = 0 ;
  float lux = 0 ;
  float value = 0;
  if (Serial.available() > 0){

     String receivedValue = Serial.readStringUntil('\n');
    if (receivedValue.substring(0 , 1) == "l" && receivedValue.substring(receivedValue.length()- 2 , receivedValue.length()-1 ) =="l"   )
    {
     String v = receivedValue.substring(1 , receivedValue.length()-1 );
     value = v.toFloat();
     lux = value;
    }
  }
  if (altSerial1.available() > 0) 
  {
    String receivedValue = altSerial1.readStringUntil('\n');
    
    int tt = receivedValue.indexOf(',');

    String number1 = receivedValue.substring(0, tt);
  
    String number2 = receivedValue.substring(tt + 1);
  
     temp = number1.toFloat();

     hum = number2.toFloat();
  }
  lcd.setCursor(0, 0);
  lcd.print("LUX: ");
  lcd.print(lux) ;

  lcd.setCursor(0, 1);
  lcd.print("temp: ");
  lcd.print(temp);
 
  lcd.setCursor(0, 2);
  lcd.print("hum: ");
  lcd.print(hum);
  if (hum>=80)
  {
  lcd.setCursor(0, 3);
  lcd.print("no watering");
  }else if(hum <= 50){
  lcd.setCursor(0, 3);
  lcd.print("action: 15 cc/min ");
   
  }else if (temp <= 25 && lux <= 600 ){
  lcd.setCursor(0, 3);
  lcd.print("action: 10 cc/min ");
  
  }else if (temp <= 25 && lux >= 600 ){
  lcd.setCursor(0, 3);
  lcd.print("action: 5 cc/min ");
  
  }else if (temp >= 25 && lux >= 600){
  lcd.setCursor(0, 3);
  lcd.print("action: 5 cc/min ");
  
  }else if (temp >= 25 && lux <= 600){
  lcd.setCursor(0, 3);
  lcd.print("action: 10 cc/min ");
  }
}
