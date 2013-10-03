//Device Code
local rgbHex = format("%07d", 0); //RGB HEX
local red = format("%03d", 0); //RGB red
local green = format("%03d", 0); //RGB green
local blue = format("%03d", 0); //RGB blue
local tempAlarm = 1; //temperature alarm
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
debugMessage <- 0 //true/false 1,0;
showMemory <- 1 //true/false 1,0;
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

function MoodCom()  //Here we built the communication protocol
{
    // String Length = 62 Chars;
    moodProt = ("ia" + red + green + blue + rgbHex + hue + sat + bri + fader + tempAlarm + fuel + fuelDailyGoal + temperature + phColorX + phColorY + phBri + phSync + "e" + "\n");
    //server.log(moodProt.len()); //show string.length
    if (moodProt.len() == 62){
    if (debugMessage == 1){ server.log("Moodcom Message: " + moodProt)};
    WriteSerial();
    fuel = format("%04d", 0);
    fuelDailyGoal= format("%04d", 0);
    } else{
        if (debugMessage == 1){ server.log("Error! IMP-Arduino Protocol has wrong length, must be 47 Characters including lf:")};
        if (debugMessage == 1){ server.log(moodProt)};
        if (debugMessage == 1){ server.log(moodProt.len())};
        moodProt = 0;
    }
   moodProt = 0;
   imp.wakeup(0.1, MoodCom);
}

function WriteSerial() {
    hardware.uart57.write(moodProt);
    if (debugMessage == 1){ ReadSerial()}; 
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
                    server.log ("Serial Message from Arduino: " + serialMessage);
                    serialMessage = "";
                }
           }
}
function MemoryConsumption(){
if (showMemory == 1){
    local freemem = imp.getmemoryfree();
    server.log("Device Moodlamp Controller: free memory: "+freemem);
    imp.wakeup(2,MemoryConsumption);
}
}

imp.configure("Moodlamp Controller", [], []);
InitUart();
//ReadSerial();
MoodCom();
MemoryConsumption();

//DEVICE CODE END

