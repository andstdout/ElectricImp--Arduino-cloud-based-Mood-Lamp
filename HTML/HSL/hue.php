<?php 
$ElectricImpApiKey = "KEY"; //Your ElectricImp Api Key here!
 $ch = curl_init(); 
 
 curl_setopt($ch, CURLOPT_URL, "https://agent.electricimp.com/".$ElectricImpApiKey."/?readh"); 
 curl_setopt($ch, CURLOPT_HEADER, 0); 
 curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

 $hue = curl_exec($ch); 

 curl_close($ch); 
?> 
 
<html>
<head>
<style type="text/css">
#HueSlider {
padding-top:10px;
padding-bottom:10px;
margin-top:10px;
height: 10px;
background-image: -webkit-linear-gradient(left, 
#FF0000 0%,    
#FFFF00 17%,
#00FF00 33%,
#00FFFF 50%,
#0000FF 66%,
#FF00FF 83%,
#FF0000 100%);
}

#HueSlider input{  
	-webkit-appearance: none;  
    background-color: gray;
    width: 100%;  
    height: 0px;
	margin-top:5px;
   	margin-right: auto;
   	margin-left: auto;
    
}   
#HueSlider input::-webkit-slider-thumb {  
    -webkit-appearance: none;  
    background-color: transparent;
    opacity: 0.4;
    -webkit-border-radius: 10em;    width: 10; 
	border-width:12px;
  	border-style:solid;
  	border-color:black;
  	padding:0.3em;
    height: 10px;  
}   

</style>
</head>
<body>
<div id="HueSlider">
<input id="HVal" type="range"
 min="0" max="359" step="1" value="<?php echo $hue; ?>" onchange="updateHue(this.value)" />
</div>

<script type="text/javascript">

var ElectricImpApiKey = "<?php echo $ElectricImpApiKey; ?>";
var readhue = "<?php echo $hue; ?>";
var hueval = "<?php echo $hue; ?>"
var interval = setInterval(writeImp,130);

function updateHue(value){
    hueval = value;
};

function writeImp(){
    if (parseInt(hueval) != readhue){
        console.log("Writing hue value to IMP: " +hueval);
        var oReq = new XMLHttpRequest(); 
        oReq.open("GET", "https://agent.electricimp.com/"+ElectricImpApiKey+"/?hue="+hueval, true);  // synchronous request  
	    oReq.send();
	    readImp();
	}
};

function readImp(){
var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {  
        readhue = this.responseText;
        console.log("Reading hue value from IMP: "+readhue); 
        }  
        else {  
        //console.log("Failure");  
        }  
    }  
    xmlhttp.open("GET", "gethue.php", true);
	xmlhttp.send();
	return;
};

</script>
</body>
</html>
