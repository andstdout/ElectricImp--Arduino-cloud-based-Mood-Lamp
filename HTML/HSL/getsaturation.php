<?php 
 $ElectricImpApiKey = "KEY"; //Your ElectricImp Api Key here!
 $ch = curl_init(); 

 // setze die URL und andere Optionen 
 curl_setopt($ch, CURLOPT_URL, "https://agent.electricimp.com/".$ElectricImpApiKey."/?reads"); 
 curl_setopt($ch, CURLOPT_HEADER, 0); 
 curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

 $sat = curl_exec($ch); 
 
 curl_close($ch); 
echo $sat;
?> 