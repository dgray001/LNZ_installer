class DImg {

  PImage img = null;
  int imgMode = CORNERS;
  int gridX = 1;
  int gridY = 1;

  // Constructor for blank image
  DImg(int x, int y) {
    this.img = createImage(x, y, ARGB);
  }
  DImg(PImage img) {
    this.img = img;
  }

  void mode(int imgMode) {
    switch(imgMode) {
      case CORNERS:
      case CORNER:
      case CENTER:
        this.imgMode = imgMode;
        break;
      default:
        print("ERROR: imgMode invalid");
        break;
    }
  }

  void setGrid(int x, int y) {
    if (x < 1 || y < 1) {
      return;
    }
    this.gridX = x;
    this.gridY = y;
  }

  int gridWidth() { // pixels / grid unit
    return round(this.img.width / this.gridX);
  }
  int gridHeight() {
    return round(this.img.height / this.gridY);
  }

  // Display functions
  void display(float x, float y) {
    imageMode(this.imgMode);
    image(this.img, x, y);
  }
  void display(float xi, float yi, float xf, float yf) {
    imageMode(this.imgMode);
    image(this.img, xi, yi, xf, yf);
  }

  // Return part of an image
  PImage getImageSection(PImage img, int x, int y, int w, int h) {
    return img.get(x, y, w, h);
  }

  // Add image to part of this using width / height
  synchronized void addImage(PImage newImg, int x, int y, int w, int h) {
    this.addImage(newImg, 0, 0, newImg.width, newImg.height, x, y, w, h);
  }
  synchronized void addImage(PImage newImg, int newImgX, int newImgY, int newImgW, int newImgH, int x, int y, int w, int h) {
    if (x < 0) {
      w += x;
      int scaled_dif = round(-x * float(newImg.width) / this.img.width);
      newImgX += scaled_dif;
      newImgW -= scaled_dif;
      x = 0;
    }
    if (y < 0) {
      h += y;
      int scaled_dif = round(-y * float(newImg.height) / this.img.height);
      newImgY += scaled_dif;
      newImgH -= scaled_dif;
      y = 0;
    }
    if (x + w > this.img.width) {
      int scaled_dif = round((x + w - this.img.width) * float(newImg.width) / w);
      w = this.img.width - x;
      newImgW -= scaled_dif;
    }
    if (y + h > this.img.height) {
      int scaled_dif = round((y + h - this.img.height) * float(newImg.height) / h);
      h = this.img.height - y;
      newImgH -= scaled_dif;
    }
    if (w < 1 || h < 1 || newImgW < 1 || newImgH < 1) {
      return;
    }
    // sometimes throws ArrayIndexOutOfBoundsException when passed bad data
    // shouldn't ever throw error though, could be rounding error or ??
    //println(newImg.width, newImg.height, newImgX, newImgY, newImgW, newImgH, this.img.width, this.img.height, x, y, w, h);
    this.img.blend(newImg, newImgX, newImgY, newImgW, newImgH, x, y, w, h, BLEND);
  }
  // Add image to part of this using percent of width / height
  void addImagePercent(PImage newImg, float xP, float yP, float wP, float hP) {
    if (xP < 0.0 || yP < 0.0 || wP < 0.0 || hP < 0.0 || xP > 1.0 || yP > 1.0 || wP > 1.0 || hP > 1.0) {
      global.log("DImg: addImagePercent coordinates out of range");
      return;
    }
    this.img.blend(newImg, 0, 0, newImg.width, newImg.height,
      round(this.img.width * xP), round(this.img.height * yP),
      round(this.img.width * wP), round(this.img.height * hP), BLEND);
  }
  // Add image to grid squares
  void addImageGrid(PImage newImg, int x, int y) {
    this.addImageGrid(newImg, x, y, 1, 1);
  }
  void addImageGrid(PImage newImg, int x, int y, int w, int h) {
    this.addImageGrid(newImg, 0, 0, newImg.width, newImg.height, x, y, w, h);
  }
  void addImageGrid(PImage newImg, int newImgX, int newImgY, int newImgW, int newImgH, int x, int y, int w, int h) {
    this.addImage(newImg, newImgX, newImgY, newImgW, newImgH,
      round(this.img.width * (float(x) / this.gridX)),
      round(this.img.height * (float(y) / this.gridY)),
      round(w * (float(this.img.width) / this.gridX)),
      round(h * (float(this.img.height) / this.gridY)));
  }

  // make grid a specific color
  void colorGrid(color c, int x, int y) {
    this.colorGrid(c, x, y, 1, 1);
  }
  void colorGrid(color c, int x, int y, int w, int h) {
    this.img.loadPixels();
    for (int i = 0; i < h * this.img.height / this.gridY; i++) {
      for (int j = 0; j < w * this.img.width / this.gridX; j++) {
        int index = (y * this.img.height / this.gridY + i) * this.img.width +
          (x * this.img.width / this.gridX + j);
        try {
          this.img.pixels[index] = c;
        } catch(IndexOutOfBoundsException e) {}
      }
    }
    this.img.updatePixels();
  }

  // my own copy function which accounts for transparency
  void copyImage(PImage newImg, float x, float y, float w, float h) {
    this.img.loadPixels();
    float scaling_width = newImg.width / w;
    float scaling_height = newImg.height / h;
    for (int i = 0; i < h; i++) {
      int imgY = int(scaling_height * i + 0.5);
      for (int j = 0; j < w; j++) {
        int imgX = int(scaling_width * j + 0.5);

        int index = int((i + y) * this.img.width + (j + x));
        int img_index = imgY * newImg.width + imgX;
        try {
          float r_source = newImg.pixels[img_index] >> 16 & 0xFF;
          float g_source = newImg.pixels[img_index] >> 8 & 0xFF;
          float b_source = newImg.pixels[img_index] & 0xFF;
          float a_source = alpha(newImg.pixels[img_index]);
          float r_target = this.img.pixels[index] >> 16 & 0xFF;
          float g_target = this.img.pixels[index] >> 8 & 0xFF;
          float b_target = this.img.pixels[index] & 0xFF;
          float a_target = alpha(this.img.pixels[index]);

          float factor_source = a_source / 255.0;
          float factor_target = (1 - factor_source) * a_target / 255.0;
          float r_final = constrain(factor_source * r_source + factor_target * r_target, 0, 255);
          float g_final = constrain(factor_source * g_source + factor_target * g_target, 0, 255);
          float b_final = constrain(factor_source * b_source + factor_target * b_target, 0, 255);
          float a_final = constrain(a_source + a_target, 0, 255);

          this.img.pixels[index] = ccolor(r_final, g_final, b_final, a_final);
        } catch(IndexOutOfBoundsException e) {}
      }
    }
    this.img.updatePixels();
  }

  // image piece
  PImage getImagePiece(int xi, int yi, int w, int h) {
    if (xi < 0) {
      w += xi;
      xi = 0;
    }
    if (yi < 0) {
      h += yi;
      yi = 0;
    }
    if (xi + w > this.img.width) {
      w = this.img.width - xi;
    }
    if (yi + h > this.img.height) {
      h = this.img.height - yi;
    }
    if (w <= 0 || h <= 0) {
      return createImage(1, 1, ARGB);
    }
    PImage return_image = createImage(w, h, ARGB);
    return_image.loadPixels();
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w; j++) {
        int index = (yi + i) * this.img.width + (xi + j);
        if (index < 0 || index >= this.img.pixels.length) {
          continue;
        }
        int return_index = i * w + j;
        return_image.pixels[return_index] = this.img.pixels[index];
      }
    }
    return_image.updatePixels();
    return return_image;
  }
  PImage getImageGridPiece(int x, int y) {
    return this.getImageGridPiece(x, y, 1, 1);
  }
  PImage getImageGridPiece(int x, int y, int w, int h) {
    if (x < 0 || y < 0 || x >= this.gridX || y >= this.gridY) {
      global.log("DImg: getImageGridPiece coordinate out of range");
      return createImage(1, 1, RGB);
    }
    if (w < 1 || h < 1 || x + w > this.gridX || y + h > this.gridY) {
      global.log("DImg: getImageGridPiece coordinate out of range");
      return createImage(1, 1, RGB);
    }
    return this.getImagePiece(x * this.img.width / this.gridX, y * this.img.height / this.gridY,
      w * this.img.width / this.gridX, h * this.img.height / this.gridY);
  }

  // convolution
  void convolution(float[][] matrix) {
    if (matrix.length % 2 != 1 || matrix[0].length % 2 != 1) {
      global.log("DImg: convolution matrix invalid size.");
      return;
    }
    this.img.loadPixels();
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        int index = i * this.img.width + j;
        float r_total = 0;
        float g_total = 0;
        float b_total = 0;
        for (int i_offset = 0; i_offset < matrix[0].length; i_offset++) {
          for (int j_offset = 0; j_offset < matrix.length; j_offset++) {
            int i_corrected = constrain(i + i_offset - matrix[0].length / 2, 0, this.img.height);
            int j_corrected = constrain(j + j_offset - matrix.length / 2, 0, this.img.width);
            int index_offset = constrain(i_corrected * this.img.width + j_corrected, 0, this.img.pixels.length - 1);
            float factor = matrix[i_offset][j_offset];
            r_total += factor * (this.img.pixels[index_offset] >> 16 & 0xFF);
            g_total += factor * (this.img.pixels[index_offset] >> 8 & 0xFF);
            b_total += factor * (this.img.pixels[index_offset] & 0xFF);
          }
        }
        r_total = constrain(r_total, 0, 255);
        g_total = constrain(g_total, 0, 255);
        b_total = constrain(b_total, 0, 255);
        this.img.pixels[index] = color(r_total, g_total, b_total);
      }
    }
    this.img.updatePixels();
  }
  void blur() {
    this.convolution(new float[][]{{1.0/9, 1.0/9, 1.0/9}, {1.0/9, 1.0/9, 1.0/9}, {1.0/9, 1.0/9, 1.0/9}});
  }
  void sharpen() {
    this.convolution(new float[][]{{-1, -1, -1}, {-1, 9, -1}, {-1, -1, -1}});
  }

  // Brighten
  void brighten(float factor) {
    this.img.loadPixels();
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        int index = i * this.img.width + j;
        if (index == 0) {
          continue;
        }
        color c = this.img.pixels[index];
        float r = constrain((c >> 16 & 0xFF) * factor, 0, 255);
        float g = constrain((c >> 8 & 0xFF) * factor, 0, 255);
        float b = constrain((c & 0xFF) * factor, 0, 255);
        float a = alpha(c);
        this.img.pixels[index] = color(r, g, b, a);
      }
    }
    this.img.updatePixels();
  }

  void brightenGradient(float factor, float gradientDistance, float x, float y) {
    this.img.loadPixels();
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        int index = i * this.img.width + j;
        float distance = sqrt((i - y) * (i - y) + (j - x) * (j - x));
        float curr_factor = factor;
        if (distance < gradientDistance) {
          curr_factor = 1 + (factor - 1) * distance / gradientDistance;
        }
        color c = this.img.pixels[index];
        float r = constrain((c >> 16 & 0xFF) * curr_factor, 0, 255);
        float g = constrain((c >> 8 & 0xFF) * curr_factor, 0, 255);
        float b = constrain((c & 0xFF) * curr_factor, 0, 255);
        int col = ccolor(round(r), round(g), round(b), 255);
        this.img.pixels[index] = col;
      }
    }
    this.img.updatePixels();
  }

  // transparent
  void makeTransparent() {
    this.makeTransparent(1);
  }
  void makeTransparent(int alpha) {
    this.img.loadPixels();
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        int index = i * this.img.width + j;
        if (index == 0) {
          continue;
        }
        float r = this.img.pixels[index] >> 16 & 0xFF;
        float g = this.img.pixels[index] >> 8 & 0xFF;
        float b = this.img.pixels[index] & 0xFF;
        this.img.pixels[index] = ccolor(round(r), round(g), round(b), alpha);
      }
    }
    this.img.updatePixels();
  }
  void transparencyGradientFromPoint(float x, float y, float distance) {
    this.img.loadPixels();
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        int index = i * this.img.width + j;
        if (index == 0) {
          continue;
        }
        float r = this.img.pixels[index] >> 16 & 0xFF;
        float g = this.img.pixels[index] >> 8 & 0xFF;
        float b = this.img.pixels[index] & 0xFF;
        float curr_distance = sqrt((i - y) * (i - y) + (j - x) * (j - x));
        float alpha = 255;
        if (curr_distance < distance) {
          alpha = 255 * curr_distance / distance;
        }
        this.img.pixels[index] = ccolor(r, g, b, alpha);
      }
    }
    this.img.updatePixels();
  }

  // color pixels
  void colorPixels(color c) {
    this.img.loadPixels();
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        int index = i * this.img.width + j;
        this.img.pixels[index] = c;
      }
    }
    this.img.updatePixels();
  }

  void colorPixel(int x, int y, color c) {
    this.img.loadPixels();
    int index = x + y * this.img.width;
    if (index < 1 || index >= this.img.pixels.length) {
      return;
    }
    this.img.pixels[index] = c;
    this.img.updatePixels();
  }
}


PImage createPImage(color c, int w, int h) {
  DImg dimg = new DImg(w, h);
  dimg.colorPixels(c);
  return dimg.img;
}


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


// resize image using nearest-neighbor interpolation
PImage resizeImage(PImage img, int w, int h) {
  if (w <= 0 || h <= 0) {
    return createImage(1, 1, ARGB);
  }
  float scaling_width = img.width / float(w);
  float scaling_height = img.height / float(h);
  PImage return_image = createImage(w, h, ARGB);
  return_image.loadPixels();
  for (int i = 0; i < h; i++) {
    int imgY = round(floor(scaling_height * i + 0.5));
    for (int j = 0; j < w; j++) {
      int imgX = round(floor(scaling_width * j + 0.5)); // must floor to avoid artifacts
      int index = i * w + j;
      int img_index = imgY * img.width + imgX;
      try {
        return_image.pixels[index] = img.pixels[img_index];
      } catch(Exception e) {}
    }
  }
  return_image.updatePixels();
  return return_image;
}
