<?php 
 $ElectricImpApiKey = "KEY"; //Your ElectricImp Api Key here!
 $ch = curl_init(); 

 curl_setopt($ch, CURLOPT_URL, "https://agent.electricimp.com/".$ElectricImpApiKey."/?readh"); 
 curl_setopt($ch, CURLOPT_HEADER, 0); 
 curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

 $hue = curl_exec($ch); 

 curl_close($ch); 
echo $hue;
?> 