int ccolor(int gray) {
  return ccolor(gray, gray, gray, 255);
}
int ccolor(int gray, int a) {
  return ccolor(gray, gray, gray, a);
}
int ccolor(int r, int g, int b) {
  return ccolor(r, g, b, 255);
}
int ccolor(float r, float g, float b, float a) {
  return ccolor(round(r), round(g), round(b), round(a));
}
int ccolor(int r, int g, int b, int a) {
  return (a << 24) | (r << 16) | (g << 8) | b;
}
