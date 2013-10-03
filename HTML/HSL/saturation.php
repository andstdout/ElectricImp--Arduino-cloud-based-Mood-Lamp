<?php 
 $ch = curl_init(); 
 $ElectricImpApiKey = "KEY"; //Your ElectricImp Api Key here!
 curl_setopt($ch, CURLOPT_URL, "https://agent.electricimp.com/".$ElectricImpApiKey."/?reads"); 
 curl_setopt($ch, CURLOPT_HEADER, 0); 
 curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

 $sat = curl_exec($ch); 

 curl_close($ch); 
?> 
 
<html>
<head>
<style type="text/css">
#SatSlider {
padding-top:10px;
padding-bottom:10px;
margin-top:10px;
height: 10px;
background-image: url(saturation.png);
-webkit-background-size: 100% 100%;
}

#SatSlider input{  
	-webkit-appearance: none;  
    background-color: gray;
    width: 100%;  
    height: 0px;
	margin-top:5px;
   	margin-right: auto;
   	margin-left: auto;
    
}   
#SatSlider input::-webkit-slider-thumb {  
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
<div id="SatSlider"; >
<input id="SVal" type="range"
 min="0" max="255" step="1" value="<?php echo $sat; ?>" onchange="updateSaturation(this.value)" />
</div>
<script type="text/javascript">
console.log("start");

var ElectricImpApiKey = "<?php echo $ElectricImpApiKey; ?>";
var readsat = "<?php echo $sat; ?>";
var satval = "<?php echo $sat; ?>"
var interval = setInterval(writeImp,130);

function updateSaturation(value){
    satval = value;
};

function writeImp(){
    if (parseInt(satval) != readsat){
        console.log("Writing saturation value to IMP: " +satval);
        var oReq = new XMLHttpRequest(); 
        oReq.open("GET", "https://agent.electricimp.com/"+ElectricImpApiKey+"/?sat="+satval, true);  // synchronous request  
	    oReq.send();
	    readImp();
	}
};

function readImp(){
var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {  
        readsat = this.responseText;
        console.log("Reading saturation value from IMP: "+readsat); 
        }  
        else {  
        //console.log("Failure");  
        }  
    }  
    xmlhttp.open("GET", "getsaturation.php", true);
	xmlhttp.send();
	return;
};

</script>
</body>
</html>
