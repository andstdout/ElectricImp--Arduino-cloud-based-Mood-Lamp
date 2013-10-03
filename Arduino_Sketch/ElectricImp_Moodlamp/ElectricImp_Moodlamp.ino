/*
This sketch "Moodlamp Control Logic" was created by Andreas Pagel 2013
Some parts of this software were taken from:
getRGB() function based on <http://www.codeproject.com/miscctrl/CPicker.asp>  
dim_curve idea by Jims <http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1174674545>
Philips Hue color conversion <https://github.com/PhilipsHue/PhilipsHueSDKiOS/blob/master/ApplicationDesignNotes/RGB%20to%20xy%20Color%20conversion.md>

--- All other parts of this software are licensed under the GPL:

    Copyright (C) 2013 by Andreas Pagel

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <SoftwareSerial.h>
#include <EEPROM.h>

//CUSTOM Settings:
int tempAlarm = 3; // hysteresis for temperature changes
boolean debugLocal = true; //serial print debugging. Function "printd" and "printDln"
boolean debugImp = false; // send all serial print debug messages to electric imp. Function "printd" and "printDln"
boolean VirtualColorMixer = false; //Processing; VirtualColorMixer, have a look at Arduino Examples -> Commuincation -> VirtualColorMixer(Virtual RGB)
const int ledPinR   = 11;  // pwm pin with red led
const int ledPinG   = 10; // pwm pin with green led
const int ledPinB   = 3; // pwm pin with blue led; 
//-------------------------------------------;-)


SoftwareSerial impSerial(8, 9); // RX on 8, TX on 9
const String args[0];
String inputString = args[0]; //serial input
String outputString; //serial output 
boolean inputStringComplete = false; 
boolean outputStringComplete = false;
boolean HSBMode = false;
int preRed;
int preGreen;
int preBlue;
int preTemperature = 12356;

void setup()  
{
  // Open the hardware serial port
  Serial.begin(57600);
  // set the data rate for the SoftwareSerial port
  impSerial.begin(57600);
  analogWrite(ledPinR,1); //It's a workaround, my custom mosfet/ transistor circuit need to hold a minimal voltage to avoid flickering when the leds are turned on
  analogWrite(ledPinG,1);
  analogWrite(ledPinB,1);

  if (VirtualColorMixer){  //we need to turn off all SerialPrint- debugging for VirtualColorMixer
    debugLocal = false;
    debugImp = false;
  }
  impSerial.write("aiRETRYe\n"); //request the last string from ElectricImp
  delay(500);
}

void loop()
{ 
  readSerial();
  if (inputStringComplete) {
    moodControl(); //main function to control the lamp
    
    }
    inputString = args[0];
    inputStringComplete = false;
    

  if (outputStringComplete) {
    // clear the string:
    outputString = args[0];
    outputStringComplete = false;
  }
}








