// main logic to control the RGB LED with the right colors
void moodControl(){  // Split the serial input string from ElectricImp into groups of variables
  printDln("Splitting serial input string into groups:");
  String red = (inputString.substring(2,5)); //
  String green = (inputString.substring(5,8));
  String blue = (inputString.substring(8,11));
  String hue = (inputString.substring(18,21));
  String saturation = (inputString.substring(21,24));
  String brightness = (inputString.substring(24,27));
  String setTempAlarm = (inputString.substring(30,31));
  String fuelToday = (inputString.substring(31,35));
  String fuelGoal = (inputString.substring(35,39));
  String temperature = (inputString.substring(39,44));
  String phColorX = (inputString.substring(44,50));
  String phColorY = (inputString.substring(50,56));
  String phBri = (inputString.substring(56,59));
  String phSync = (inputString.substring(59,60)); //Philips Hue Sync 1=true 0=false

  printDln("RGB:");
  printD ((String)red);
  printD(",");
  printD((String)green);
  printD(",");
  printDln((String)blue);
  printDln("HUE/ HSL:");
  printDln((String)hue);
  printDln("Saturation:");
  printDln((String)saturation);
  printDln("Brightness:");
  printDln((String)brightness);
  printDln("Nike Fuel earned:");
  printD((String)fuelToday);
  printD("/");
  printDln((String)fuelGoal);
  printDln("Temperature:");
  printDln((String)temperature);
  printDln("Temperature Alarm? true/false:");
  printDln((String)setTempAlarm);
  printDln("Philips Hue Color X:");
  printDln((String)phColorX);
  printDln("Philips Hue Color Y:");
  printDln((String)phColorY);
  printDln("Philips Hue Brightness:");
  printDln((String)phBri);
  printDln("Philips Sync with Moodlamp? true/false");
  printDln((String)phSync);

  //Change all grouped strings to int or float vars
  int redint = red.toInt();
  int greenint = green.toInt();
  int blueint = blue.toInt();
  int hueint = hue.toInt();
  int saturationint = saturation.toInt();
  int brightnessint = brightness.toInt();
  int fuelTodayint = fuelToday.toInt();
  int fuelGoalint = fuelGoal.toInt();
  int temperatureint = temperature.toInt();
  float phColorXfloat =StrToFloat(phColorX);
  float phColorYfloat =StrToFloat(phColorY);
  float phBrifloat =StrToFloat(phBri);

  inputString = "";

  if (brightnessint > 0){
    HsbConverter(hueint,brightnessint,saturationint);
    HSBMode =true;
  } 

  if (phSync == "1" && HSBMode == false){

    xyBriToRgb(phColorXfloat,phColorYfloat,phBrifloat);
    HSBMode = false;
  } 

  if (phSync == "0" && HSBMode == false){
    printDln("Philips Hue sync active!");
    setLedColor(redint,greenint,blueint);
    HSBMode = false;
  }

  if (fuelTodayint > 0){
    nikeFuel(fuelTodayint, fuelGoalint,hueint, brightnessint, saturationint);
  }
  //Temperature Alarm
  if (setTempAlarm == "1"){
    printDln("Temperature Alarm set!");
    if (preTemperature == 12356){
      preTemperature = temperatureint;
    }
    if (temperatureint > (preTemperature + tempAlarm) || temperatureint < (preTemperature - tempAlarm)){
      weather(temperatureint, hueint, brightnessint,saturationint);
    }
  }

  HSBMode = false;
}

//Function to convert string to float
float StrToFloat(String str){
  char carray[str.length() + 1]; //determine size of the array
  str.toCharArray(carray, sizeof(carray)); //put str into an array
  return atof(carray);
}











