//conversion from Philips HUE XYZ to RGB see <https://github.com/PhilipsHue/PhilipsHueSDKiOS/blob/master/ApplicationDesignNotes/RGB%20to%20xy%20Color%20conversion.md>
void xyBriToRgb(float xval, float yval, float brival) {
  boolean throwflag = false;
  brival = brival/255;
  if(0 > xval || xval > 0.8) {
    throwflag = true; //x property must be between 0 and .8, but isn't
  }
  if(0 > yval || yval > 1) {
    throwflag = true;
  }
  if(0 > brival || brival > 1) {
    throwflag = true;
  }
  if (throwflag == false){
    float x = xval;
    float y = yval;
    float z = 1.0 - x - y;
    float Y = brival;
    float X = (Y / y) * x;
    float Z = (Y / y) * z;
    float r = X * 1.612 - Y * 0.203 - Z * 0.302;
    float g = -X * 0.509 + Y * 1.412 + Z * 0.066;
    float b = X * 0.026 - Y * 0.072 + Z * 0.962;
    //gamma correction, we don't need it: 
    //r = r <= 0.0031308 ? 12.92 * r : (1.0 + 0.055) * pow(r, (1.0 / 2.4)) - 0.055; 
    //g = g <= 0.0031308 ? 12.92 * g : (1.0 + 0.055) * pow(g, (1.0 / 2.4)) - 0.055;
    //b = b <= 0.0031308 ? 12.92 * b : (1.0 + 0.055) * pow(b, (1.0 / 2.4)) - 0.055;

    r = getcap(r)*255;
    g = getcap(g)*255;
    b = getcap(b)*255;
    int red = r;
    int green = g;
    int blue = b;
    setLedColor(red,green,blue);
  };
}
//strip down all values greater than 1 to 1
float getcap(float x){
  return max(0, min(1, x));
};

