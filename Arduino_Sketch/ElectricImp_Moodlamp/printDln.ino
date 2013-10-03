//Debugging function with new line print
void printDln (String debugMessage)
{
  if (debugLocal) Serial.println(debugMessage);
  if (debugImp) impSerial.println(debugMessage);
  debugMessage = "";
}
