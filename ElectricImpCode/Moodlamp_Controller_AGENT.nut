server.log("ElectricImp agent started on "+http.agenturl());
//CUSTOM Vars:
webserver <- "https://YourWebServerUrlHere.com/"; //Your Webserver URL, where the .php scripts for NikeFuel/ Weather/ Philips Hue are lying
webserverAuth <- "BASE64 KEY" //Your .htaccess authorization key, have a look here: http://www.base64decode.org
weathercity <- "New York"; //Your location for http://openweathermap.org
//------------------------------------------
hueA <- 0; //hue agent variable
briA <- 0; //brightness
satA <- 0; //saturation
redA <- 0; //RGB red
greenA <- 0; //RGB green
blueA <- 0; //RGB blue
tempAlarmA <- 1 //set temperature alarm
faderA <- 0; //currently not used
local fuel; //fuel points from Nike.com
local fuelDailyGoal; //fuel goal
local temperature; //current temperature from openweathermap.org
local condition; //condition from openweathermap.org
local phColor; //Philips hue color variable
phBrightness <- ""; //Philips hue brightness
pHueABulb <- 1; //Set PhilipsHue default to bulb no. 1
pHueASync <- "0"; //Boolean variable; sync Philips Hue with moodlamp? 
pHueASyncBusy <- 0; //Helper variable

http.onrequest(function(request, response) { //read incoming data from agent.electricimp.com/yourapikey/*
    local q = request.query;
   // server.log(q);
    if ("red" in q) {
        device.send("RedDev", q.red.tointeger());
        redA = q.red;
        response.send(200, redA);
    }
    if ("green" in q) {
        device.send("GreenDev", q.green.tointeger());
        greenA = q.green;
        response.send(200, greenA);
    }
    if ("blue" in q) {device.send("BlueDev", q.blue.tointeger());
        blueA = q.blue;
        response.send(200, blueA);
    }
    if ("tempalarm" in q) {device.send("TempAlarmDev", q.tempalarm.tointeger());
        tempAlarmA = q.tempalarm;
        response.send(200, tempAlarmA);
    }
    if ("fader" in q) {device.send("FaderDev", q.fader.tointeger());
        faderA = q.fader;
        response.send(200, faderA);
    }
    if ("hue" in q) {device.send("HueDev", q.hue.tointeger());
        hueA = q.hue;
        //server.log(hueA)
        response.send(200, hueA);
    }
    
    if ("sat" in q) {device.send("SatDev", q.sat.tointeger());
        satA = q.sat;
        //server.log(satA)
        response.send(200, satA);
    }
    
    if ("bri" in q) {device.send("BriDev", q.bri.tointeger());
        briA = q.bri;
        //server.log(briA)
        response.send(200, briA);
    }
    
    if ("getfuel" in q){
        getFuel();
        device.send("FuelDev", fuel);
        device.send("FuelDailyGoalDev", fuelDailyGoal);
        response.send(200, "Nike Fuel earned: "+fuel + "/"+fuelDailyGoal);
        server.log("Nike Fuel earned: "+fuel + "/"+fuelDailyGoal);
    }
     if ("getweather" in q){
        getWeather();
        response.send(200, "Current temperature: "+temperature +"C, " + condition);
        server.log("Current temperature: "+temperature +"C, " + condition);
    }
    if ("setphuebulb" in q){
        pHueABulb = q.setphuebulb;
        local name = getPhilipsHueColor(pHueABulb);
        server.log(name);
        response.send(200,"Moodlamp is in sync with Philips Hue Bulb: "+pHueABulb + ", " + name);
        server.log("Moodlamp is in sync with Philips Hue Bulb: "+pHueABulb + ", " + name);
    }
    if ("setphsync" in q){
        pHueASync = q.setphsync;
        response.send(200,pHueASync);
        if (pHueASync == "1"){
            server.log("PhilipsHue sync active!");
        };
        device.send("PHueSyncDev", pHueASync.tointeger());
    }
        
    //Send response (For NetIO to set ui- elements)
    if ("readr" in q) {response.send(200, redA);}
    if ("readg" in q) {response.send(200, greenA);}
    if ("readb" in q) {response.send(200, blueA);}
    if ("readt" in q) {response.send(200, tempAlarmA);}
    if ("readf" in q) {response.send(200, faderA);}
    if ("readh" in q) {response.send(200, hueA);}
    if ("reads" in q) {response.send(200, satA);}
    if ("readbr" in q) {response.send(200, briA);}
    if ("readphsync" in q) {response.send(200, pHueASync);}
    if ("readphbulb" in q) {local name = getPhilipsHueColor(pHueABulb);response.send(200, pHueABulb + ", " + name);}
     device.send("MoodComTrigger" , 1); //Trigger device function "MoodComTrigger"
});

