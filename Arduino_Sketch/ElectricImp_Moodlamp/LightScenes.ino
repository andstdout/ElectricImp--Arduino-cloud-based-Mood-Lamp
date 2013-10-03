//light scenes, blinking (not used yet), nikeFuel, weather
void sceneBlink(char color, int blinkCount, int blinkInterval){
  int saveRed = preRed;
  int saveGreen = preGreen;
  int saveBlue = preBlue;
  int red, green, blue;

  switch(color) {

  case 'r':
    red = 255;
    green = 0;
    blue = 0;
    break;

  case 'g':
    red = 0;
    green = 255;
    blue = 0;      
    break;

  case 'b':
    red = 0;
    green = 0;
    blue = 255;     
    break;
  }
  setLedColor(0,0,0);
  for (int i=0;i<blinkCount;i++){
    setLedColor(red, green, blue);
    delay(blinkInterval);
    setLedColor(0,0,0);
    delay(blinkInterval);
  }

}

void nikeFuel(int fuelToday, int fuelGoal, int hue, int brightness, int sat){
  int hueFuelToday = 0;  

  if (fuelToday < fuelGoal){
    hueFuelToday = map(fuelToday, 0, fuelGoal, 0,110); //0 - 120 are the colors from red to green, map the colors
  } 
  else {
    hueFuelToday = 120; //set fuel to red
  }

  if (brightness > 0){ //dimming the actual HSB light setting to zero
    for (int i = brightness; i > 0 ; i--){
      HsbConverter(hue,i,sat); 
      delay(10);
    }
  }
  for (int i = 0; i < 255; i++){ //dimming the fuel red to full brigthness
    HsbConverter(0,i,255);
    delay(10);
  }
  delay(50);
  for (int i = 1; i < hueFuelToday;i++){ //fading the fuel color from red to actual fuel
    HsbConverter(i,255,255);
    delay(100);
  } 
  delay(500); 
  if (fuelToday > fuelGoal){ //Some light firework!!!
    for (int i = 1; i < 360; i++){
      int randColor = random(0, 359);
      int randSat = random(0,255);
      int randBrightness = random(200,255);
      HsbConverter(randColor,randBrightness,randSat);
      delay(30);
    }
    HsbConverter(0,0,0);
  }
  delay(50);
  for (int i = 1; i < 3 ;i++){ //Blink green two times at the end like the NikeFuel Band
    HsbConverter(0,0,0);
    delay(200);
    HsbConverter(120,250,255);
    delay(500);
    HsbConverter(0,0,0);
    delay(200);
  }
  if (brightness > 0){ //fading back to old light setting for HSB
    for (int i = 0; i <= brightness; i++){
      HsbConverter(hue,i,sat);
      delay(5);
    } 
  }
}

void weather(int temperature, int hue, int brightness, int sat){
  preTemperature = temperature;
  if  (temperature < 30 && temperature > -30){
    temperature = map(temperature, -30, 50, 240,1); //map HSB colors to temperature
  } 
  else if (temperature > 30){
    temperature = 1;
  } 
  else if (temperature < -30){
    temperature = 240;
  } 
  if (brightness > 0){ //dimming the actual HSB light setting to zero
    for (int i = brightness; i > 0 ; i--){
      HsbConverter(hue,i,sat); 
      delay(5);
    }
  }
    
  for (int i = 0; i < 255 ; i++){ //dimming the temperature color to full brigthness
    HsbConverter(temperature,i,i);
    delay(5);
  }
  
  delay(15000); 
  for (int i = 1; i < 3 ;i++){ //Blink temperature two times at the end like the NikeFuel Band
    HsbConverter(0,0,0);
    delay(200);
    HsbConverter(temperature,255,255);
    delay(500);
    HsbConverter(0,0,0);
    delay(200);
  }
  if (brightness > 0){ //fading back to old light setting for HSB
    for (int i = 0; i <= brightness; i++){
      HsbConverter(hue,i,sat);
      delay(5);
    } 
  }
}









