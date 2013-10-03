<?php 
//$hue= $_GET["hue"];
 $ElectricImpApiKey = "KEY"; //Your ElectricImp Api Key here!
 $ch = curl_init(); 

 // setze die URL und andere Optionen 
 curl_setopt($ch, CURLOPT_URL, "https://agent.electricimp.com/".$ElectricImpApiKey."/?readbr"); //ElectricImp Api Key
 curl_setopt($ch, CURLOPT_HEADER, 0); 
 curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

 $bri = curl_exec($ch); 
 
 curl_close($ch); 
?> 
 
<html>
<head>
<style type="text/css">
#BriSlider {
padding-top:10px;
padding-bottom:10px;
margin-top:10px;
height: 10px;
background-image: -webkit-linear-gradient(left, 
#000000 0%,
#FFFFFF 100%);
margin-top:10px;
}

#BriSlider input{  
	-webkit-appearance: none;  
    background-color: gray;
    width: 100%;  
    height: 0px;
	margin-top:5px;
   	margin-right: auto;
   	margin-left: auto;
    
}   
#BriSlider input::-webkit-slider-thumb {  
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
<div id="BriSlider"; >
<input id="VVal" type="range"
 min="0" max="255" step="1" value="<?php echo $bri; ?>" onchange="updateBrightness(this.value)" />
</div>
<script type="text/javascript">

var ElectricImpApiKey = "<?php echo $ElectricImpApiKey; ?>";
var readbri = "<?php echo $bri; ?>";
var brival = "<?php echo $bri; ?>"
var interval = setInterval(writeImp,130);

function updateBrightness(value){
    brival = value;
};

function writeImp(){
    if (parseInt(brival) != readbri){
        console.log("Writing hue value to IMP: " +brival);
        var oReq = new XMLHttpRequest(); 
        oReq.open("GET", "https://agent.electricimp.com/"+ElectricImpApiKey+"/?bri="+brival, true);  // synchronous request  
	    oReq.send();
	    readImp();
	}
};

function readImp(){
var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {  
        readbri = this.responseText;
        console.log("Reading hue value from IMP: "+readbri); 
        }  
        else {  
        //console.log("Failure");  
        }  
    }  
    xmlhttp.open("GET", "getbrightness.php", true);
	xmlhttp.send();
	return;
};

</script>
</body>
</html>