//Functions:
// ------------------------------------------------------------------------------------------

function getFuel(){ //get the actual nike fuel points from getFuel.php
    //imp.wakeup(5, getFuel);
local httpgetfuel = http.get(webserver + "HSL/Fuelband/getFuel.php",
        {
        "Content-Type": "text/xml",
        "Authorization": "Basic" + webserverAuth      
        }).sendsync();
    local nikedata = http.jsondecode(httpgetfuel.body);
    fuel = nikedata.progress;
    fuelDailyGoal = nikedata.targetValue;
}

function getPhilipsHueColor(bulb){
    pHueASyncBusy = 1;
    local httpgetcolor = http.get((webserver + "HSL/phue.php/getcolor/"+bulb), 
        {
        "Content-Type": "text/xml" //,
        "Authorization": "Basic" + webserverAuth        
        }).sendsync();
    local currentcolor = http.jsondecode(httpgetcolor.body);
    phColor = currentcolor.state.xy;
    local phState = currentcolor.state.on;
    local phReachable = currentcolor.state.reachable;
    phBrightness = currentcolor.state.bri;
    if (phState == false || phReachable == false){
        phBrightness = "0";
    }
    pHueASyncBusy = 0;
    return (currentcolor.name);
}

function getPhilipsHueBulbName(){ //How many lightbulbs we have and collect names
    local httpgetbulbs = http.get(webserver + "HSL/phue.php/getbulbs",
        {
        "Content-Type": "text/xml" //,
        "Authorization": "Basic" + webserverAuth       
        }).sendsync();
    local bulbs = (httpgetbulbs.body);
    local phBulbs = bulbs.tointeger();  
    server.log(phBulbs);
    for (local i = 1; i <phBulbs + 1;i++){
        local phuename = getPhilipsHueColor(i);
        server.log(phuename);
        return phuename
    }
}

function getWeather(){
    if (tempAlarmA == 1){
    local httpgetweather = http.get("http://api.openweathermap.org/data/2.5/weather?q="+ weathercity +"&mode=json&units=metric",
        {
        "Content-Type": "text/xml"       
        }).sendsync();
    local weatherdata = http.jsondecode(httpgetweather.body);
    temperature = weatherdata.main.temp;
    //condition = weatherdata.condition;
    condition = weatherdata.weather[0].description;
    server.log("Temperature alarm is on!")
    server.log("Current temperature: "+ temperature + "C");
    server.log("Current condition: "+condition);
    device.send("TemperatureDev", temperature);
    imp.wakeup(10, getWeather);
    }
}

function pHueSync(){
    imp.wakeup(3, pHueSync);
    if (pHueASyncBusy == 0 && pHueASync == "1"){
        getPhilipsHueColor(pHueABulb);
        device.send("PHueXyDev", phColor);
        device.send("PHueBriDev", phBrightness.tointeger());
        device.send("MoodComTrigger" , 1); //Trigger function MoodComTrigger
    };
};
pHueSync();
getWeather();
