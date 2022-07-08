class Images {
  private HashMap<String, PImage> imgs = new HashMap<String, PImage>();
  private String basePath = sketchPath("data/images/");
  private boolean loaded_map_gifs = false;

  Images() {}

  PImage getImage(String filePath) {
    if (this.imgs.containsKey(filePath)) {
      return this.imgs.get(filePath);
    }
    else {
      this.loadImageFile(filePath);
      return this.imgs.get(filePath);
    }
  }

  PGraphics getImageAsGraphic(String filePath) {
    PImage img = this.getImage(filePath);
    PGraphics graphic = createGraphics(img.width, img.height);
    graphic.beginDraw();
    graphic.image(img, 0, 0);
    graphic.endDraw();
    return graphic;
  }

  void loadImageFiles(String ... filePaths) {
    for (String filePath : filePaths) {
      this.loadImageFile(filePath);
    }
  }
  void loadImageFile(String filePath) {
    PImage img = loadImage(this.basePath + filePath);
    if (img == null) {
      global.log("Images: Missing image " + filePath + ".");
      this.imgs.put(filePath, this.getBlackPixel());
    }
    else {
      this.imgs.put(filePath, img);
    }
  }

  PImage getBlackPixel() {
    PImage img = new PImage(1, 1, RGB);
    img.loadPixels();
    img.pixels[0] = color(0);
    img.updatePixels();
    return img;
  }

  PImage getTransparentPixel() {
    PImage img = new PImage(1, 1, ARGB);
    img.loadPixels();
    img.pixels[0] = color(255, 0);
    img.updatePixels();
    return img;
  }

  PImage getRandomPixel() {
    PImage img = new PImage(1, 1, ARGB);
    img.loadPixels();
    img.pixels[0] = color(round(random(255)), round(random(255)), round(random(255)));
    img.updatePixels();
    return img;
  }

  PImage getColoredPixel(color c) {
    PImage img = new PImage(1, 1, ARGB);
    img.loadPixels();
    img.pixels[0] = c;
    img.updatePixels();
    return img;
  }
}



PImage getCurrImage() {
  PImage img = createImage(width, height, ARGB);
  img.loadPixels();
  loadPixels();
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      int index = i + j * width;
      img.pixels[index] = pixels[index];
    }
  }
  img.updatePixels();
  return img;
}

PImage getCurrImage(int xi, int yi, int xf, int yf) {
  PImage img = createImage(xf - xi, yf - yi, ARGB);
  img.loadPixels();
  loadPixels();
  for (int i = xi; i <= xf; i++) {
    for (int j = yi; j <= yf; j++) {
      int index = i + j * width;
      if (index < 0 || index >= pixels.length) {
        continue;
      }
      int img_index = (i - xi) + (j - yi) * img.width;
      if (img_index >= img.pixels.length) {
        continue;
      }
      img.pixels[img_index] = pixels[index];
    }
  }
  img.updatePixels();
  return img;
}
