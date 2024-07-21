
#include "Wire.h"
#include "SHT2x.h"
SHT2x sht;
void setup()
{
  Serial.begin(9600); 
}
void loop()
{
  bool success  = sht.read();
  if (success)
  {    
    String temp =String((sht.getTemperature()));
    String hum =String((sht.getHumidity()));
    String csv = temp + "," + hum;
    Serial.println(csv);
  }

}