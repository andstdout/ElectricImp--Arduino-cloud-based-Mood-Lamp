// UART Read Example
 
// configure a pin pair for UART TX/RX
local rgbHex = format("%07d", 0); //RGB HEX
local red = format("%03d", 0); //RGB red
local green = format("%03d", 0); //RGB green
local blue = format("%03d", 0); //RGB blue
local tempAlarm = 1; //temperature alarm set?
local fader = format("%03d", 0); //RGB brightness fader
local moodProt = 0; //Moodlamp Arduino <-> IMP Protocol definition
local hue = format("%03d", 0); //HSB hue
local sat = format("%03d", 0); //HSB saturation
local bri = format("%03d", 0); //HSB brightness
local stringComplete = 0; //Boolean variable for moodProt protocol
local fuel =  format("%04d", 0); //Nike Fuel
local fuelDailyGoal = format("%04d", 0); //Nike Fuel Daily Goal;
local temperature = format("%05d", 0);
local condition;
local custom = format("%03d", 0); //Three digits within moodProt for custom use
local readSerialBlocked = 0; //Block interval SerialReading, when we request some data
local phColorX = format("%06d",0);
local phColorY = format("%06d",0);
local phBri = format ("%03d",0);
phSync <- 0;
serialMessage <- "";
moodComBlocked <- 0;


function InitUart() //Init serial com
{
hardware.configure(UART_57);  
hardware.uart57.configure(57600, 8, PARITY_NONE, 1, NO_CTSRTS);
local impeeOutput = OutputPort("UART In", "string");  // set impeeOutput as a string
}

//Agent <-> Device functions to receive data from imp-agent
agent.on("RedDev", function(msg) { 
    if (msg >= 100){
        red = msg;
    } else if (msg < 100){
    red = format("%03d", msg);
    }
});

agent.on("GreenDev", function(msg) {
  if (msg >= 100){
        green = msg;
    } else if (msg < 100){
    green = format("%03d", msg);
    }
});

agent.on("BlueDev", function(msg) {
    if (msg >= 100){
        blue = msg;
    } else if (msg < 100){
    blue = format("%03d", msg);
    }
});

agent.on("TempAlarmDev", function(msg) {
  tempAlarm = msg;
  server.log(tempAlarm);
});

agent.on("FaderDev", function(msg) {
    if (msg >= 100){
        fader = msg;
    } else if (msg < 100){
    fader = format("%03d", msg);
    }
});

agent.on("HueDev", function(msg) {
  if (msg >= 100){
        hue = msg;
    } else if (msg < 100){
    hue = format("%03d", msg);
    }
});

agent.on("SatDev", function(msg) {
  if (msg >= 100){
        sat = msg;
    } else if (msg < 100){
    sat = format("%03d", msg);
    }
});

agent.on("BriDev", function(msg) {
  if (msg >= 100){
        bri = msg;
    } else if (msg < 100){
    bri = format("%03d", msg);
    }
});

agent.on("FuelDev", function(fuelMsg) {
  if (fuelMsg >= 1000){
        fuel = fuelMsg;
    } else if (fuelMsg < 1000){
    fuel = format("%04d", fuelMsg);
    }
});

agent.on("FuelDailyGoalDev", function(fuelDailyGoalMsg) {
 if (fuelDailyGoalMsg >= 1000){
        fuelDailyGoal = fuelDailyGoalMsg;
    } else if (fuelDailyGoalMsg < 1000){
    fuelDailyGoal = format("%04d", fuelDailyGoalMsg);
    }
    server.log(fuel);
    server.log(fuelDailyGoal);
});

agent.on("TemperatureDev", function(tempMsg) {
    if (tempMsg < 100 && tempMsg >= 10){
        temperature = format("0%0.1f",tempMsg);
    } else if (tempMsg < 10 && tempMsg >= 0){
        temperature = format("00%01.1f",tempMsg);
    } else if (tempMsg < 0 && tempMsg >= -10){
        temperature = format("%05.1f",tempMsg);
    } else if (tempMsg < -10){
        temperature = format("%02.1f",tempMsg);
    }
    server.log(temperature);
    //MoodCom();
});

agent.on("PHueXyDev", function(msg) {
    phColorX = msg[0].tofloat();
    phColorY = msg[1].tofloat();
    phColorX = format("%.4f",phColorX);
    phColorY = format("%.4f",phColorY);
   // v=math.floor(v*100)/100.0;
    //phColorX = format("%06d", msg[0]);
    //phColorY = format("%06d", msg[1]);
});

agent.on("PHueBriDev", function(msg) {
  if (msg >= 100){
        phBri = msg;
    } else if (msg < 100){
    phBri = format("%03d", msg);
    }
});

agent.on("PHueSyncDev", function(msg) {
    phSync = msg;
});

agent.on("MoodComTrigger", function(msg) {
    moodComBlocked = 1;
    MoodCom();
    moodComBlocked = 0;
    
});

function MoodCom()  //Here we built the communication protocol
{
    // String Length = 62 Chars;
    moodProt = ("ia" + red + green + blue + rgbHex + hue + sat + bri + fader + tempAlarm + fuel + fuelDailyGoal + temperature + phColorX + phColorY + phBri + phSync + "e" + "\n");
    //server.log(moodProt.len()); //show string.length
    if (moodProt.len() == 62){
    server.log (moodProt);
    server.show (moodProt);
    WriteSerial();
    fuel = format("%04d", 0);
    fuelDailyGoal= format("%04d", 0);
    } else{
        server.log("Error! IMP-Arduino Protocol has wrong length, must be 47 Characters including lf:");
        server.log(moodProt);
        server.log(moodProt.len())
        moodProt = 0;
    }
   moodProt = 0;
   if (moodComBlocked == 0){
       server.log("MoodCom Automatic Mode")
        imp.wakeup(5, MoodCom);
    }
}

function WriteSerial() {
    hardware.uart57.write(moodProt);
    readSerialBlocked = 1;
    ReadSerial();
    readSerialBlocked = 0;
  
}
 
function ReadSerial()
{    
     serialMessage = "";
        local byte = hardware.uart57.read();    
        while (byte != -1)
         {
           serialMessage+=byte.tochar();  
           byte = hardware.uart57.read(); 
              if (byte.tochar() == "\n")
             {   
                    stringComplete = 1;
                }
           }
      if (stringComplete == 1) // replace with whatever validation you are using
        {  
            //impeeOutput.set(s);
            server.show("From Arduino: " + serialMessage);
            server.log("From Arduino: " + serialMessage)
          if (serialMessage == "aiRETRYe\n"){
             server.log("Error in serial message, retry")
             MoodCom();
            }
            stringComplete = 0;
          }
         //serialMessage = "";
    if (readSerialBlocked == 0){
        imp.wakeup(0.2, ReadSerial);
    }
    serialMessage = "";
}

imp.configure("Moodlamp Controller", [], []);
InitUart();
ReadSerial();
MoodCom();

//DEVICE CODE END

