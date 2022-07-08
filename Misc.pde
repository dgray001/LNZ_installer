// String to primitive casts
boolean isInt(String str) {
  try {
    int i = Integer.parseInt(str);
    return true;
  } catch(NumberFormatException e) {
    return false;
  }
}
int toInt(String str) {
  int i = -1;
  try {
    i = Integer.parseInt(str);
  } catch(NumberFormatException e) {}
  return i;
}

boolean isFloat(String str) {
  try {
    float i = Float.parseFloat(str);
    return true;
  } catch(NumberFormatException e) {
    return false;
  }
}
float toFloat(String str) {
  float i = -1;
  try {
    i = Float.parseFloat(str);
  } catch(NumberFormatException e) {}
  return i;
}

boolean isBoolean(String str) {
  if (str.equals(Boolean.toString(true)) || str.equals(Boolean.toString(false))) {
    return true;
  }
  else {
    return false;
  }
}
boolean toBoolean(String str) {
  if (str.equals(Boolean.toString(true))) {
    return true;
  }
  else {
    return false;
  }
}


// color functions
color brighten(color c) {
  return adjust_color_brightness(c, 1.05);
}
color darken(color c) {
  return adjust_color_brightness(c, 0.95);
}
color adjust_color_brightness(color c, float factor) {
  float r = constrain(factor * (c >> 16 & 0xFF), 0, 255);
  float g = constrain(factor * (c >> 8 & 0xFF), 0, 255);
  float b = constrain(factor * (c & 0xFF), 0, 255);
  return ccolor(r, g, b, alpha(c));
}
