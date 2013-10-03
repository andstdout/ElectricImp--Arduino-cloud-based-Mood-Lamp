//set RGB led to given colors
void setLedColor(int red, int green, int blue)
{
  if (red == 0){
    red = 1;
  }
  if (green == 0){
    green = 1;
  }
  if (blue == 0){
    blue = 1;
  }
  
analogWrite(ledPinR,red);
analogWrite(ledPinG,green);
analogWrite(ledPinB,blue);
if (VirtualColorMixer){
      Serial.print(red);
      Serial.print(",");
      Serial.print(green);
      Serial.print(",");
      Serial.println(blue);
    }
  preRed = red;
  preGreen = green;
  preBlue = blue;
}




