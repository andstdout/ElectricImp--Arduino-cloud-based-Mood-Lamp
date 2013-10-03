//Debugging function without new line print
void printD (String debugMessage)
{
  if (debugLocal) Serial.print(debugMessage);
  if (debugImp) impSerial.print(debugMessage);
  debugMessage = "";
}
