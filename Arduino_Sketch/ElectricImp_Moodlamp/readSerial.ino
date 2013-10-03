//reading data from electric imp shield
void readSerial() {
  int i = 0;
  while (impSerial.available()) {
    char inChar = (char)impSerial.read(); 
    // add incoming bytes to the inputString:
    inputString += inChar;
    i++;
    // if the incoming character is a newline, set a flag and break serial reading
    if (inChar == '\n' || i == 62) {
      checkComplete(); //checks if a consistent string was received
      i = 0;
      break;
    } 
  }
}
void checkComplete(){ //check if the string begins with "ia" and ends with "e"
  printDln("Check incoming data:");
  if (inputString.charAt(0) == 'i' && 
    inputString.charAt(1) == 'a' &&
    inputString.charAt(60) == 'e' && 
    inputString.length() == 62){
    printDln("InputString OK");
    printDln(inputString);
    inputStringComplete = true;
    impSerial.write("aiOKe\n"); //send OK message to imp
  } 
  else {
    inputStringComplete = false;
    printDln("InputString not OK, ERROR!");
    impSerial.write("aiRETRYe\n"); //Send an error string to IMP, let imp retry to send the last string
    printDln(inputString);
    inputString = args[0];
  }
}



