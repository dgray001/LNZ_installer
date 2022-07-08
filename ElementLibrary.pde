abstract class Button {
  // state
  protected boolean hidden = false;
  protected boolean disabled = false;
  protected boolean hovered = false;
  protected boolean clicked = false;
  protected boolean button_focused = false;
  // colors
  protected color color_disabled = ccolor(220, 180);
  protected color color_default = ccolor(220);
  protected color color_hover = ccolor(170);
  protected color color_click = ccolor(120);
  protected color color_text = ccolor(0);
  protected color color_stroke = ccolor(0);
  protected color color_focused = ccolor(170, 180);
  // config
  protected String message = "";
  protected boolean show_message = false;
  protected float text_size = 14;
  protected boolean show_stroke = true;
  protected float stroke_weight = 0.5;
  protected boolean stay_dehovered = false;
  protected boolean adjust_for_text_descent = false;
  protected boolean hover_check_after_release = true;
  protected boolean use_time_elapsed = false;
  protected boolean force_left_button = true;
  // timer
  protected int hold_timer = 0;
  protected int lastUpdateTime = millis();

  Button() {
  }

  void disable() {
    this.disabled = true;
    this.hovered = false;
    this.clicked = false;
    this.button_focused = false;
  }

  void setColors(color c_dis, color c_def, color c_hov, color c_cli, color c_tex) {
    this.color_disabled = c_dis;
    this.color_default = c_def;
    this.color_hover = c_hov;
    this.color_click = c_cli;
    this.color_text = c_tex;
  }

  void setStroke(color c_str, float stroke_weight) {
    this.color_stroke = c_str;
    this.stroke_weight = stroke_weight;
    this.show_stroke = true;
  }
  void noStroke() {
    this.show_stroke = false;
  }

  color fillColor() {
    if (this.disabled) {
      return this.color_disabled;
    }
    else if (this.clicked) {
      return this.color_click;
    }
    else if (this.hovered) {
      return this.color_hover;
    }
    else {
      return this.color_default;
    }
  }

  void setFill() {
    fill(this.fillColor());
    stroke(this.color_stroke);
    if (this.show_stroke) {
      if (this.button_focused) {
        strokeWeight(2 * this.stroke_weight);
      }
      else {
        strokeWeight(this.stroke_weight);
      }
    }
    else {
      if (this.button_focused) {
        strokeWeight(0.8 * this.stroke_weight);
      }
      else {
        strokeWeight(0.0001);
        noStroke();
      }
    }
  }

  void writeText() {
    if (!this.show_message) {
      return;
    }
    fill(this.color_text);
    textAlign(CENTER, CENTER);
    textSize(this.text_size);
    if (this.adjust_for_text_descent) {
      text(this.message, this.xCenter(), this.yCenter() - textDescent());
    }
    else {
      text(this.message, this.xCenter(), this.yCenter());
    }
  }


  void stayDehovered() {
    this.stay_dehovered = true;
    this.hovered = false;
  }

  void update(int millis) {
    if (!this.hidden) {
      drawButton();
      if (this.clicked) {
        if (this.use_time_elapsed) {
          this.hold_timer += millis;
        }
        else {
          this.hold_timer += millis - this.lastUpdateTime;
        }
      }
    }
    if (!this.use_time_elapsed) {
      this.lastUpdateTime = millis;
    }
  }

  void mouseMove(float mX, float mY) {
    if (this.disabled) {
      return;
    }
    boolean prev_hover = this.hovered;
    this.hovered = this.mouseOn(mX, mY);
    if (this.stay_dehovered) {
      if (this.hovered) {
        this.hovered = false;
      }
      else {
        this.stay_dehovered = false;
      }
    }
    if (prev_hover && !this.hovered) {
      this.dehover();
    }
    else if (!prev_hover && this.hovered) {
      this.hover();
    }
  }

  void mousePress() {
    if (this.disabled) {
      return;
    }
    if (this.force_left_button && mouseButton != LEFT) {
      return;
    }
    if (this.hovered) {
      this.clicked = true;
      this.click();
    }
    else {
      this.clicked = false;
    }
  }

  void mouseRelease(float mX, float mY) {
    if (this.disabled) {
      return;
    }
    if (this.force_left_button && mouseButton != LEFT) {
      return;
    }
    if (this.clicked) {
      this.clicked = false;
      this.hold_timer = 0;
      this.release();
    }
    this.clicked = false;
    if (this.hover_check_after_release) {
      this.mouseMove(mX, mY);
    }
  }

  void keyPress() {
    if (key == CODED) {
    }
    else {
      switch(key) {
        case RETURN:
        case ENTER:
          if (this.button_focused) {
            this.clicked = true;
            this.click();
          }
          break;
      }
    }
  }

  void keyRelease() {
    if (key == CODED) {
    }
    else {
      switch(key) {
        case RETURN:
        case ENTER:
          if (this.button_focused) {
            if (this.clicked) {
              this.clicked = false;
              this.hold_timer = 0;
              this.release();
            }
          }
          break;
      }
    }
  }

  abstract float xCenter();
  abstract float yCenter();
  abstract float button_width();
  abstract float button_height();
  abstract void drawButton();
  abstract void moveButton(float xMove, float yMove);
  abstract boolean mouseOn(float mX, float mY);
  abstract void hover();
  abstract void dehover();
  abstract void click();
  abstract void release();
}



abstract class RectangleButton extends Button {
  protected float xi;
  protected float yi;
  protected float xf;
  protected float yf;
  protected int roundness = 8;
  protected float xCenter;
  protected float yCenter;
  protected boolean raised_border = false;
  protected boolean raised_body = false;
  protected boolean shadow = false;
  protected float shadow_amount = 5;

  RectangleButton(float xi, float yi, float xf, float yf) {
    super();
    this.setLocation(xi, yi, xf, yf);
  }

  float xCenter() {
    return this.xCenter;
  }

  float yCenter() {
    return this.yCenter;
  }

  float button_width() {
    return this.xf - this.xi;
  }

  float button_height() {
    return this.yf - this.yi;
  }

  void drawButton() {
    rectMode(CORNERS);
    if (this.shadow) {
      fill(ccolor(0, 180));
      rect(this.xi + this.shadow_amount, this.yi + this.shadow_amount,
        this.xf + this.shadow_amount, this.yf + this.shadow_amount, this.roundness);
    }
    this.setFill();
    if (this.shadow && this.clicked && !this.disabled) {
      translate(this.shadow_amount, this.shadow_amount);
    }
    if (this.raised_body && !this.disabled) {
      fill(ccolor(255, 0));
      rect(this.xi, this.yi, this.xf, this.yf, this.roundness);
      stroke(ccolor(255, 0));
      if (this.clicked) {
        fill(darken(this.fillColor()));
        rect(this.xi, this.yi, this.xf, this.yCenter());
        fill(brighten(this.fillColor()));
        rect(this.xi, this.yCenter(), this.xf, this.yf);
      }
      else {
        fill(brighten(this.fillColor()));
        rect(this.xi, this.yi, this.xf, this.yCenter(), this.roundness);
        fill(darken(this.fillColor()));
        rect(this.xi, this.yCenter(), this.xf, this.yf, this.roundness);
      }
    }
    else {
      rect(this.xi, this.yi, this.xf, this.yf, this.roundness);
    }
    this.writeText();
    if (this.shadow && this.clicked && !this.disabled) {
      translate(-this.shadow_amount, -this.shadow_amount);
    }
    if (this.raised_border && !this.disabled) {
      strokeWeight(1);
      if (this.clicked) {
        stroke(ccolor(0));
        line(this.xi, this.yi, this.xf, this.yi);
        line(this.xi, this.yi, this.xi, this.yf);
        stroke(ccolor(255));
        line(this.xf, this.yf, this.xf, this.yi);
        line(this.xf, this.yf, this.xi, this.yf);
      }
      else {
        stroke(ccolor(255));
        line(this.xi, this.yi, this.xf, this.yi);
        line(this.xi, this.yi, this.xi, this.yf);
        stroke(ccolor(0));
        line(this.xf, this.yf, this.xf, this.yi);
        line(this.xf, this.yf, this.xi, this.yf);
      }
    }
    if (this.button_focused) {
      noFill();
      strokeWeight(this.stroke_weight);
      stroke(this.color_stroke);
      rect(this.xi + 0.1 * this.button_width(), this.yi + 0.1 * this.button_height(),
        this.xf - 0.1 * this.button_width(), this.yf - 0.1 * this.button_height(), this.roundness);
    }
  }

  void setLocation(float xi, float yi, float xf, float yf) {
    this.xi = xi;
    this.yi = yi;
    this.xf = xf;
    this.yf = yf;
    this.xCenter = this.xi + 0.5 * (this.xf - this.xi);
    this.yCenter = this.yi + 0.5 * (this.yf - this.yi);
  }
  void setXLocation(float xi, float xf) {
    this.setLocation(xi, this.yi, xf, this.yf);
  }
  void setYLocation(float yi, float yf) {
    this.setLocation(this.xi, yi, this.xf, yf);
  }

  void moveButton(float xMove, float yMove) {
    this.xi += xMove;
    this.yi += yMove;
    this.xf += xMove;
    this.yf += yMove;
    this.xCenter = this.xi + 0.5 * (this.xf - this.xi);
    this.yCenter = this.yi + 0.5 * (this.yf - this.yi);
  }

  void stretchButton(float amount, int direction) {
    switch(direction) {
      case UP:
        this.setLocation(this.xi, this.yi - amount, this.xf, this.yf);
        break;
      case DOWN:
        this.setLocation(this.xi, this.yi, this.xf, this.yf + amount);
        break;
      case LEFT:
        this.setLocation(this.xi - amount, this.yi, this.xf, this.yf);
        break;
      case RIGHT:
        this.setLocation(this.xi, this.yi, this.xf + amount, this.yf);
        break;
      default:
        break;
    }
  }

  boolean mouseOn(float mX, float mY) {
    if (mX >= this.xi && mY >= this.yi &&
      mX <= this.xf && mY <= this.yf) {
      return true;
    }
    return false;
  }
}


abstract class CheckBox extends RectangleButton {
  protected boolean checked = false;
  protected color color_check = ccolor(0);
  protected float offset = 0;

  CheckBox(float xi, float yi, float size) {
    this(xi, yi, xi + size, xi + size);
  }
  CheckBox(float xi, float yi, float xf, float yf) {
    super(xi, yi, xf, yf);
    this.setColors(color(170, 170), ccolor(170, 0), ccolor(170, 50), ccolor(170, 120), ccolor(0));
    this.roundness = 0;
    this.stroke_weight = 2;
  }

  @Override
  void setLocation(float xi, float yi, float xf, float yf) {
    super.setLocation(xi, yi, xf, yf);
    this.offset = 0.1 * (xf  - xi);
  }

  @Override
  void drawButton() {
    super.drawButton();
    if (this.checked) {
      strokeWeight(this.stroke_weight);
      stroke(this.color_stroke);
      line(this.xi + offset, this.yi + offset, this.xf - offset, this.yf - offset);
      line(this.xi + offset, this.yf - offset, this.xf - offset, this.yi + offset);
    }
  }

  void click() {
    this.checked = !this.checked;
  }
}


abstract class ImageButton extends RectangleButton {
  protected PImage img;
  protected color color_tint = ccolor(255);
  protected boolean overshadow_colors = false;

  ImageButton(PImage img, float xi, float yi, float xf, float yf) {
    super(xi, yi, xf, yf);
    this.img = img;
  }

  @Override
  void drawButton() {
    tint(this.color_tint);
    imageMode(CORNERS);
    image(this.img, this.xi, this.yi, this.xf, this.yf);
    noTint();
    this.writeText();
    if (this.overshadow_colors) {
      fill(this.fillColor());
      stroke(this.fillColor());
      rectMode(CORNERS);
      rect(this.xi, this.yi, this.xf, this.yf);
    }
  }

  void setImg(PImage img) {
    this.img = img;
    this.img.resize(int(this.button_width()), int(this.button_height()));
  }
}


abstract class ToggleButton extends ImageButton {
  protected int toggle_index = 0;
  protected boolean click_toggle = true;
  protected PImage[] images;

  ToggleButton(PImage[] images, float xi, float yi, float xf, float yf) {
    super(images[0], xi, yi, xf, yf);
    this.images = images;
  }

  void setToggle(int toggle_index) {
    this.toggle_index = toggle_index;
    if (this.toggle_index < 0) {
      this.toggle_index = 0;
    }
    if (this.toggle_index >= this.images.length) {
      this.toggle_index = this.images.length - 1;
    }
  }

  void toggle() {
    this.toggle_index++;
    if (this.toggle_index >= this.images.length) {
      this.toggle_index = 0;
    }
    this.setImg(this.images[this.toggle_index]);
  }

  void click() {
    if (this.click_toggle) {
      this.toggle();
    }
  }

  void release() {
    if (!this.hovered || this.click_toggle) {
      return;
    }
    this.toggle();
  }
}


abstract class RippleRectangleButton extends ImageButton {
  class Pixel {
    private int x;
    private int y;
    private float x_pixel;
    private float y_pixel;
    Pixel(int x, int y, float x_pixel, float y_pixel) {
      this.x = x;
      this.y = y;
      this.x_pixel = x_pixel;
      this.y_pixel = y_pixel;
    }
    float distance(float mX, float mY) {
      return sqrt((mX - this.x_pixel) * (mX - this.x_pixel) +
        (mY - this.y_pixel) * (mY - this.y_pixel));
    }
  }

  protected int rippleTime = 250;
  protected int rippleTimer = 0;
  protected int number_buckets = 50;
  protected HashMap<Integer, ArrayList<Pixel>> buckets;
  protected float last_mX = 0;
  protected float last_mY = 0;
  protected float clickX = 0;
  protected float clickY = 0;
  protected float maxRippleDistance;

  RippleRectangleButton(float xi, float yi, float xf, float yf) {
    super(createImage(int(xf - xi), int(yf - yi), ARGB), xi, yi, xf, yf);
    this.refreshColor();
    this.maxRippleDistance = max(this.button_width(), this.button_height());
  }

  @Override
  void setLocation(float xi, float yi, float xf, float yf) {
    super.setLocation(xi, yi, xf, yf);
    this.maxRippleDistance = max(this.button_width(), this.button_height());
    if (this.button_width() > 0 && this.button_height() > 0) {
      this.setImg(createImage(int(xf - xi), int(yf - yi), ARGB));
      this.refreshColor();
    }
  }

  @Override
  void update(int millis) {
    int timeElapsed = millis - this.lastUpdateTime;
    if (this.use_time_elapsed) {
      timeElapsed = millis;
    }
    super.update(millis);
    if (this.rippleTimer > 0) {
      this.rippleTimer -= timeElapsed;
      if (this.rippleTimer <= 0) {
        this.refreshColor();
      }
      else {
        this.colorPixels();
      }
    }
  }

  void refreshColor() {
    DImg dimg = new DImg(this.img);
    dimg.colorPixels(this.fillColor());
    this.img = dimg.img;
    this.rippleTimer = 0;
  }

  void initializeRipple() {
    this.buckets = new HashMap<Integer, ArrayList<Pixel>>();
    for (int i = 0; i < this.number_buckets; i++) {
      this.buckets.put(i, new ArrayList<Pixel>());
    }
    float keyMultiplier = float(this.rippleTime) / this.number_buckets;
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        float x = this.xi + this.button_width() * j / this.img.width;
        float y = this.yi + this.button_height() * i / this.img.height;
        Pixel p = new Pixel(j, i, x, y);
        float distance = p.distance(this.clickX, this.clickY);
        int timer = int(floor(this.rippleTime * (1 - distance / this.maxRippleDistance) / keyMultiplier));
        if (this.buckets.containsKey(timer)) {
          this.buckets.get(timer).add(p);
        }
      }
    }
    this.rippleTimer = this.rippleTime;
  }

  void colorPixels() {
    DImg dimg = new DImg(this.img);
    float currDistance = this.maxRippleDistance * (this.rippleTime - this.rippleTimer) / this.rippleTime;
    float keyMultiplier = float(this.rippleTime) / this.number_buckets;
    for (Map.Entry<Integer, ArrayList<Pixel>> entry : this.buckets.entrySet()) {
      if (entry.getKey() * keyMultiplier > this.rippleTimer) {
        for (Pixel p : entry.getValue()) {
          dimg.colorPixel(p.x, p.y, this.color_click);
        }
        entry.getValue().clear();
      }
    }
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.last_mX = mX;
    this.last_mY = mY;
    super.mouseMove(mX, mY);
  }

  void hover() {
    this.refreshColor();
  }

  void dehover() {
    this.refreshColor();
  }

  void click() {
    this.clickX = this.last_mX;
    this.clickY = this.last_mY;
    this.initializeRipple();
  }

  void release() {
    this.refreshColor();
  }
}


abstract class IconButton extends RippleRectangleButton {
  protected color background_color = ccolor(255);
  protected PImage icon;
  protected float icon_width = 0;

  IconButton(float xi, float yi, float xf, float yf, PImage icon) {
    super(xi, yi, xf, yf);
    this.icon = icon;
    this.icon_width = yf - yi;
  }

  @Override
  void setLocation(float xi, float yi, float xf, float yf) {
    super.setLocation(xi, yi, xf, yf);
    this.icon_width = yf - yi;
  }

  @Override
  void update(int millis) {
    rectMode(CORNERS);
    if (this.show_stroke) {
      stroke(this.color_stroke);
      strokeWeight(this.stroke_weight);
    }
    else {
      noStroke();
    }
    fill(this.background_color);
    rect(this.xi, this.yi, this.xf, this.yf);
    imageMode(CORNER);
    image(this.icon, this.xi, this.yi, this.icon_width, this.icon_width);
    super.update(millis);
  }

  @Override
  void writeText() {
    if (this.show_message) {
      fill(this.color_text);
      textAlign(LEFT, CENTER);
      textSize(this.text_size);
      if (this.adjust_for_text_descent) {
        text(this.message, this.xi + this.icon_width + 1, this.yCenter() - textDescent());
      }
      else {
        text(this.message, this.xi + this.icon_width + 1, this.yCenter());
      }
    }
  }
}


abstract class IconInverseButton extends IconButton {
  IconInverseButton(float xi, float yi, float xf, float yf, PImage icon) {
    super(xi, yi, xf, yf, icon);
  }

  @Override
  void update(int millis) {
    super.update(millis);
    imageMode(CORNER);
    image(this.icon, this.xi, this.yi, this.icon_width, this.icon_width);
    if (this.disabled) {
      rectMode(CORNERS);
      if (this.show_stroke) {
        stroke(this.color_stroke);
        strokeWeight(this.stroke_weight);
      }
      else {
        noStroke();
      }
      fill(this.background_color);
      rect(this.xi, this.yi, this.xf, this.yf);
    }
  }
}


abstract class RippleCircleButton extends RippleRectangleButton {
  private ArrayList<Pixel> transparentPixels = new ArrayList<Pixel>();

  RippleCircleButton(float xc, float yc, float r) {
    super(xc - r, yc - r, xc + r, yc + r);
    this.findTransparentPixels();
    this.refreshColor();
  }

  @Override
  void setLocation(float xi, float yi, float xf, float yf) {
    super.setLocation(xi, yi, xf, yf);
    this.findTransparentPixels();
  }

  void findTransparentPixels() {
    this.transparentPixels = new ArrayList<Pixel>();
    float r = 0.5 * (this.xf - this.xi);
    for (int i = 0; i < this.img.height; i++) {
      for (int j = 0; j < this.img.width; j++) {
        float distance = sqrt((r - i) * (r - i) + (r - j) * (r - j));
        if (distance > r) {
          this.transparentPixels.add(new Pixel(j, i, 0, 0));
        }
      }
    }
  }

  void colorTransparentPixels() {
    if (this.transparentPixels == null) {
      return;
    }
    this.img.loadPixels();
    for (Pixel p : this.transparentPixels) {
      int index = p.x + p.y * this.img.width;
      try {
        this.img.pixels[index] = ccolor(1, 0);
      } catch(ArrayIndexOutOfBoundsException e) {}
    }
    this.img.updatePixels();
  }

  @Override
  void refreshColor() {
    super.refreshColor();
    this.colorTransparentPixels();
  }

  @Override
  void colorPixels() {
    super.colorPixels();
    this.colorTransparentPixels();
  }
}




abstract class EllipseButton extends Button {
  protected float xc;
  protected float yc;
  protected float xr;
  protected float yr;

  EllipseButton(float xc, float yc, float xr, float yr) {
    super();
    this.xc = xc;
    this.yc = yc;
    this.xr = xr;
    this.yr = yr;
  }

  float xCenter() {
    return this.xc;
  }

  float yCenter() {
    return this.yc;
  }

  float button_width() {
    return 2 * this.xr;
  }

  float button_height() {
    return 2 * this.yr;
  }

  void drawButton() {
    this.setFill();
    ellipseMode(RADIUS);
    ellipse(this.xc, this.yc, this.xr, this.yr);
    this.writeText();
    if (this.button_focused) {
      noFill();
      strokeWeight(this.stroke_weight);
      stroke(this.color_stroke);
      ellipse(this.xc + 0.1 * this.xr, this.yc + 0.1 * this.yr,
        this.xr - 0.1 * this.xr, this.yr - 0.1 * this.yr);
    }
  }

  void setLocation(float xc, float yc, float xr, float yr) {
    this.xc = xc;
    this.yc = yc;
    this.xr = xr;
    this.yr = yr;
  }

  void moveButton(float xMove, float yMove) {
    this.xc += xMove;
    this.yc += yMove;
  }

  boolean mouseOn(float mX, float mY) {
    if (this.xr == 0 || this.yr == 0) {
      return false;
    }
    float xRatio = (mX - this.xc) / this.xr;
    float yRatio = (mY - this.yc) / this.yr;
    if (xRatio * xRatio + yRatio * yRatio <= 1) {
      return true;
    }
    return false;
  }
}



abstract class CircleButton extends EllipseButton {
  CircleButton(float xc, float yc, float r) {
    super(xc, yc, r, r);
  }
  float radius() {
    return this.xr;
  }

  void setLocation(float xc, float yc, float radius) {
    super.setLocation(xc, yc, radius, radius);
  }
}



abstract class RadioButton extends CircleButton {
  protected boolean checked = false;
  protected color color_active = ccolor(0);

  RadioButton(float xc, float yc, float r) {
    super(xc, yc, r);
    this.setColors(color(170, 120), ccolor(170, 0), ccolor(170, 40), ccolor(170, 80), ccolor(0));
  }

  @Override
  void drawButton() {
    super.drawButton();
    if (this.checked) {
      fill(this.color_active);
      ellipseMode(RADIUS);
      circle(this.xCenter(), this.yCenter(), 0.6 * this.radius());
    }
    if (this.clicked) {
      fill(this.color_active, 135);
      ellipseMode(RADIUS);
      circle(this.xCenter(), this.yCenter(), 1.4 * this.radius());
    }
  }

  void click() {
    this.checked = !this.checked;
  }
}




abstract class TriangleButton extends Button {
  protected float x1;
  protected float y1;
  protected float x2;
  protected float y2;
  protected float x3;
  protected float y3;
  protected float dotvv;
  protected float dotuu;
  protected float dotvu;
  protected float constant;
  protected float xCenter;
  protected float yCenter;

  TriangleButton(float x1, float y1, float x2, float y2, float x3, float y3) {
    super();
    this.setLocation(x1, y1, x2, y2, x3, y3);
  }

  void setLocation(float x1, float y1, float x2, float y2, float x3, float y3) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.x3 = x3;
    this.y3 = y3;
    this.dotvv = (x3 - x1) * (x3 - x1) + (y3 - y1) * (y3 - y1);
    this.dotuu = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
    this.dotvu = (x3 - x1) * (x2 - x1) + (y3 - y1) * (y2 - y1);
    this.constant = this.dotvv * this.dotuu - this.dotvu * this.dotvu;
    this.xCenter = (x1 + x2 + x3) / 3.0;
    this.yCenter = (y1 + y2 + y3) / 3.0;
  }

  float xCenter() {
    return this.xCenter;
  }

  float yCenter() {
    return this.yCenter;
  }

  float button_width() {
    return max(this.x1, this.x2, this.x3) - min(this.x1, this.x2, this.x3);
  }

  float button_height() {
    return max(this.y1, this.y2, this.y3) - min(this.y1, this.y2, this.y3);
  }

  void drawButton() {
    this.setFill();
    triangle(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);
    this.writeText();
  }

  void moveButton(float xMove, float yMove) {
    this.x1 += xMove;
    this.y1 += yMove;
    this.x2 += xMove;
    this.y2 += yMove;
    this.x3 += xMove;
    this.y3 += yMove;
  }

  boolean mouseOn(float mX, float mY) {
    float dotvp = (this.x3 - this.x1) * (mX - this.x1) + (this.y3 - this.y1) * (mY - this.y1);
    float dotup = (this.x2 - this.y1) * (mX - this.x1) + (this.y2 - this.y1) * (mY - this.y1);
    if (this.constant == 0) {
      return false;
    }
    float t1 = (this.dotuu * dotvp - this.dotvu * dotup) / this.constant;
    float t2 = (this.dotvv * dotup - this.dotvu * dotvp) / this.constant;
    if (t1 >= 0 && t2 >= 0 && t1 + t2 < 1) {
      return true;
    }
    return false;
  }
}




abstract class ArcButton extends Button {
  class TestButton extends TriangleButton {
    TestButton(float x1, float y1, float x2, float y2, float x3, float y3) {
      super(x1, y1, x2, y2, x3, y3);
    }
    void hover() {}
    void dehover() {}
    void click() {}
    void release() {}
  }

  protected float xc;
  protected float yc;
  protected float xr;
  protected float yr;
  protected float start;
  protected float stop;
  protected boolean pie = true; // false for open arc
  protected float xStart;
  protected float xStop;
  protected float yStart;
  protected float yStop;

  ArcButton(float xc, float yc, float xr, float yr, float start, float stop) {
    super();
    this.setLocation(xc, yc, xr, yr, start, stop);
  }

  void setLocation(float xc, float yc, float xr, float yr, float start, float stop) {
    this.xc = xc;
    this.yc = yc;
    this.xr = xr;
    this.yr = yr;
    this.start = start;
    this.stop = stop;
    // fix angles if not in range [0, TWO_PI]
    this.xStart = cos(this.start);
    this.xStop = cos(this.stop);
    this.yStart = sin(this.start);
    this.yStop = sin(this.stop);
  }

  float xCenter() {
    return this.xc;
  }

  float yCenter() {
    return this.yc;
  }

  float button_width() {
    return 2 * this.xr;
  }

  float button_height() {
    return 2 * this.yr;
  }

  void drawButton() {
    this.setFill();
    ellipseMode(RADIUS);
    if (this.pie) {
      arc(this.xc, this.yc, this.xr, this.yr, this.start, this.stop, PIE);
    }
    else {
      arc(this.xc, this.yc, this.xr, this.yr, this.start, this.stop, CHORD);
    }
    this.writeText();
  }

  void moveButton(float xMove, float yMove) {
    this.xc += xMove;
    this.yc += yMove;
  }

  boolean mouseOn(float mX, float mY) {
    if (this.xr == 0 || this.yr == 0) {
      return false;
    }
    // in ellipse
    float xRatio = (mX - this.xc) / this.xr;
    float yRatio = (mY - this.yc) / this.yr;
    float hypotenuse = xRatio * xRatio + yRatio * yRatio;
    if (hypotenuse > 1) {
      return false;
    }
    hypotenuse = sqrt(hypotenuse);
    // in arc
    float angle = asin(yRatio / hypotenuse);
    if (xRatio < 0) { // Q2 or Q3
      angle = PI - angle;
    }
    else if (yRatio < 0) { // Q4
      angle += TWO_PI;
    }
    if (angle > this.start && angle < this.stop) {
      if (this.pie) {
        return true;
      }
      else {
        TestButton excludedArea = new TestButton(0, 0, this.xStart, this.yStart, this.xStop, this.yStop);
        if (!excludedArea.mouseOn(xRatio, yRatio)) {
          return true;
        }
      }
    }
    return false;
  }
}




// shaped like the 'Find Match' button in League
abstract class LeagueButton extends ArcButton {
  protected float trapezoid_height;
  protected float trapezoid_shift;
  protected float trapezoid_xi;
  protected float trapezoid_xf;
  protected float trapezoid_bottom;
  protected PVector[] vertices = new PVector[4]; // trapezoid vertices

  LeagueButton(float xBottom, float yBottom, float xRadius, float yRadius, float radians, float trapezoid_height, float trapezoid_shift) {
    super(xBottom, yBottom - yRadius, xRadius, yRadius, HALF_PI - 0.5 * radians, HALF_PI + 0.5 * radians);
    this.pie = false;
    this.trapezoid_height = trapezoid_height;
    this.trapezoid_shift = trapezoid_shift;
    this.trapezoid_xi = xStop * this.xr + this.xc;
    this.trapezoid_xf = xStart * this.xr + this.xc;
    this.trapezoid_bottom = yStop * this.yr + this.yc;
    this.vertices[0] = new PVector(this.trapezoid_xi, this.trapezoid_bottom);
    this.vertices[1] = new PVector(this.trapezoid_xi + this.trapezoid_shift, this.trapezoid_bottom - this.trapezoid_height);
    this.vertices[2] = new PVector(this.trapezoid_xf - this.trapezoid_shift, this.trapezoid_bottom - this.trapezoid_height);
    this.vertices[3] = new PVector(this.trapezoid_xf, this.trapezoid_bottom);
  }

  @Override
  void drawButton() {
    this.setFill();
    ellipseMode(RADIUS);
    arc(this.xc, this.yc, this.xr, this.yr, this.start, this.stop, OPEN);
    beginShape();
    for (PVector p : this.vertices) {
      vertex(p.x, p.y);
    }
    endShape();
    stroke(this.fillColor());
    strokeWeight(1);
    line(this.trapezoid_xi+2, this.trapezoid_bottom-1, this.trapezoid_xf-2, this.trapezoid_bottom-1);
    if (this.show_message) {
      fill(this.color_text);
      textSize(this.text_size);
      textAlign(CENTER, BOTTOM);
      text(this.message, this.xc, this.trapezoid_bottom);
    }
  }

  boolean mouseOn(float mX, float mY) {
    boolean collision = false;
    for (int i = 0; i < this.vertices.length; i++) {
      PVector p1 = this.vertices[i];
      PVector p2;
      if (i + 1 == this.vertices.length) {
        p2 = this.vertices[0];
      }
      else {
        p2 = this.vertices[i + 1];
      }
      if ( ((p1.y > mY) != (p2.y > mY)) && (mX < (p2.x - p1.x) * (mY - p1.y) / (p2.y - p1.y) + p1.x) ) {
        collision = !collision;
      }
    }
    if (collision) {
      return true;
    }
    if (super.mouseOn(mX, mY)) {
      return true;
    }
    return false;
  }
}






class ScrollBar {
  abstract class ScrollBarButton extends RectangleButton {
    protected int time_hold = 350;
    protected int time_click = 80;
    protected boolean held = false;

    ScrollBarButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      this.roundness = 0;
      this.raised_border = true;
    }

    @Override
    void update(int millis) {
      super.update(millis);
      if (this.clicked) {
        if (this.held) {
          if (this.hold_timer > this.time_click) {
            this.hold_timer -= this.time_click;
            this.click();
          }
        }
        else {
          if (this.hold_timer > this.time_hold) {
            this.hold_timer -= this.time_hold;
            this.held = true;
            this.click();
          }
        }
      }
    }

    void hover() {
    }
    void dehover() {
    }
    void release() {
      this.held = false;
    }
  }

  class ScrollBarUpButton extends ScrollBarButton {
    float arrowWidth = 0;
    float arrowRatio = 0.1;
    float cushionRatio = 1.5;
    ScrollBarUpButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      refreshArrowWidth();
      this.raised_border = true;
    }
    @Override
    void setLocation(float xi, float yi, float xf, float yf) {
      super.setLocation(xi, yi, xf, yf);
      this.refreshArrowWidth();
    }
    void refreshArrowWidth() {
      if (ScrollBar.this.vertical) {
        this.arrowWidth = this.arrowRatio * this.button_height();
      }
      else {
        this.arrowWidth = this.arrowRatio * this.button_width();
      }
    }
    @Override
    void drawButton() {
      super.drawButton();
      stroke(ccolor(0));
      strokeWeight(this.arrowWidth);
      if (ScrollBar.this.vertical) {
        line(this.xi + this.cushionRatio * this.arrowWidth, this.yf - this.cushionRatio * this.arrowWidth,
          this.xCenter(), this.yi + this.cushionRatio * this.arrowWidth);
        line(this.xf - this.cushionRatio * this.arrowWidth, this.yf - this.cushionRatio * this.arrowWidth,
          this.xCenter(), this.yi + this.cushionRatio * this.arrowWidth);
      }
      else {
        line(this.xf - this.cushionRatio * this.arrowWidth, this.yi + this.cushionRatio * this.arrowWidth,
          this.xi + this.cushionRatio * this.arrowWidth, this.yCenter());
        line(this.xf - this.cushionRatio * this.arrowWidth, this.yf - this.cushionRatio * this.arrowWidth,
          this.xi + this.cushionRatio * this.arrowWidth, this.yCenter());
      }
    }
    @Override
    void dehover() {
      this.clicked = false;
    }
    void click() {
      ScrollBar.this.decreaseValue(1);
    }
  }

  class ScrollBarDownButton extends ScrollBarButton {
    float arrowWidth = 0;
    float arrowRatio = 0.1;
    float cushionRatio = 1.5;
    ScrollBarDownButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      refreshArrowWidth();
      this.raised_border = true;
    }
    @Override
    void setLocation(float xi, float yi, float xf, float yf) {
      super.setLocation(xi, yi, xf, yf);
      this.refreshArrowWidth();
    }
    void refreshArrowWidth() {
      if (ScrollBar.this.vertical) {
        this.arrowWidth = this.arrowRatio * this.button_height();
      }
      else {
        this.arrowWidth = this.arrowRatio * this.button_width();
      }
    }
    @Override
    void drawButton() {
      super.drawButton();
      stroke(ccolor(0));
      strokeWeight(this.arrowWidth);
      if (ScrollBar.this.vertical) {
        line(this.xi + this.cushionRatio * this.arrowWidth, this.yi + this.cushionRatio * this.arrowWidth,
          this.xCenter(), this.yf - this.cushionRatio * this.arrowWidth);
        line(this.xf - this.cushionRatio * this.arrowWidth, this.yi + this.cushionRatio * this.arrowWidth,
          this.xCenter(), this.yf - this.cushionRatio * this.arrowWidth);
      }
      else {
        line(this.xi + this.cushionRatio * this.arrowWidth, this.yi + this.cushionRatio * this.arrowWidth,
          this.xf - this.cushionRatio * this.arrowWidth, this.yCenter());
        line(this.xi + this.cushionRatio * this.arrowWidth, this.yf - this.cushionRatio * this.arrowWidth,
          this.xf - this.cushionRatio * this.arrowWidth, this.yCenter());
      }
    }
    @Override
    void dehover() {
      this.clicked = false;
    }
    void click() {
      ScrollBar.this.increaseValue(1);
    }
  }

  class ScrollBarUpSpaceButton extends ScrollBarButton {
    ScrollBarUpSpaceButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      this.setColors(color(180), ccolor(235), ccolor(235), ccolor(0), ccolor(0));
      this.raised_border = false;
    }
    void click() {
      ScrollBar.this.decreaseValuePercent(0.1);
    }
    @Override
    void release() {
      super.release();
      this.hovered = false;
    }
  }

  class ScrollBarDownSpaceButton extends ScrollBarButton {
    ScrollBarDownSpaceButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      this.setColors(color(180), ccolor(235), ccolor(235), ccolor(0), ccolor(0));
      this.raised_border = false;
    }
    void click() {
      ScrollBar.this.increaseValuePercent(0.1);
    }
    @Override
    void release() {
      super.release();
      this.hovered = false;
    }
  }

  class ScrollBarBarButton extends ScrollBarButton {
    protected float val = 0;
    protected float last_val = 0;
    ScrollBarBarButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
    }
    @Override
    void update(int millis) {
      if (!this.hidden) {
        drawButton();
      }
      if (this.clicked && ScrollBar.this.value_size != 0) {
        this.hold_timer += millis - this.lastUpdateTime;
      }
      this.lastUpdateTime = millis;
    }
    @Override
    void mouseMove(float mX, float mY) {
      super.mouseMove(mX, mY);
      if (ScrollBar.this.vertical) {
        this.last_val = mY;
      }
      else {
        this.last_val = mX;
      }
      if (this.clicked && ScrollBar.this.value_size != 0) {
        if (ScrollBar.this.vertical) {
          ScrollBar.this.increaseValue((mY - this.yi - this.val) / ScrollBar.this.value_size);
        }
        else {
          ScrollBar.this.increaseValue((mX - this.xi - this.val) / ScrollBar.this.value_size);
        }
      }
    }
    void click() {
      if (ScrollBar.this.vertical) {
        this.val = this.last_val - this.yi;
      }
      else {
        this.val = this.last_val - this.xi;
      }
    }
  }

  protected ScrollBarUpButton button_up = new ScrollBarUpButton(0, 0, 0, 0);
  protected ScrollBarDownButton button_down = new ScrollBarDownButton(0, 0, 0, 0);
  protected ScrollBarUpSpaceButton button_upspace = new ScrollBarUpSpaceButton(0, 0, 0, 0);
  protected ScrollBarDownSpaceButton button_downspace = new ScrollBarDownSpaceButton(0, 0, 0, 0);
  protected ScrollBarBarButton button_bar = new ScrollBarBarButton(0, 0, 0, 0);

  protected float minValue = 0;
  protected float maxValue = 0;
  protected float value = 0;

  protected float xi;
  protected float yi;
  protected float xf;
  protected float yf;
  protected boolean vertical;
  protected float bar_size = 0;
  protected float min_size = 0;
  protected float value_size = 0;
  protected float step_size = 10; // constant

  ScrollBar(boolean vertical) {
    this(0, 0, 0, 0, vertical);
  }
  ScrollBar(float xi, float yi, float xf, float yf, boolean vertical) {
    this.vertical = vertical;
    this.setLocation(xi, yi, xf, yf);
  }

  void setButtonColors(color c_dis, color c_def, color c_hov, color c_cli, color c_tex) {
    this.button_up.setColors(c_dis, c_def, c_hov, c_cli, c_tex);
    this.button_down.setColors(c_dis, c_def, c_hov, c_cli, c_tex);
    this.button_bar.setColors(c_dis, c_def, c_hov, c_cli, c_tex);
  }

  void useElapsedTime() {
    this.button_up.use_time_elapsed = true;
    this.button_down.use_time_elapsed = true;
    this.button_upspace.use_time_elapsed = true;
    this.button_downspace.use_time_elapsed = true;
    this.button_bar.use_time_elapsed = true;
  }

  void move(float xMove, float yMove) {
    this.xi += xMove;
    this.yi += yMove;
    this.xf += xMove;
    this.yf += yMove;
    this.button_up.moveButton(xMove, yMove);
    this.button_down.moveButton(xMove, yMove);
    this.button_upspace.moveButton(xMove, yMove);
    this.button_downspace.moveButton(xMove, yMove);
    this.button_bar.moveButton(xMove, yMove);
  }

  void setLocation(float xi, float yi, float xf, float yf) {
    this.xi = xi;
    this.yi = yi;
    this.xf = xf;
    this.yf = yf;
    if (this.vertical) {
      this.bar_size = this.xf - this.xi;
      if (3 * this.bar_size > this.yf - this.yi) {
        this.bar_size = (this.yf - this.yi) / 3.0;
        this.min_size = 0.5 * this.bar_size;
      }
      else {
        this.min_size = min(this.bar_size, (this.yf - this.yi) / 9.0);
      }
      this.button_up.setLocation(this.xi, this.yi, this.xf, this.yi + this.bar_size);
      this.button_down.setLocation(this.xi, this.yf - this.bar_size, this.xf, this.yf);
    }
    else {
      this.bar_size = this.yf - this.yi;
      if (3 * this.bar_size > this.xf - this.xi) {
        this.bar_size = (this.xf - this.xi) / 3.0;
        this.min_size = 0.5 * this.bar_size;
      }
      else {
        this.min_size = min(this.bar_size, (this.xf - this.xi) / 9.0);
      }
      this.button_up.setLocation(this.xi, this.yi, this.xi + this.bar_size, this.yf);
      this.button_down.setLocation(this.xf - this.bar_size, this.yi, this.xf, this.yf);
    }
    this.refreshBarButtonSizes();
  }

  void refreshBarButtonSizes() {
    float bar_height = 0;
    if (this.vertical) {
      bar_height = this.yf - this.yi - 2 * this.bar_size;
    }
    else {
      bar_height = this.xf - this.xi - 2 * this.bar_size;
    }
    float bar_button_size = max(this.min_size, bar_height - this.step_size * (this.maxValue - this.minValue));
    if (this.maxValue == this.minValue) {
      this.value_size = 0;
    }
    else {
      this.value_size = (bar_height - bar_button_size) / (this.maxValue - this.minValue);
    }
    this.refreshBarButtons();
  }

  void refreshBarButtons() {
    if (this.vertical) {
      float cut_one = this.yi + this.bar_size + this.value_size * (this.value - this.minValue);
      float cut_two = this.yf - this.bar_size - this.value_size * (this.maxValue - this.value);
      this.button_upspace.setLocation(this.xi, this.yi + this.bar_size, this.xf, cut_one);
      this.button_downspace.setLocation(this.xi, cut_two, this.xf, this.yf - this.bar_size);
      this.button_bar.setLocation(this.xi, cut_one, this.xf, cut_two);
    }
    else {
      float cut_one = this.xi + this.bar_size + this.value_size * (this.value - this.minValue);
      float cut_two = this.xf - this.bar_size - this.value_size * (this.maxValue - this.value);
      this.button_upspace.setLocation(this.xi + this.bar_size, this.yi, cut_one, this.yf);
      this.button_downspace.setLocation(cut_two, this.yi, this.xf - this.bar_size, this.yf);
      this.button_bar.setLocation(cut_one, this.yi, cut_two, this.yf);
    }
  }

  void updateMinValue(float minValue) {
    this.minValue = minValue;
    if (this.minValue > this.maxValue) {
      this.minValue = this.maxValue;
    }
    if (this.value < this.minValue) {
      this.value = this.minValue;
    }
    this.refreshBarButtonSizes();
  }
  void increaseMinValue(float amount) {
    this.updateMinValue(this.minValue + amount);
  }
  void decreaseMinValue(float amount) {
    this.updateMinValue(this.minValue - amount);
  }

  void updateMaxValue(float maxValue) {
    this.maxValue = maxValue;
    if (this.maxValue < this.minValue) {
      this.maxValue = this.minValue;
    }
    if (this.value > this.maxValue) {
      this.value = this.maxValue;
    }
    this.refreshBarButtonSizes();
  }
  void increaseMaxValue(float amount) {
    this.updateMaxValue(this.maxValue + amount);
  }
  void decreaseMaxValue(float amount) {
    this.updateMaxValue(this.maxValue - amount);
  }

  void updateValue(float value) {
    this.value = value;
    if (this.value < this.minValue) {
      this.value = this.minValue;
    }
    else if (this.value > this.maxValue) {
      this.value = this.maxValue;
    }
    this.refreshBarButtons();
  }
  void scrollMax() {
    this.value = this.maxValue;
    this.refreshBarButtons();
  }
  void scrollMin() {
    this.value = this.minValue;
    this.refreshBarButtons();
  }

  void increaseValue(float amount) {
    this.updateValue(this.value + amount);
  }
  void decreaseValue(float amount) {
    this.updateValue(this.value - amount);
  }
  void increaseValuePercent(float percent) {
    this.updateValue(this.value + percent * (this.maxValue - this.minValue));
  }
  void decreaseValuePercent(float percent) {
    this.updateValue(this.value - percent * (this.maxValue - this.minValue));
  }

  void update(int millis) {
    this.button_up.update(millis);
    this.button_down.update(millis);
    this.button_upspace.update(millis);
    this.button_downspace.update(millis);
    this.button_bar.update(millis);
  }

  void mouseMove(float mX, float mY) {
    this.button_up.mouseMove(mX, mY);
    this.button_down.mouseMove(mX, mY);
    this.button_upspace.mouseMove(mX, mY);
    this.button_downspace.mouseMove(mX, mY);
    this.button_bar.mouseMove(mX, mY);
  }

  void mousePress() {
    this.button_up.mousePress();
    this.button_down.mousePress();
    this.button_upspace.mousePress();
    this.button_downspace.mousePress();
    this.button_bar.mousePress();
  }

  boolean clicked() {
    return (this.button_up.clicked || this.button_down.clicked ||
      this.button_upspace.clicked || this.button_downspace.clicked ||
      this.button_bar.clicked);
  }

  void mouseRelease(float mX, float mY) {
    this.button_up.mouseRelease(mX, mY);
    this.button_down.mouseRelease(mX, mY);
    this.button_upspace.mouseRelease(mX, mY);
    this.button_downspace.mouseRelease(mX, mY);
    this.button_bar.mouseRelease(mX, mY);
  }
}



class TextBox {
  protected float xi = 0;
  protected float yi = 0;
  protected float xf = 0;
  protected float yf = 0;
  protected boolean hovered = false;
  protected int lastUpdateTime = 0;
  protected boolean use_time_elapsed = false;

  protected ScrollBar scrollbar = new ScrollBar(true);
  protected float scrollbar_max_width = 50;
  protected float scrollbar_min_width = 25;

  protected boolean wordWrap = true;
  protected ScrollBar scrollbar_horizontal;
  protected ArrayList<String> text_lines_display = new ArrayList<String>();

  protected String text_ref = "";
  protected ArrayList<String> text_lines = new ArrayList<String>();
  protected float text_size = 15;
  protected float text_leading = 0;

  protected String text_title_ref = null;
  protected String text_title = null;
  protected float title_size = 22;

  protected color color_background = ccolor(250);
  protected color color_header = ccolor(200);
  protected color color_stroke = ccolor(0);
  protected color color_text = ccolor(0);
  protected color color_title = ccolor(0);

  TextBox() {
    this(0, 0, 0, 0);
  }
  TextBox(float xi, float yi, float xf, float yf) {
    this.setLocation(xi, yi, xf, yf);
  }

  void useElapsedTime() {
    this.scrollbar.useElapsedTime();
    if (this.scrollbar_horizontal != null) {
      this.scrollbar_horizontal.useElapsedTime();
    }
    this.use_time_elapsed = true;
  }

  void setXLocation(float xi, float xf) {
    this.setLocation(xi, this.yi, xf, this.yf);
  }
  void setYLocation(float yi, float yf) {
    this.setLocation(this.xi, yi, this.xf, yf);
  }
  void setLocation(float xi, float yi, float xf, float yf) {
    this.xi = xi;
    this.yi = yi;
    this.xf = xf;
    this.yf = yf;
    this.refreshTitle();
  }

  void setTextSize(float text_size) {
    this.text_size = text_size;
    this.refreshText();
  }

  void setTitleSize(float title_size) {
    this.title_size = title_size;
    this.refreshTitle();
  }

  void refreshTitle() {
    this.setTitleText(this.text_title_ref);
  }

  void setTitleText(String title) {
    this.text_title_ref = title;
    float scrollbar_width = min(this.scrollbar_max_width, 0.05 * (this.xf - this.xi));
    scrollbar_width = max(this.scrollbar_min_width, scrollbar_width);
    scrollbar_width = min(0.05 * (this.xf - this.xi), scrollbar_width);
    if (title == null) {
      this.text_title = null;
      this.scrollbar.setLocation(xf - scrollbar_width, this.yi, this.xf, this.yf);
    }
    else {
      this.text_title = "";
      textSize(this.title_size);
      for (int i = 0; i < title.length(); i++) {
        char nextChar = title.charAt(i);
        if (textWidth(this.text_title + nextChar) < this.xf - this.xi - 3) {
          this.text_title += nextChar;
        }
        else {
          break;
        }
      }
      this.scrollbar.setLocation(this.xf - scrollbar_width, this.yi + 1 + textAscent() + textDescent(), this.xf, this.yf);
    }
    if (!this.wordWrap) {
      this.scrollbar_horizontal.setLocation(this.xi, this.yf - this.scrollbar.bar_size, this.xf - this.scrollbar.bar_size, this.yf);
    }
    this.refreshText();
  }

  void setWordWrap(boolean wordWrap) {
    this.wordWrap = wordWrap;
    if (!wordWrap) {
      this.scrollbar_horizontal = new ScrollBar(false);
      this.scrollbar_horizontal.setLocation(this.xi, this.yf - this.scrollbar.bar_size, this.xf - this.scrollbar.bar_size, this.yf);
    }
    this.refreshText();
  }

  void refreshText() {
    this.setText(this.text_ref);
  }

  void clearText() {
    this.setText("");
  }

  void addText(String text) {
    this.setText(this.text_ref + text);
  }

  void setText(String text) {
    this.text_ref = text;
    this.text_lines.clear();
    this.text_lines_display.clear();
    float currY = this.yi + 1;
    if (this.text_title_ref != null) {
      textSize(this.title_size);
      currY += textAscent() + textDescent() + 2;
    }
    textSize(this.text_size);
    float text_height = textAscent() + textDescent();
    float effective_xf = this.xf - this.xi - 3 - this.scrollbar.bar_size;
    int lines_above = 0;
    String[] lines = split(text, '\n');
    String currLine = "";
    boolean firstWord = true;
    int max_line_length = 0;
    for (int i = 0; i < lines.length; i++) {
      if (this.wordWrap) {
        String[] words = split(lines[i], ' ');
        for (int j = 0; j < words.length; j++) {
          String word = " ";
          if (firstWord) {
            word = "";
          }
          word += words[j];
          if (textWidth(currLine + word) < effective_xf) {
            currLine += word;
            firstWord = false;
          }
          else if (firstWord) {
            for (int k = 0; k < word.length(); k++) {
              char nextChar = word.charAt(k);
              if (textWidth(currLine + nextChar) < effective_xf) {
                currLine += nextChar;
              }
              else {
                this.text_lines.add(currLine);
                currLine = "" + nextChar;
                firstWord = true;
                if (currY + text_height + 1 > this.yf) {
                  lines_above++;
                }
                currY += text_height + this.text_leading;
              }
            }
            firstWord = false;
          }
          else {
            this.text_lines.add(currLine);
            currLine = words[j];
            firstWord = false;
            if (currY + text_height + 1 > this.yf) {
              lines_above++;
            }
            currY += text_height + this.text_leading;
          }
        }
        this.text_lines.add(currLine);
        currLine = "";
        firstWord = true;
        if (currY + text_height + 1 > this.yf) {
          lines_above++;
        }
        currY += text_height + this.text_leading;
      }
      else {
        this.text_lines.add(lines[i]);
        for (int j = 0; j < lines[i].length(); j++) {
          char nextChar = lines[i].charAt(j);
          if (textWidth(currLine + nextChar) < effective_xf) {
            currLine += nextChar;
          }
          else {
            if (lines[i].length() - j > max_line_length) {
              max_line_length = lines[i].length() - j;
            }
            break;
          }
        }
        currLine = "";
        if (currY + text_height + 1 > this.yf) {
          lines_above++;
        }
        currY += text_height + this.text_leading;
      }
    }
    this.scrollbar.updateMaxValue(lines_above);
    if (!this.wordWrap) {
      this.scrollbar_horizontal.updateMaxValue(max_line_length);
    }
  }

  String truncateLine(String line) {
    String return_line = "";
    float effective_xf = this.xf - this.xi - 3 - this.scrollbar.bar_size;
    for (int i = int(floor(this.scrollbar_horizontal.value)); i < line.length(); i++) {
      char nextChar = line.charAt(i);
      if (textWidth(return_line + nextChar) < effective_xf) {
        return_line += nextChar;
      }
      else {
        break;
      }
    }
    return return_line;
  }

  void update(int millis) {
    rectMode(CORNERS);
    fill(this.color_background);
    stroke(this.color_stroke);
    strokeWeight(1);
    rect(this.xi, this.yi, this.xf, this.yf);
    float currY = this.yi + 1;
    if (this.text_title_ref != null) {
      fill(this.color_header);
      textSize(this.title_size);
      rect(this.xi, this.yi, this.xf, this.yi + textAscent() + textDescent() + 1);
      fill(this.color_title);
      textAlign(CENTER, TOP);
      text(this.text_title, this.xi + 0.5 * (this.xf - this.xi), currY);
      currY += textAscent() + textDescent() + 2;
    }
    fill(this.color_text);
    textAlign(LEFT, TOP);
    textSize(this.text_size);
    float text_height = textAscent() + textDescent();
    for (int i = int(floor(this.scrollbar.value)); i < this.text_lines.size(); i++, currY += text_height + this.text_leading) {
      if (currY + text_height + 1 > this.yf) {
        break;
      }
      if (this.wordWrap) {
        text(this.text_lines.get(i), this.xi + 2, currY);
      }
      else {
        text(this.truncateLine(this.text_lines.get(i)), this.xi + 2, currY);
      }
    }
    if (this.scrollbar.maxValue != this.scrollbar.minValue) {
      this.scrollbar.update(millis);
    }
    if (!this.wordWrap) {
      if (this.scrollbar_horizontal.maxValue != this.scrollbar_horizontal.minValue) {
        this.scrollbar_horizontal.update(millis);
      }
    }
    this.lastUpdateTime = millis;
  }

  void mouseMove(float mX, float mY) {
    this.scrollbar.mouseMove(mX, mY);
    if (!this.wordWrap) {
      if (this.scrollbar_horizontal.maxValue != this.scrollbar_horizontal.minValue) {
        this.scrollbar_horizontal.mouseMove(mX, mY);
      }
    }
    if (mX >= this.xi && mX <= this.xf && mY >= this.yi && mY <= this.yf) {
      this.hovered = true;
    }
    else {
      this.hovered = false;
    }
  }

  void mousePress() {
    this.scrollbar.mousePress();
    if (!this.wordWrap) {
      if (this.scrollbar_horizontal.maxValue != this.scrollbar_horizontal.minValue) {
        this.scrollbar_horizontal.mousePress();
      }
    }
  }

  void mouseRelease(float mX, float mY) {
    this.scrollbar.mouseRelease(mX, mY);
    if (!this.wordWrap) {
      if (this.scrollbar_horizontal.maxValue != this.scrollbar_horizontal.minValue) {
        this.scrollbar_horizontal.mouseRelease(mX, mY);
      }
    }
  }

  void scroll(int amount) {
    if (this.hovered) {
      this.scrollbar.increaseValue(amount);
      if (!this.wordWrap && this.scrollbar.maxValue == this.scrollbar.minValue) {
        if (this.scrollbar_horizontal.maxValue != this.scrollbar_horizontal.minValue) {
          this.scrollbar_horizontal.increaseValue(amount);
        }
      }
    }
  }

  void scrollBottom() {
    this.scrollbar.updateValue(this.scrollbar.maxValue);
  }

  void keyPress() {
  }
}


abstract class ListTextBox extends TextBox {
  protected ArrayList<String> text_lines_ref;
  protected int line_hovered = -1;
  protected int line_clicked = -1;
  protected color hover_color = ccolor(180, 180, 200, 60);
  protected color highlight_color = ccolor(100, 100, 250, 120);
  protected int doubleclickTimer = 0;
  protected int doubleclickTime = 400;
  protected boolean can_unclick_outside_box = true;

  ListTextBox() {
    this(0, 0, 0, 0);
  }
  ListTextBox(float xi, float yi, float xf, float yf) {
    super(xi, yi, xf, yf);
  }

  @Override
  void clearText() {
    this.setText("");
    this.text_lines.clear();
  }

  @Override
  void setText(String text) {
    this.text_ref = text;
    this.text_lines.clear();
    this.text_lines_ref = new ArrayList<String>();
    float currY = this.yi + 1;
    if (this.text_title_ref != null) {
      textSize(this.title_size);
      currY += textAscent() + textDescent() + 2;
    }
    textSize(this.text_size);
    float text_height = textAscent() + textDescent();
    float effective_xf = this.xf - this.xi - 3 - this.scrollbar.bar_size;
    int lines_above = 0;
    String[] lines = split(text, '\n');
    for (String line : lines) {
      this.text_lines_ref.add(line);
      String currLine = "";
      for (int i = 0; i < line.length(); i++) {
        char nextChar = line.charAt(i);
        if (textWidth(currLine + nextChar) < effective_xf) {
          currLine += nextChar;
        }
        else {
          break;
        }
      }
      this.text_lines.add(currLine);
      if (currY + text_height + 1 > this.yf) {
        lines_above++;
      }
      currY += text_height + this.text_leading;
    }
    this.scrollbar.updateMaxValue(lines_above);
  }

  void addLine(String line) {
    if (this.text_ref == null || this.text_ref.equals("")) {
      this.setText(line);
    }
    else {
      this.addText("\n" + line);
    }
  }

  String highlightedLine() {
    if (this.line_clicked < 0 || this.line_clicked >= this.text_lines_ref.size()) {
      return null;
    }
    return this.text_lines_ref.get(this.line_clicked);
  }

  @Override
  void update(int millis) {
    int time_elapsed = millis - this.lastUpdateTime;
    if (this.use_time_elapsed) {
      time_elapsed = millis;
    }
    super.update(millis);
    if (this.doubleclickTimer > 0) {
      this.doubleclickTimer -= time_elapsed;
    }
    float currY = this.yi + 1;
    if (this.text_title_ref != null) {
      textSize(this.title_size);
      currY += textAscent() + textDescent() + 2;
    }
    textSize(this.text_size);
    float text_height = textAscent() + textDescent();
    if (this.line_hovered >= floor(this.scrollbar.value)) {
      float hovered_yi = currY + (this.line_hovered - floor(this.scrollbar.value)) * (text_height + this.text_leading);
      if (hovered_yi + text_height + 1 < this.yf) {
        rectMode(CORNERS);
        fill(this.hover_color);
        strokeWeight(0.001);
        stroke(this.hover_color);
        rect(this.xi + 1, hovered_yi, this.xf - 2 - this.scrollbar.bar_size, hovered_yi + text_height);
      }
    }
    if (this.line_clicked >= floor(this.scrollbar.value)) {
      float clicked_yi = currY + (this.line_clicked - floor(this.scrollbar.value)) * (text_height + this.text_leading);
      if (clicked_yi + text_height + 1 < this.yf) {
        rectMode(CORNERS);
        fill(this.highlight_color);
        strokeWeight(0.001);
        stroke(this.highlight_color);
        rect(this.xi + 1, clicked_yi, this.xf - 2 - this.scrollbar.bar_size, clicked_yi + text_height);
      }
    }
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.scrollbar.mouseMove(mX, mY);
    if (mX > this.xi && mX < this.xf && mY > this.yi && mY < this.yf) {
      this.hovered = true;
      float currY = this.yi + 1;
      if (this.text_title_ref != null) {
        textSize(this.title_size);
        currY += textAscent() + textDescent() + 2;
      }
      textSize(this.text_size);
      float line_height = textAscent() + textDescent() + this.text_leading;
      int target_line = int(floor(this.scrollbar.value) + floor((mY - currY) / line_height));
      int lines_shown = this.text_lines.size() - int(this.scrollbar.maxValue);
      if (target_line < 0 || mX > (this.xf - this.scrollbar.bar_size) || target_line >= this.text_lines_ref.size() ||
        target_line - int(floor(this.scrollbar.value)) >= lines_shown) {
        this.line_hovered = -1;
      }
      else {
        this.line_hovered = target_line;
      }
    }
    else {
      this.hovered = false;
      this.line_hovered = -1;
    }
  }

  @Override
  void mousePress() {
    super.mousePress();
    if (this.line_hovered > -1) {
      if (this.doubleclickTimer > 0  && this.line_clicked == this.line_hovered) {
        this.line_clicked = this.line_hovered;
        this.doubleclick();
        this.doubleclickTimer = 0;
      }
      else {
        this.line_clicked = this.line_hovered;
        this.click();
        this.doubleclickTimer = this.doubleclickTime;
      }
    }
    else if (this.can_unclick_outside_box || this.hovered) {
      this.line_clicked = this.line_hovered;
    }
  }

  @Override
  void mouseRelease(float mX, float mY) {
    if (this.line_hovered < 0 && !this.scrollbar.clicked() && (this.can_unclick_outside_box || this.hovered)) {
      this.line_clicked = this.line_hovered;
    }
    super.mouseRelease(mX, mY);
  }

  void jump_to_line() {
    this.jump_to_line(false);
  }
  void jump_to_line(boolean hard_jump) {
    if (this.line_clicked < 0) {
      return;
    }
    if (hard_jump || this.line_clicked < int(floor(this.scrollbar.value))) {
      this.scrollbar.updateValue(this.line_clicked);
      return;
    }
    int lines_shown = this.text_lines.size() - int(this.scrollbar.maxValue);
    if (this.line_clicked >= int(this.scrollbar.value) + lines_shown) {
      this.scrollbar.increaseValue(1 + this.line_clicked - int(this.scrollbar.value) - lines_shown);
    }
    else if (this.line_clicked < int(this.scrollbar.value)) {
      this.scrollbar.decreaseValue(int(this.scrollbar.value) - this.line_clicked);
    }
  }

  @Override
  void keyPress() {
    if (!this.hovered) {
      return;
    }
    if (key == CODED) {
      switch(keyCode) {
        case UP:
          if (this.line_clicked > 0) {
            this.line_clicked--;
            this.jump_to_line(false);
          }
          break;
        case DOWN:
          if (this.line_clicked < this.text_lines_ref.size() - 1) {
            this.line_clicked++;
            this.jump_to_line(false);
          }
          break;
        default:
          break;
      }
    }
  }

  abstract void click(); // click on line
  abstract void doubleclick(); // doubleclick on line
}


abstract class MaxListTextBox extends ListTextBox {
  protected float y_curr = 0;

  MaxListTextBox() {
    this(0, 0, 0, 0);
  }
  MaxListTextBox(float xi, float yi, float xf, float yf) {
    super(xi, yi, xf, yf);
  }

  @Override
  void setText(String text) {
    super.setText(text);
    float currY = this.yi + 3;
    if (this.text_title_ref != null) {
      textSize(this.title_size);
      currY += textAscent() + textDescent() + 2;
    }
    textSize(this.text_size);
    float text_height = textAscent() + textDescent();
    this.y_curr = min(this.yf, currY + this.text_lines_ref.size() * (text_height + this.text_leading));
  }

  @Override
  void update(int millis) {
    float y_max = this.yf;
    this.yf = y_curr;
    super.update(millis);
    this.yf = y_max;
  }
}


class DropDownList extends ListTextBox {
  protected boolean active = false;
  protected boolean show_highlight = false;
  protected String hint_text = "";

  DropDownList() {
    this(0, 0, 0, 0);
  }
  DropDownList(float xi, float yi, float xf, float yf) {
    super(xi, yi, xf, yf);
  }

  @Override
  void update(int millis) {
    if (this.active) {
      super.update(millis);
    }
    else {
      textAlign(LEFT, TOP);
      textSize(this.text_size);
      float text_height = textAscent() + textDescent();
      rectMode(CORNERS);
      fill(this.color_background);
      stroke(this.color_stroke);
      strokeWeight(1);
      rect(this.xi, this.yi, this.xf - 1 - this.scrollbar.bar_size, this.yi + 3 + text_height);
      if (this.line_clicked >= 0) {
        fill(this.color_text);
        text(this.text_lines.get(this.line_clicked), this.xi + 2, this.yi + 1);
      }
      else {
        fill(this.color_text, 150);
        text(this.hint_text, this.xi + 2, this.yi + 1);
      }
      if (this.show_highlight) {
        fill(this.highlight_color);
        strokeWeight(0.0001);
        stroke(this.highlight_color);
        rect(this.xi + 1, this.yi + 1, this.xf - 2 - this.scrollbar.bar_size, this.yi + 1 + text_height);
      }
    }
  }

  @Override
  void mousePress() {
    if (this.active) {
      if (this.hovered) {
        int last_line_clicked = this.line_clicked;
        super.mousePress();
        this.line_clicked = last_line_clicked;
      }
      else {
        this.show_highlight = false;
        this.active = false;
      }
    }
    else {
      int last_line_clicked = this.line_clicked;
      super.mousePress();
      if (this.line_clicked == int(floor(this.scrollbar.value))) {
        if (this.show_highlight) {
          this.active = true;
          this.line_clicked = last_line_clicked;
          this.jump_to_line(true);
        }
        else {
          this.line_clicked = last_line_clicked;
          this.show_highlight = true;
        }
      }
      else {
        this.line_clicked = last_line_clicked;
        this.show_highlight = false;
      }
    }
  }

  @Override
  void mouseRelease(float mX, float mY) {
    int last_line_clicked = this.line_clicked;
    super.mouseRelease(mX, mY);
    this.line_clicked = last_line_clicked;
  }

  @Override
  void keyPress() {
    if (!this.show_highlight && !this.active) {
      return;
    }
    if (key == CODED) {
      switch(keyCode) {
        case UP:
          if (this.line_clicked > 0) {
            this.line_clicked--;
            this.jump_to_line(false);
          }
          break;
        case DOWN:
          if (this.line_clicked < this.text_lines_ref.size() - 1) {
            this.line_clicked++;
            this.jump_to_line(false);
          }
          break;
        default:
          break;
      }
    }
    else {
      switch(key) {
        case ENTER:
        case RETURN:
          if (this.active) {
            this.doubleclick();
          }
          else {
            this.active = true;
            this.jump_to_line(true);
          }
          break;
        case ESC:
          this.doubleclick();
          this.show_highlight = false;
          break;
        default:
          break;
      }
    }
  }

  void click() {}

  void doubleclick() {
    if (this.active) {
      this.active = false;
      this.show_highlight = true;
    }
  }
}




class InputBox extends RectangleButton {
  protected String text = "";
  protected String hint_text = "";
  protected color hint_color = ccolor(80);
  protected boolean typing = false;
  protected String display_text = "";

  protected int location_display = 0;
  protected int location_cursor = 0;

  protected float cursor_weight = 1;
  protected int cursor_blink_time = 450;
  protected int cursor_blink_timer = 0;
  protected boolean cursor_blinking = true;

  protected float lastMouseX = 0;

  InputBox(float xi, float yi, float xf, float yf) {
    super(xi, yi, xf, yf);
    this.roundness = 0;
    this.setColors(color(170), ccolor(220), ccolor(220), ccolor(255), ccolor(0));
  }

  void refreshText() {
    this.setText(this.text);
  }
  void setText(String text) {
    if (text == null) {
      text = "";
    }
    this.text = text;
    this.updateDisplayText();
    if (this.location_cursor > this.text.length()) {
      this.location_cursor = this.text.length();
    }
    if (this.location_cursor > this.location_display + this.display_text.length()) {
      this.location_display = this.location_cursor - this.display_text.length();
      this.updateDisplayText();
    }
  }

  void setTextSize(float text_size) {
    this.text_size = text_size;
    this.refreshText();
  }

  @Override
  void setLocation(float xi, float yi, float xf, float yf) {
    super.setLocation(xi, yi, xf, yf);
    this.updateDisplayText();
  }

  @Override
  void stretchButton(float amount, int direction) {
    super.stretchButton(amount, direction);
    this.updateDisplayText();
  }

  void updateDisplayText() {
    if (this.text == null) {
      this.text = "";
    }
    this.display_text = "";
    textSize(this.text_size);
    float maxWidth = this.xf - this.xi - 2 - textWidth(' ');
    boolean decreaseDisplayLocation = true;
    for (int i = this.location_display; i < this.text.length(); i++ ) {
      if (textWidth(this.display_text + this.text.charAt(i)) > maxWidth) {
        decreaseDisplayLocation = false;
        break;
      }
      this.display_text += this.text.charAt(i);
    }
    if (decreaseDisplayLocation && this.location_display <= this.text.length()) {
      while(this.location_display > 0 && textWidth(this.text.charAt(
        this.location_display - 1) + this.display_text) <= maxWidth) {
        this.location_display--;
        this.display_text = this.text.charAt(this.location_display) + this.display_text;
      }
    }
    // if say increased text size
    if (this.location_cursor - this.location_display > this.display_text.length()) {
      int dif = this.location_cursor - this.location_display - this.display_text.length();
      this.location_display += dif;
      int end_index = this.location_display + this.display_text.length();
      if (end_index > this.text.length()) {
        end_index = this.text.length();
      }
      if (this.location_display > this.text.length()) {
        this.location_display = this.text.length();
      }
      this.display_text = this.text.substring(this.location_display, end_index);
    }
  }

  void resetBlink() {
    this.cursor_blinking = true;
    this.cursor_blink_timer = 0;
  }

  @Override
  color fillColor() {
    if (this.disabled) {
      return this.color_disabled;
    }
    else if (this.typing) {
      return this.color_click;
    }
    else {
      return this.color_default;
    }
  }

  @Override
  void drawButton() {
    super.drawButton();
    textAlign(LEFT, TOP);
    if (this.text.equals("")) {
      textSize(this.text_size - 2);
      fill(this.hint_color);
      text(this.hint_text, this.xi + 2, this.yi + 1);
    }
    else {
      textSize(this.text_size);
      fill(this.color_text);
      text(this.display_text, this.xi + 2, this.yi + 1);
    }
    if (this.typing && this.cursor_blinking) {
      strokeWeight(this.cursor_weight);
      fill(this.color_stroke);
      float x_cursor = this.xi + 2 + textWidth(this.display_text.substring(
        0, this.location_cursor - this.location_display));
      line(x_cursor, this.yi + 2, x_cursor, this.yf - 2);
    }
  }

  @Override
  void update(int millis) {
    int timeElapsed = millis - this.lastUpdateTime;
    super.update(millis);
    if (this.typing) {
      this.cursor_blink_timer += timeElapsed;
      if (this.cursor_blink_timer > this.cursor_blink_time) {
        this.cursor_blink_timer -= this.cursor_blink_time;
        this.cursor_blinking = !this.cursor_blinking;
      }
    }
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.lastMouseX = mX;
    super.mouseMove(mX, mY);
  }

  void dehover() {
  }

  void hover() {
  }

  @Override
  void mousePress() {
    this.typing = false;
    super.mousePress();
  }
  void click() {
    this.typing = true;
    this.resetBlink();
    textSize(this.text_size);
    String display_text_copy = this.display_text;
    while (display_text_copy.length() > 0 && this.lastMouseX < this.xi + 2 + textWidth(display_text_copy)) {
      display_text_copy = display_text_copy.substring(0, display_text_copy.length() - 1);
    }
    this.location_cursor = location_display + display_text_copy.length();
  }

  void release() {
  }

  void keyPress() {
    if (!this.typing) {
      return;
    }
    if (key == CODED) {
      switch(keyCode) {
        case LEFT:
          this.location_cursor--;
          if (this.location_cursor < 0) {
            this.location_cursor = 0;
          }
          else if (this.location_cursor < this.location_display) {
            this.location_display--;
            this.updateDisplayText();
          }
          break;
        case RIGHT:
          this.location_cursor++;
          if (this.location_cursor > this.text.length()) {
            this.location_cursor = this.text.length();
          }
          else if (this.location_cursor > this.location_display + this.display_text.length()) {
            this.location_display++;
            this.updateDisplayText();
          }
          break;
        case KeyEvent.VK_HOME:
          this.location_cursor = 0;
          this.location_display = 0;
          this.updateDisplayText();
          break;
        case KeyEvent.VK_END:
          this.location_cursor = this.text.length();
          this.location_display = this.text.length();
          this.updateDisplayText();
          break;
        default:
          break;
      }
    }
    else {
      switch(key) {
        case BACKSPACE:
          if (this.location_cursor > 0) {
            this.location_cursor--;
            if (this.location_cursor < this.location_display) {
              this.location_display--;
            }
            this.setText(this.text.substring(0, this.location_cursor) +
              this.text.substring(this.location_cursor + 1, this.text.length()));
          }
          break;
        case TAB:
          break;
        case ENTER:
        case RETURN:
          break;
        case ESC:
          this.typing = false;
          break;
        case DELETE:
          break;
        default:
          this.location_cursor++;
          if (this.location_cursor > this.location_display + this.display_text.length()) {
            this.location_display++;
          }
          this.setText(this.text.substring(0, this.location_cursor - 1) + key +
            this.text.substring(this.location_cursor - 1, this.text.length()));
          this.updateDisplayText();
          break;
      }
    }
    this.resetBlink();
  }

  void keyRelease() {
    if (!this.typing) {
      return;
    }
    this.resetBlink();
  }
}




class Slider  {
  class SliderButton extends CircleButton {
    protected boolean active = false;
    protected float active_grow_factor = 1.3;
    protected color active_color = ccolor(0, 50, 0);
    protected float lastX = 0;
    protected float changeFactor = 1;

    SliderButton() {
      super(0, 0, 0);
      this.setColors(color(170), ccolor(255, 0), ccolor(255, 0), ccolor(255, 0), ccolor(0));
      strokeWeight(2);
    }

    @Override
    float radius() {
      if (this.active) {
        return this.active_grow_factor * super.radius();
      }
      else {
        return super.radius();
      }
    }

    color lineColor() {
      if (this.disabled) {
        return this.color_disabled;
      }
      else if (this.active) {
        return this.active_color;
      }
      return this.color_stroke;
    }

    @Override
    void drawButton() {
      ellipseMode(RADIUS);
      if (this.disabled) {
        fill(this.color_disabled);
      }
      else if (this.active) {
        fill(this.active_color);
      }
      else {
        noFill();
      }
      stroke(this.lineColor());
      strokeWeight(Slider.this.line_thickness);
      circle(this.xc, this.yc, this.radius());
    }

    void mouseMove(float mX, float mY) {
      super.mouseMove(mX, mY);
      if (this.active && this.clicked) {
        this.moveButton(mX - this.lastX, 0);
        this.changeFactor = 1; // how much value actually changed (accounting for step_size)
        Slider.this.refreshValue();
        this.lastX += this.changeFactor * (mX - this.lastX);
      }
      else {
        this.lastX = mX;
      }
    }

    void mousePress() {
      super.mousePress();
      if (!this.hovered) {
        this.active = false;
      }
    }

    void scroll(int amount) {
      if (!this.active) {
        return;
      }
      Slider.this.step(amount);
    }

    void keyPress() {
      if (!this.active) {
        return;
      }
      if (key == CODED) {
        switch(keyCode) {
          case LEFT:
            Slider.this.step(-1);
            break;
          case RIGHT:
            Slider.this.step(1);
            break;
          default:
            break;
        }
      }
    }

    void hover() {}
    void dehover() {}
    void release() {}

    void click() {
      this.active = true;
    }
  }

  protected float xi;
  protected float yi;
  protected float xf;
  protected float yf;
  protected float yCenter;

  protected float min_value = 0;
  protected float max_value = 0;
  protected float step_size = -1;
  protected boolean no_step = true;
  protected float value = 0;

  protected SliderButton button = new SliderButton();
  protected float offset;
  protected float line_thickness = 3;

  protected boolean hovered = false;

  protected String label = "";
  protected boolean show_label = false;
  protected boolean round_label = true;
  protected boolean only_label_ends = false;
  protected boolean show_label_in_middle = false;

  Slider() {
    this(0, 0, 0, 0);
  }
  Slider(float xi, float yi, float xf, float yf) {
    this.setLocation(xi, yi, xf, yf);
  }

  void disable() {
    this.button.active = false;
    this.button.disabled = true;
  }

  void enable() {
    this.button.disabled = false;
  }

  void setLocation(float xi, float yi, float xf, float yf) {
    this.xi = xi;
    this.yi = yi;
    this.xf = xf;
    this.yf = yf;
    this.yCenter = yi + 0.5 * (yf - yi);
    this.button.setLocation(xi, this.yCenter, 0.5 * (yf - yi) / this.button.active_grow_factor);
    this.offset = this.button.xr * this.button.active_grow_factor;
    this.refreshButton();
  }

  // called when slider changes value or size (this never changes value)
  void refreshButton() {
    if (this.min_value == this.max_value) {
      this.button.moveButton(this.xi + this.offset - this.button.xCenter(), 0);
      return;
    }
    float targetX = this.xi + this.offset + (this.xf - 2 * this.offset - this.xi) *
      (this.value - this.min_value) / (this.max_value - this.min_value);
    this.button.moveButton(targetX - this.button.xCenter(), 0);
  }

  // called when button changes value (this changes value so calls refreshButton)
  void refreshValue() {
    float targetValue = this.min_value + (this.button.xCenter() - this.xi - this.offset)
      * (this.max_value - this.min_value) / (this.xf - 2 * this.offset - this.xi);
    boolean hitbound = false;
    if (targetValue >= this.max_value) {
      float change = targetValue - this.value;
      if (change > 0) {
        this.button.changeFactor = (this.max_value - this.value) / change;
      }
      targetValue = this.max_value;
      hitbound = true;
    }
    else if (targetValue <= this.min_value) {
      float change = targetValue - this.value;
      if (change < 0) {
        this.button.changeFactor = (this.min_value - this.value) / change;
      }
      targetValue = this.min_value;
      hitbound = true;
    }
    float change = targetValue - this.value;
    if (!this.no_step && !hitbound && this.step_size != 0 && change != 0) {
      float new_change = this.step_size * (round(change / this.step_size));
      this.button.changeFactor = new_change/change;
      change = new_change;
    }
    this.value += change;
    this.refreshButton();
  }

  void bounds(float min, float max, float step) {
    if (min > max) {
      min = max;
    }
    this.min_value = min;
    this.max_value = max;
    this.step_size = step;
    if (this.value < min) {
      this.value = min;
    }
    else if (this.value > max) {
      this.value = max;
    }
    if (step > 0) {
      this.no_step = false;
    }
    else {
      this.no_step = true;
    }
  }

  void step(int amount) {
    if (this.no_step) {
      this.value += 0.1 * (this.max_value - this.min_value) * amount;
    }
    else {
      this.value += this.step_size * amount;
    }
    if (this.value > this.max_value) {
      this.value = this.max_value;
    }
    else if (this.value < this.min_value) {
      this.value = this.min_value;
    }
    this.refreshButton();
  }

  void setValue(float value) {
    this.value = value;
    if (this.value > this.max_value) {
      this.value = this.max_value;
    }
    else if (this.value < this.min_value) {
      this.value = this.min_value;
    }
    this.refreshButton();
  }

  void update(int millis) {
    if (this.show_label) {
      textSize(this.button.yr);
      textAlign(CENTER, BOTTOM);
    }
    if (!this.no_step && this.max_value != this.min_value) {
      strokeWeight(0.5 * this.line_thickness);
      stroke(this.button.active_color);
      fill(this.button.active_color);
      boolean not_switched_color = true;
      boolean on_end = true;
      for (float i = this.min_value; i <= this.max_value; i += this.step_size) {
        if (i + this.step_size > this.max_value) {
          on_end = true;
        }
        float targetX = this.xi + this.offset + (this.xf - 2 * this.offset - this.xi) *
          (i - this.min_value) / (this.max_value - this.min_value);
        if (not_switched_color && targetX > this.button.xCenter()) {
          stroke(this.button.color_stroke);
          fill(this.button.color_stroke);
          not_switched_color = false;
        }
        if (this.show_label && (!this.only_label_ends || on_end)) {
          line(targetX, this.button.yc - 3, targetX, this.button.yc + this.button.yr - 1);
          String label_text = "";
          if (this.round_label) {
            if (on_end || this.show_label_in_middle) {
              label_text = round(i) + this.label;
            }
            else {
              label_text = Integer.toString(round(i));
            }
          }
          else {
            if (on_end || this.show_label_in_middle) {
              label_text = i + this.label;
            }
            else {
              label_text = Float.toString(i);
            }
          }
          text(label_text, targetX, this.button.yc);
        }
        else {
          line(targetX, this.button.yc - this.button.yr + 1, targetX, this.button.yc + this.button.yr - 1);
        }
        on_end = false;
      }
    }
    else if (this.show_label) {
      String label_min = "";
      String label_max = "";
      if (this.round_label) {
        label_min = round(this.min_value) + this.label;
        label_max = round(this.max_value) + this.label;
      }
      else {
        label_min = this.min_value + this.label;
        label_max = this.max_value + this.label;
      }
      fill(this.button.active_color);
      text(label_min, this.xi + this.offset, this.button.yc);
      fill(this.button.color_stroke);
      text(label_max, this.xf - this.offset, this.button.yc);
    }
    strokeWeight(this.line_thickness);
    stroke(this.button.active_color);
    line(min(this.xi + this.offset, this.button.xc - this.button.radius()),
      this.yCenter, this.button.xc - this.button.radius(), this.yCenter);
    stroke(this.button.color_stroke);
    line(this.button.xc + this.button.radius(), this.yCenter,
      max(this.xf - this.offset, this.button.xc + this.button.radius()), this.yCenter);
    this.button.update(millis);
  }

  void mouseMove(float mX, float mY) {
    this.button.mouseMove(mX, mY);
    if (mX > this.xi && mY > this.yi && mX < this.xf && mY < this.yf) {
      this.hovered = true;
    }
    else {
      this.hovered = false;
    }
  }

  void mousePress() {
    this.button.mousePress();
    if (this.hovered && !this.button.disabled) {
      this.button.active = true;
      this.button.clicked = true;
      this.button.moveButton(this.button.lastX - this.button.xCenter(), 0);
      Slider.this.refreshValue();
    }
  }

  void mouseRelease(float mX, float mY) {
    this.button.mouseRelease(mX, mY);
  }

  void scroll(int amount) {
    this.button.scroll(amount);
  }

  void keyPress() {
    this.button.keyPress();
  }
}




enum FormFieldSubmit {
  NONE, SUBMIT, CANCEL, BUTTON;
}

abstract class FormField {
  protected String message;
  protected float field_width = 0;

  FormField(String message) {
    this.message = message;
  }

  float getWidth() {
    return this.field_width;
  }
  void setWidth(float new_width) {
    this.field_width = new_width;
    this.updateWidthDependencies();
  }

  void setValue(int newValue) {
    this.setValue(Integer.toString(newValue));
  }
  void setValue(float newValue) {
    this.setValue(Float.toString(newValue));
  }
  void setValue(boolean newValue) {
    this.setValue(Boolean.toString(newValue));
  }

  abstract void enable();
  abstract void disable();

  abstract boolean focusable();
  abstract void focus();
  abstract void defocus();
  abstract boolean focused();

  abstract void updateWidthDependencies();
  abstract float getHeight();
  abstract String getValue();
  abstract void setValue(String newValue);
  void setValueIfNotFocused(String newValue) {
    if (!this.focused()) {
      this.setValue(newValue);
    }
  }

  abstract FormFieldSubmit update(int millis);
  abstract void mouseMove(float mX, float mY);
  abstract void mousePress();
  abstract void mouseRelease(float mX, float mY);
  abstract void keyPress();
  abstract void keyRelease();
  abstract void scroll(int amount);

  abstract void submit();
}


// Spacer
class SpacerFormField extends FormField {
  protected float spacer_height;

  SpacerFormField(float spacer_height) {
    super("");
    this.spacer_height = spacer_height;
  }

  void enable() {}
  void disable() {}
  void updateWidthDependencies() {}

  boolean focusable() {
    return false;
  }
  void focus() {}
  void defocus() {}
  boolean focused() {
    return false;
  }

  float getHeight() {
    return this.spacer_height;
  }

  String getValue() {
    return this.message;
  }
  void setValue(String newValue) {
    this.message = newValue;
  }

  FormFieldSubmit update(int millis) {
    return FormFieldSubmit.NONE;
  }
  void mouseMove(float mX, float mY) {}
  void mousePress() {}
  void mouseRelease(float mX, float mY) {}
  void scroll(int amount) {}
  void keyPress() {}
  void keyRelease() {}
  void submit() {}
}


// One line message
class MessageFormField extends FormField {
  protected String display_message; // can be different if truncated
  protected float default_text_size = 22;
  protected float minimum_text_size = 8;
  protected float text_size = 0;
  protected color text_color = ccolor(0);
  protected int text_align = LEFT;
  protected float left_edge = 1;

  MessageFormField(String message) {
    this(message, LEFT);
  }
  MessageFormField(String message, int text_align) {
    super(message);
    this.display_message = message;
    this.text_align = text_align;
  }

  void setTextSize(float new_text_size) {
    this.setTextSize(new_text_size, false);
  }
  void setTextSize(float new_text_size, boolean force) {
    this.default_text_size = new_text_size;
    if (force) {
      this.minimum_text_size = new_text_size;
    }
    this.updateWidthDependencies();
  }

  void enable() {}
  void disable() {}

  boolean focusable() {
    return false;
  }
  void focus() {}
  void defocus() {}
  boolean focused() {
    return false;
  }

  void updateWidthDependencies() {
    float max_width = this.field_width - 2;
    this.text_size = this.default_text_size;
    textSize(this.text_size);
    this.display_message = this.message;
    while(textWidth(this.display_message) > max_width) {
      this.text_size -= 0.2;
      textSize(this.text_size);
      if (this.text_size < this.minimum_text_size) {
        this.text_size = this.minimum_text_size;
        textSize(this.text_size);
        String truncated_string = "";
        for (int i = 0 ; i < this.display_message.length(); i++) {
          char c = this.display_message.charAt(i);
          if (textWidth(truncated_string + c) <= max_width) {
            truncated_string += c;
          }
          else {
            this.display_message = truncated_string;
            break;
          }
        }
        break;
      }
    }
  }

  float getHeight() {
    textSize(this.text_size);
    return textAscent() + textDescent() + 2;
  }

  String getValue() {
    return this.message;
  }
  void setValue(String newValue) {
    this.message = newValue;
    this.updateWidthDependencies();
  }

  FormFieldSubmit update(int millis) {
    textSize(this.text_size);
    textAlign(this.text_align, TOP);
    fill(this.text_color);
    switch(this.text_align) {
      case RIGHT:
        text(this.display_message, this.field_width - 1, 1);
        break;
      case CENTER:
        text(this.display_message, 0.5 * this.field_width, 1);
        break;
      case LEFT:
      default:
        text(this.display_message, this.left_edge, 1);
        break;
    }
    return FormFieldSubmit.NONE;
  }

  void mouseMove(float mX, float mY) {
  }

  void mousePress() {}
  void mouseRelease(float mX, float mY) {}
  void scroll(int amount) {}
  void keyPress() {}
  void keyRelease() {}
  void submit() {}
}


// Multi-line message
class TextBoxFormField extends FormField {
  protected TextBox textbox = new TextBox(0, 0, 0, 0);

  TextBoxFormField(String message, float box_height) {
    super(message);
    this.textbox.setText(message);
    this.textbox.setLocation(0, 0, 0, box_height);
    this.textbox.color_background = ccolor(255, 0);
    this.textbox.color_header = ccolor(255, 0);
    this.textbox.color_stroke = ccolor(255, 0);
  }

  void enable() {}
  void disable() {}

  boolean focusable() {
    return false;
  }
  void focus() {}
  void defocus() {}
  boolean focused() {
    return false;
  }

  void updateWidthDependencies() {
    this.textbox.setLocation(0, 0, this.field_width, this.getHeight());
  }
  float getHeight() {
    return this.textbox.yf - this.textbox.yi;
  }

  String getValue() {
    return this.textbox.text_ref;
  }
  void setValue(String newValue) {
    this.textbox.setText(newValue);
  }

  FormFieldSubmit update(int millis) {
    this.textbox.update(millis);
    return FormFieldSubmit.NONE;
  }

  void mouseMove(float mX, float mY) {
    this.textbox.mouseMove(mX, mY);
  }

  void mousePress() {
    this.textbox.mousePress();
  }

  void mouseRelease(float mX, float mY) {
    this.textbox.mouseRelease(mX, mY);
  }

  void scroll(int amount) {
    this.textbox.scroll(amount);
  }

  void keyPress() {
    this.textbox.keyPress();
  }
  void keyRelease() {}
  void submit() {}
}


// String input
class StringFormField extends MessageFormField {
  protected InputBox input = new InputBox(0, 0, 0, 0);

  StringFormField(String message) {
    this(message, "");
  }
  StringFormField(String message, String hint) {
    super(message);
    if (hint != null) {
      this.input.hint_text = hint;
    }
  }

  @Override
  boolean focusable() {
    if (this.input.typing) {
      return false;
    }
    return true;
  }
  @Override
  void focus() {
    this.input.typing = true;
  }
  @Override
  void defocus() {
    this.input.typing = false;
  }
  @Override
  boolean focused() {
    return this.input.typing;
  }

  void updateWidthDependencies() {
    float temp_field_width = this.field_width;
    this.field_width = 0.5 * this.field_width;
    super.updateWidthDependencies();
    this.field_width = temp_field_width;
    this.input.setTextSize(this.text_size);
    textSize(this.text_size);
    this.input.setLocation(textWidth(this.message), 0, this.field_width, textAscent() + textDescent() + 2);
  }

  @Override
  String getValue() {
    return this.input.text;
  }
  @Override
  void setValue(String newValue) {
    this.input.setText(newValue);
  }

  @Override
  FormFieldSubmit update(int millis) {
    this.input.update(millis);
    return super.update(millis);
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.input.mouseMove(mX, mY);
  }

  @Override
  void mousePress() {
    this.input.mousePress();
  }

  @Override
  void mouseRelease(float mX, float mY) {
    this.input.mouseRelease(mX, mY);
  }

  @Override
  void keyPress() {
    this.input.keyPress();
  }
  @Override
  void keyRelease() {
    this.input.keyRelease();
  }
}


class IntegerFormField extends StringFormField {
  protected int min_value = 0;
  protected int max_value = 0;

  IntegerFormField(String message) {
    this(message, "");
  }
  IntegerFormField(String message, String hint) {
    this(message, hint, Integer.MIN_VALUE + 1, Integer.MAX_VALUE - 1);
  }
  IntegerFormField(String message, int min, int max) {
    this(message, "", min, max);
  }
  IntegerFormField(String message, String hint, int min, int max) {
    super(message, hint);
    this.min_value = min;
    this.max_value = max;
  }

  int validateInt(int value) {
    if (this.min_value == this.max_value) {
      return value;
    }
    if (value < this.min_value) {
      value = this.min_value;
    }
    else if (value > this.max_value) {
      value = this.max_value;
    }
    return value;
  }

  @Override
  String getValue() {
    int return_value = toInt(this.input.text);
    return_value = this.validateInt(return_value);
    return Integer.toString(return_value);
  }

  void submit() {
    if (this.focused()) {
      return;
    }
    int value = this.validateInt(toInt(this.input.text));
    this.input.setText(Integer.toString(value));
  }
}


class FloatFormField extends StringFormField {
  protected float min_value = 0;
  protected float max_value = 0;

  FloatFormField(String message) {
    this(message, "");
  }
  FloatFormField(String message, String hint) {
    this(message, hint, 0, 0);
  }
  FloatFormField(String message, float min, float max) {
    this(message, "", min, max);
  }
  FloatFormField(String message, String hint, float min, float max) {
    super(message, hint);
    this.min_value = min;
    this.max_value = max;
  }

  @Override
  String getValue() {
    float return_value = toFloat(this.input.text);
    if (return_value < this.min_value) {
      return_value = this.min_value;
    }
    else if (return_value > this.max_value) {
      return_value = this.max_value;
    }
    return Float.toString(return_value);
  }

  void submit() {
    if (this.focused()) {
      return;
    }
    float value = toFloat(this.input.text);
    if (value > this.max_value) {
      value = this.max_value;
    }
    else if (value < this.min_value) {
      value = this.min_value;
    }
    this.input.setText(Float.toString(value));
  }
}


class BooleanFormField extends StringFormField {
  BooleanFormField(String message) {
    this(message, "");
  }
  BooleanFormField(String message, String hint) {
    super(message, hint);
  }

  void submit() {
    if (this.focused()) {
      return;
    }
    this.input.setText(Boolean.toString(toBoolean(this.input.text)));
  }
}


// Array of radio buttons
class RadiosFormField extends MessageFormField {
  class DefaultRadioButton extends RadioButton {
    DefaultRadioButton(String message) {
      super(0, 0, 0);
      this.message = message;
    }
    void hover() {
    }
    void dehover() {
    }
    void release() {
    }
  }

  protected ArrayList<RadioButton> radios = new ArrayList<RadioButton>();
  protected float radio_padding = 6;
  protected int index_selected = -1;
  protected boolean message_first = false;

  RadiosFormField(String message) {
    super(message);
  }

  void addRadio() {
    this.addRadio("");
  }
  void addRadio(String message) {
    this.addRadio(new DefaultRadioButton(message));
  }
  void addDisabledRadio(String message) {
    DefaultRadioButton radio = new DefaultRadioButton(message);
    radio.disabled = true;
    radio.color_text = ccolor(80);
    this.addRadio(radio);
  }
  void addRadio(RadioButton radio) {
    this.radios.add(radio);
    this.updateWidthDependencies();
  }

  @Override
  void updateWidthDependencies() {
    super.updateWidthDependencies();
    float currY = super.getHeight() + this.radio_padding;
    textSize(this.text_size - 2);
    for (RadioButton radio : this.radios) {
      radio.text_size = this.text_size - 2;
      float radius = 0.5 * min(0.8 * (textAscent() + textDescent() + 2),
        abs(this.field_width - textWidth(radio.message) - 2 * this.radio_padding));
      float xc = radius + this.radio_padding;
      if (message_first) {
        xc += textWidth(radio.message) + this.radio_padding;
      }
      float yc = currY + 0.5 * (textAscent() + textDescent() + 2);
      radio.setLocation(xc, yc, radius);
      currY += textAscent() + textDescent() + 2 + this.radio_padding;
    }
  }

  @Override
  float getHeight() {
    float field_height = super.getHeight();
    field_height += this.radios.size() * this.radio_padding;
    boolean first = true;
    for (RadioButton radio : this.radios) {
      textSize(radio.text_size);
      field_height += textAscent() + textDescent() + 2;
    }
    return field_height;
  }

  @Override
  String getValue() {
    return Integer.toString(this.index_selected);
  }
  @Override
  void setValue(String newValue) {
    if (isInt(newValue)) {
      this.index_selected = toInt(newValue);
      this.uncheckOthers();
    }
  }
  void setMessage(String message) {
    super.setValue(message);
  }

  @Override
  FormFieldSubmit update(int millis) {
    FormFieldSubmit returnValue = super.update(millis);
    for (RadioButton radio : this.radios) {
      textSize(radio.text_size);
      textAlign(LEFT, TOP);
      fill(radio.color_text);
      if (this.message_first) {
        text(radio.message, this.radio_padding, radio.yCenter() - radio.radius() + 1);
      }
      else {
        text(radio.message, radio.button_width() + 2 * this.radio_padding, radio.yCenter() - radio.radius() + 1);
      }
      radio.update(millis);
    }
    return returnValue;
  }

  @Override
  void mouseMove(float mX, float mY) {
    for (RadioButton radio : this.radios) {
      radio.mouseMove(mX, mY);
    }
  }

  @Override
  void mousePress() {
    for (int i = 0; i < this.radios.size(); i++) {
      RadioButton radio = this.radios.get(i);
      boolean pressed = radio.checked;
      radio.mousePress();
      if (!pressed && radio.checked) {
        this.index_selected = i;
        this.uncheckOthers();
      }
      else if (pressed && !radio.checked) {
        this.index_selected = -1;
        this.uncheckOthers();
      }
    }
  }

  void uncheckOthers() {
    for (int i = 0; i < this.radios.size(); i++) {
      if (i == this.index_selected) {
        continue;
      }
      this.radios.get(i).checked = false;
    }
  }

  @Override
  void mouseRelease(float mX, float mY) {
    for (RadioButton radio : this.radios) {
      radio.mouseRelease(mX, mY);
    }
  }
}


// Single checkbox
class CheckboxFormField extends MessageFormField {
  class DefaultCheckBox extends CheckBox {
    DefaultCheckBox() {
      super(0, 0, 0, 0);
    }
    void hover() {
    }
    void dehover() {
    }
    void release() {
    }
  }

  protected CheckBox checkbox = new DefaultCheckBox();

  CheckboxFormField(String message) {
    super(message);
  }

  @Override
  void updateWidthDependencies() {
    float temp_field_width = this.field_width;
    this.field_width = 0.75 * this.field_width;
    super.updateWidthDependencies();
    this.field_width = temp_field_width;
    textSize(this.text_size);
    float checkboxsize = min(0.8 * this.getHeight(), this.field_width - textWidth(this.message));
    float xi = textWidth(this.message);
    float yi = 0.5 * (this.getHeight() - checkboxsize);
    this.checkbox.setLocation(xi, yi, xi + checkboxsize, yi + checkboxsize);
  }

  @Override
  String getValue() {
    return Boolean.toString(this.checkbox.checked);
  }
  @Override
  void setValue(String newValue) {
    if (isBoolean(newValue)) {
      this.checkbox.checked = toBoolean(newValue);
    }
  }

  @Override
  FormFieldSubmit update(int millis) {
    this.checkbox.update(millis);
    return super.update(millis);
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.checkbox.mouseMove(mX, mY);
  }

  @Override
  void mousePress() {
    this.checkbox.mousePress();
  }

  @Override
  void mouseRelease(float mX, float mY) {
    this.checkbox.mouseRelease(mX, mY);
  }
}


class ToggleFormFieldInput {
  private String message;
  private PImage img;
  ToggleFormFieldInput(String message, PImage img) {
    this.message = message;
    this.img = img;
  }
}


// Toggle between discreet list of things
class ToggleFormField extends MessageFormField {
  class FormFieldToggleButton extends ToggleButton {
    FormFieldToggleButton(PImage[] images) {
      super(images, 0, 0, 0, 0);
      this.use_time_elapsed = true;
      this.overshadow_colors = true;
      this.setColors(color(170, 170), ccolor(1, 0), ccolor(100, 80), ccolor(200, 160), ccolor(0));
    }
    @Override
    void toggle() {
      super.toggle();
      ToggleFormField.this.toggle();
    }
    void hover() {
    }
    void dehover() {
    }
  }

  protected FormFieldToggleButton toggle;
  protected ArrayList<String> messages = new ArrayList<String>();

  ToggleFormField(ArrayList<ToggleFormFieldInput> message_to_images) {
    super("");
    PImage[] imgs = new PImage[message_to_images.size()];
    for (int i = 0; i < message_to_images.size(); i++) {
      this.messages.add(message_to_images.get(i).message);
      imgs[i] = message_to_images.get(i).img;
    }
    this.toggle = new FormFieldToggleButton(imgs);
    this.toggle();
  }

  void toggle() {
    super.setValue(this.messages.get(this.toggle.toggle_index));
    this.updateWidthDependencies();
  }

  @Override
  void updateWidthDependencies() {
    float temp_field_width = this.field_width;
    this.field_width = 0.75 * this.field_width;
    super.updateWidthDependencies();
    this.field_width = temp_field_width;
    textSize(this.text_size);
    float togglesize = min(0.95 * this.getHeight(), this.field_width - textWidth(this.message) - 2);
    float xi = textWidth(this.message);
    float yi = 0.5 * (this.getHeight() - togglesize);
    this.toggle.setLocation(1, yi, togglesize, yi + togglesize);
    this.left_edge = 2 + togglesize;
  }

  @Override
  String getValue() {
    return Integer.toString(this.toggle.toggle_index);
  }
  @Override
  void setValue(String newValue) {
    if (isInt(newValue)) {
      this.toggle.setToggle(toInt(newValue));
      this.toggle();
    }
  }

  @Override
  FormFieldSubmit update(int millis) {
    this.toggle.update(millis);
    return super.update(millis);
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.toggle.mouseMove(mX, mY);
  }

  @Override
  void mousePress() {
    this.toggle.mousePress();
  }

  @Override
  void mouseRelease(float mX, float mY) {
    this.toggle.mouseRelease(mX, mY);
  }
}


// Slider
class SliderFormField extends MessageFormField {
  class DefaultCheckBox extends CheckBox {
    DefaultCheckBox() {
      super(0, 0, 0, 0);
    }
    void hover() {
    }
    void dehover() {
    }
    void release() {
    }
  }

  protected Slider slider = new Slider();
  protected CheckBox checkbox = null;
  protected float max_slider_height = 30;
  protected float threshhold = 0.2;

  SliderFormField(String message, float max) {
    this(message, 0, max, -1);
  }
  SliderFormField(String message, float min, float max) {
    this(message, min, max, -1);
  }
  SliderFormField(String message, float min, float max, float step) {
    super(message);
    this.text_align = RIGHT;
    this.slider.bounds(min, max, step);
    this.slider.setValue(min);
  }

  void addCheckbox(String message) {
    this.checkbox = new DefaultCheckBox();
    this.checkbox.message = message;
    this.updateWidthDependencies();
  }

  void addLabel(String label, boolean round_label) {
    this.addLabel(label, round_label, this.slider.only_label_ends);
  }
  void addLabel(String label, boolean round_label, boolean only_label_ends) {
    this.slider.show_label = true;
    this.slider.label = label;
    this.slider.round_label = round_label;
    this.slider.only_label_ends = only_label_ends;
  }

  @Override
  void disable() {
    this.slider.disable();
    if (this.checkbox != null) {
      this.checkbox.checked = true;
    }
  }
  @Override
  void enable() {
    this.slider.enable();
    if (this.checkbox != null) {
      this.checkbox.checked = false;
    }
  }

  @Override
  boolean focusable() {
    if (this.slider.button.active) {
      return false;
    }
    return true;
  }
  @Override
  void focus() {
    this.slider.button.active = true;
  }
  @Override
  void defocus() {
    this.slider.button.active = false;
  }
  @Override
  boolean focused() {
    return this.slider.button.active;
  }

  @Override
  void updateWidthDependencies() {
    float temp_field_width = this.field_width;
    this.field_width = this.threshhold * this.field_width;
    super.updateWidthDependencies();
    float buffer_width = 0.02 * this.field_width;
    this.field_width = temp_field_width;
    float sliderheight = min(this.getHeight(), this.max_slider_height);
    if (this.checkbox != null) {
      this.checkbox.text_size = 0.75 * this.text_size;
      textSize(this.checkbox.text_size);
      float checkboxsize = 0.8 * (textAscent() + textDescent() + 2);
      buffer_width += textWidth(this.checkbox.message) + 0.02 * this.field_width;
      float xi = this.threshhold * this.field_width + buffer_width;
      float yi = 0.5 * (this.getHeight() - checkboxsize);
      this.checkbox.setLocation(xi, yi, xi + checkboxsize, yi + checkboxsize);
      buffer_width += checkboxsize + 0.02 * this.field_width;
    }
    float xi = this.threshhold * this.field_width + buffer_width;
    float yi = 0.5 * (this.getHeight() - sliderheight);
    this.slider.setLocation(xi, yi, this.field_width, yi + sliderheight);
  }

  @Override
  String getValue() {
    if (this.checkbox != null && this.checkbox.checked) {
      return Float.toString(this.slider.value) + ":disabled";
    }
    return Float.toString(this.slider.value);
  }
  @Override
  void setValue(String newValue) {
    if (isFloat(newValue)) {
      this.slider.setValue(toFloat(newValue));
    }
  }

  @Override
  FormFieldSubmit update(int millis) {
    this.slider.update(millis);
    float temp_field_width = this.field_width;
    this.field_width = this.threshhold * this.field_width;
    super.update(millis);
    this.field_width = temp_field_width;
    if (this.checkbox != null) {
      textSize(this.checkbox.text_size);
      fill(this.checkbox.color_text);
      textAlign(RIGHT, CENTER);
      text(this.checkbox.message, this.checkbox.xi - 1, this.checkbox.yCenter());
      this.checkbox.update(millis);
    }
    return FormFieldSubmit.NONE;
  }

  @Override
  void mouseMove(float mX, float mY) {
    this.slider.mouseMove(mX, mY);
    if (this.checkbox != null) {
      this.checkbox.mouseMove(mX, mY);
    }
  }

  @Override
  void mousePress() {
    this.slider.mousePress();
    if (this.checkbox != null) {
      this.checkbox.mousePress();
      if (this.checkbox.checked) {
        this.disable();
      }
      else {
        this.enable();
      }
    }
  }

  @Override
  void mouseRelease(float mX, float mY) {
    this.slider.mouseRelease(mX, mY);
    if (this.checkbox != null) {
      this.checkbox.mouseRelease(mX, mY);
    }
  }

  @Override
  void scroll(int amount) {
    this.slider.scroll(amount);
  }

  @Override
  void keyPress() {
    this.slider.keyPress();
  }
}


// Submit button (submits and cancels)
class SubmitFormField extends FormField {
  class SubmitButton extends RectangleButton {
    SubmitButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      this.roundness = 0;
      this.raised_body = true;
      this.raised_border = true;
      this.adjust_for_text_descent = true;
    }
    void hover() {
    }
    void dehover() {
    }
    void click() {
    }
    void release() {
      if (this.hovered || this.button_focused) {
        SubmitFormField.this.submitted = true;
      }
    }
  }

  protected RectangleButton button = new SubmitButton(0, 0, 0, 30);
  protected boolean submitted = false;
  protected boolean submit_button = true;
  protected boolean extend_width = false;
  protected boolean align_left = false;

  SubmitFormField(String message) {
    this(message, true);
  }
  SubmitFormField(String message, boolean submit_button) {
    super(message);
    this.button.message = message;
    this.button.show_message = true;
    this.submit_button = submit_button;
  }

  void setButtonHeight(float new_height) {
    if (new_height < 0) {
      new_height = 0;
    }
    this.button.setYLocation(0, new_height);
  }

  void disable() {
    this.button.disabled = true;
  }
  void enable() {
    this.button.disabled = false;
  }

  boolean focusable() {
    if (this.button.button_focused) {
      return false;
    }
    return true;
  }
  void focus() {
    this.button.button_focused = true;
  }
  void defocus() {
    this.button.button_focused = false;
  }
  boolean focused() {
    return this.button.button_focused;
  }

  void updateWidthDependencies() {
    textSize(this.button.text_size);
    float desiredWidth = textWidth(this.button.message) + textWidth("  ");
    if (desiredWidth > this.field_width || this.extend_width) {
      this.button.setXLocation(0, this.field_width);
    }
    else if (this.align_left) {
      this.button.setXLocation(4, desiredWidth + 4);
    }
    else {
      this.button.setXLocation(0.5 * (this.field_width - desiredWidth),
        0.5 * (this.field_width + desiredWidth));
    }
  }

  float getHeight() {
    return this.button.yf - this.button.yi;
  }

  String getValue() {
    return this.message;
  }
  @Override
  void setValue(String newValue) {
    if (isBoolean(newValue)) {
      this.submit_button = toBoolean(newValue);
    }
  }

  FormFieldSubmit update(int millis) {
    this.button.update(millis);
    if (this.submitted) {
      this.submitted = false;
      if (this.submit_button) {
        return FormFieldSubmit.SUBMIT;
      }
      else {
        return FormFieldSubmit.CANCEL;
      }
    }
    return FormFieldSubmit.NONE;
  }

  void mouseMove(float mX, float mY) {
    this.button.mouseMove(mX, mY);
  }

  void mousePress() {
    this.button.mousePress();
  }

  void mouseRelease(float mX, float mY) {
    this.button.mouseRelease(mX, mY);
  }

  void scroll(int amount) {
  }

  void keyPress() {
    this.button.keyPress();
  }
  void keyRelease() {
    this.button.keyRelease();
  }
  void submit() {}
}


class ButtonFormField extends SubmitFormField {
  ButtonFormField(String message) {
    super(message, true);
  }

  @Override
  FormFieldSubmit update(int millis) {
    if (super.update(millis) != FormFieldSubmit.NONE) {
      return FormFieldSubmit.BUTTON;
    }
    return FormFieldSubmit.NONE;
  }
}


class SubmitCancelFormField extends FormField {
  class SubmitCancelButton extends RectangleButton {
    protected boolean submit;

    SubmitCancelButton(float xi, float yi, float xf, float yf, boolean submit) {
      super(xi, yi, xf, yf);
      this.submit = submit;
      this.roundness = 0;
      this.raised_body = true;
      this.raised_border = true;
      this.adjust_for_text_descent = true;
    }
    void hover() {
    }
    void dehover() {
    }
    void click() {
    }
    void release() {
      if (this.hovered || this.button_focused) {
        if (this.submit) {
          SubmitCancelFormField.this.submitted = true;
        }
        else {
          SubmitCancelFormField.this.canceled = true;
        }
      }
    }
  }

  protected SubmitCancelButton button1 = new SubmitCancelButton(0, 0, 0, 30, true);
  protected SubmitCancelButton button2 = new SubmitCancelButton(0, 0, 0, 30, false);
  protected boolean submitted = false;
  protected boolean canceled = false;
  protected float gapSize = 10;

  SubmitCancelFormField(String message1, String message2) {
    super(message1);
    this.button1.message = message1;
    this.button1.show_message = true;
    this.button2.message = message2;
    this.button2.show_message = true;
  }

  void setButtonHeight(float new_height) {
    if (new_height < 0) {
      new_height = 0;
    }
    this.button1.setYLocation(0, new_height);
    this.button2.setYLocation(0, new_height);
  }

  void disable() {
    this.button1.disabled = true;
    this.button2.disabled = true;
  }
  void enable() {
    this.button1.disabled = false;
    this.button2.disabled = false;
  }

  boolean focusable() {
    if (this.button2.button_focused) {
      return false;
    }
    return true;
  }
  void focus() {
    if (this.button1.button_focused) {
      this.button1.button_focused = false;
      this.button2.button_focused = true;
    }
    else {
      this.button1.button_focused = true;
      this.button2.button_focused = false;
    }
  }
  void defocus() {
    this.button1.button_focused = false;
    this.button2.button_focused = false;
  }
  boolean focused() {
    if (this.button1.button_focused || this.button2.button_focused) {
      return true;
    }
    return false;
  }

  void updateWidthDependencies() {
    textSize(this.button1.text_size);
    float desiredWidth1 = textWidth(this.button1.message) + textWidth("  ");
    textSize(this.button2.text_size);
    float desiredWidth2 = textWidth(this.button2.message) + textWidth("  ");
    if (this.gapSize > this.field_width) {
      this.button1.setXLocation(0, 0);
      this.button2.setXLocation(0, 0);
    }
    else if (desiredWidth1 + this.gapSize + desiredWidth2 > this.field_width) {
      this.button1.setXLocation(0, 0.5 * (this.field_width - this.gapSize));
      this.button2.setXLocation(0.5 * (this.field_width + gapSize), this.field_width);
    }
    else if (2 * max(desiredWidth1, desiredWidth2) + this.gapSize > this.field_width) {
      this.button1.setXLocation(0.5 * (this.field_width - this.gapSize) - desiredWidth1, 0.5 * (this.field_width - this.gapSize));
      this.button2.setXLocation(0.5 * (this.field_width + this.gapSize), 0.5 * (this.field_width + this.gapSize) + desiredWidth2);
    }
    else {
      this.button1.setXLocation(0.5 * (this.field_width - this.gapSize) - max(desiredWidth1, desiredWidth2), 0.5 * (this.field_width - this.gapSize));
      this.button2.setXLocation(0.5 * (this.field_width + this.gapSize), 0.5 * (this.field_width + this.gapSize) + max(desiredWidth1, desiredWidth2));
    }
  }

  float getHeight() {
    return max(this.button1.yf - this.button1.yi, this.button2.yf - this.button2.yi);
  }

  String getValue() {
    return this.message;
  }
  @Override
  void setValue(String newValue) {
    this.message = newValue;
  }

  FormFieldSubmit update(int millis) {
    this.button1.update(millis);
    this.button2.update(millis);
    if (this.submitted) {
      this.submitted = false;
      return FormFieldSubmit.SUBMIT;
    }
    else if (this.canceled) {
      this.canceled = false;
      return FormFieldSubmit.CANCEL;
    }
    return FormFieldSubmit.NONE;
  }

  void mouseMove(float mX, float mY) {
    this.button1.mouseMove(mX, mY);
    this.button2.mouseMove(mX, mY);
  }

  void mousePress() {
    this.button1.mousePress();
    this.button2.mousePress();
  }

  void mouseRelease(float mX, float mY) {
    this.button1.mouseRelease(mX, mY);
    this.button2.mouseRelease(mX, mY);
  }

  void scroll(int amount) {
  }

  void keyPress() {
    this.button1.keyPress();
    this.button2.keyPress();
  }
  void keyRelease() {
    this.button1.keyRelease();
    this.button2.keyRelease();
  }
  void submit() {}
}



class ButtonsFormField extends SubmitCancelFormField {
  protected int last_button_pressed = -1;

  ButtonsFormField(String message1, String message2) {
    super(message1, message2);
  }

  @Override
  String getValue() {
    return Integer.toString(this.last_button_pressed);
  }
  @Override
  void setValue(String newValue) {
    if (isInt(newValue)) {
      this.last_button_pressed = toInt(newValue);
    }
    else {
      this.last_button_pressed = -1;
    }
  }

  @Override
  FormFieldSubmit update(int millis) {
    this.button1.update(millis);
    this.button2.update(millis);
    if (this.submitted) {
      this.submitted = false;
      this.last_button_pressed = 0;
      return FormFieldSubmit.BUTTON;
    }
    else if (this.canceled) {
      this.canceled = false;
      this.last_button_pressed = 1;
      return FormFieldSubmit.BUTTON;
    }
    this.last_button_pressed = -1;
    return FormFieldSubmit.NONE;
  }
}



abstract class Form {
  class CancelButton extends RectangleButton {
    CancelButton(float xi, float yi, float xf, float yf) {
      super(xi, yi, xf, yf);
      this.roundness = 0;
      this.setColors(color(170), ccolor(240, 30, 30), ccolor(255, 60, 60), ccolor(180, 0, 0), ccolor(0));
      this.color_stroke = ccolor(0, 1);
    }
    @Override
    void drawButton() {
      super.drawButton();
      stroke(ccolor(0));
      strokeWeight(1.5);
      float offset = 0.05 * this.button_width();
      line(this.xi + offset, this.yi + offset, this.xf - offset, this.yf - offset);
      line(this.xi + offset, this.yf - offset, this.xf - offset, this.yi + offset);
    }
    void hover() {
    }
    void dehover() {
    }
    void click() {
    }
    void release() {
      if (this.hovered) {
        Form.this.cancelForm();
      }
    }
  }

  protected float xi = 0;
  protected float yi = 0;
  protected float xf = 0;
  protected float yf = 0;
  protected boolean hovered = false;
  protected CancelButton cancel;

  protected ScrollBar scrollbar = new ScrollBar(0, 0, 0, 0, true);
  protected float scrollbar_max_width = 40;
  protected float scrollbar_min_width = 20;
  protected float scrollbar_width_multiplier = 0.05;

  protected ArrayList<FormField> fields = new ArrayList<FormField>();
  protected float fieldCushion = 20;
  protected float yStart = 0;

  protected String text_title_ref = null;
  protected String text_title = null;
  protected float title_size = 22;

  protected color color_background = ccolor(210);
  protected color color_header = ccolor(170);
  protected color color_stroke = ccolor(0);
  protected color color_title = ccolor(0);

  protected boolean draggable = false;
  protected boolean hovered_header = false;
  protected boolean dragging = false;
  protected float dragX = 0;
  protected float dragY = 0;
  protected float max_x = width;
  protected float min_x = 0;
  protected float max_y = height;
  protected float min_y = 0;

  Form() {
    this(0, 0, 0, 0);
  }
  Form(float xi, float yi, float xf, float yf) {
    this.setLocation(xi, yi, xf, yf);
  }

  void cancelButton() {
    textSize(this.title_size);
    this.cancelButton(textAscent() + textDescent() + 1);
  }
  void cancelButton(float size) {
    this.cancel = new CancelButton(this.xf - size, this.yi + 1, this.xf, this.yi + size);
    this.refreshTitle();
  }

  float form_width() {
    return this.xf - this.xi;
  }
  float form_height() {
    return this.yf - this.yi;
  }

  float xCenter() {
    return this.xi + 0.5 * (this.xf - this.xi);
  }
  float yCenter() {
    return this.yi + 0.5 * (this.yf - this.yi);
  }

  void setLocation(float xi, float yi, float xf, float yf) {
    this.xi = xi;
    this.yi = yi;
    this.xf = xf;
    this.yf = yf;
    this.refreshTitle();
    for (FormField field : this.fields) {
      field.setWidth(this.xf - this.xi - 3 - this.scrollbar.bar_size);
    }
  }
  void setXLocation(float xi, float xf) {
    this.xi = xi;
    this.xf = xf;
    this.refreshTitle();
    for (FormField field : this.fields) {
      field.setWidth(this.xf - this.xi - 3 - this.scrollbar.bar_size);
    }
  }
  void setYLocation(float yi, float yf) {
    this.yi = yi;
    this.yf = yf;
    this.refreshTitle();
  }

  void moveForm(float xMove, float yMove) {
    this.xi += xMove;
    this.yi += yMove;
    this.xf += xMove;
    this.yf += yMove;
    this.scrollbar.move(xMove, yMove);
    if (this.cancel != null) {
      this.cancel.moveButton(xMove, yMove);
    }
    this.yStart += yMove;
    if (this.xi >= this.max_x || this.xf <= this.min_x || (this.cancel != null && this.xf <= this.cancel.button_width())
      || this.yi >= this.max_y || this.yStart <= this.min_y) {
      this.toCenter();
      this.dragging = false;
    }
  }

  void toCenter() {
    float xMove = 0.5 * (width - this.form_width()) - this.xi;
    float yMove = 0.5 * (height - this.form_height()) - this.yi;
    this.moveForm(xMove, yMove);
  }

  void refreshTitle() {
    this.setTitleText(this.text_title_ref);
  }
  void setTitleSize(float title_size) {
    this.title_size = title_size;
    this.refreshTitle();
    if (this.cancel != null) {
      textSize(this.title_size);
      if (this.cancel.button_height() > textAscent() + textDescent() + 1) {
        this.cancelButton();
      }
    }
  }
  void setTitleText(String title) {
    this.text_title_ref = title;
    float scrollbar_width = min(this.scrollbar_max_width, this.scrollbar_width_multiplier * (this.xf - this.xi));
    scrollbar_width = max(this.scrollbar_min_width, scrollbar_width);
    scrollbar_width = min(this.scrollbar_width_multiplier * (this.xf - this.xi), scrollbar_width);
    if (title == null) {
      this.text_title = null;
      this.scrollbar.setLocation(this.xf - scrollbar_width, this.yi, this.xf, this.yf);
      this.yStart = this.yi + 1;
    }
    else {
      this.text_title = "";
      textSize(this.title_size);
      for (int i = 0; i < title.length(); i++) {
        char nextChar = title.charAt(i);
        if (textWidth(this.text_title + nextChar) < this.xf - this.xi - 3) {
          this.text_title += nextChar;
        }
        else {
          break;
        }
      }
      this.yStart = this.yi + 2 + textAscent() + textDescent();
      this.scrollbar.setLocation(xf - scrollbar_width, this.yStart, this.xf, this.yf);
    }
  }

  void setFieldCushion(float fieldCushion) {
    this.fieldCushion = fieldCushion;
    this.refreshScrollbar();
  }


  void addField(FormField field) {
    field.setWidth(this.xf - this.xi - 3 - this.scrollbar.bar_size);
    this.fields.add(field);
    this.refreshScrollbar();
  }

  void removeField(int index) {
    if (index < 0 || index >= this.fields.size()) {
      return;
    }
    this.fields.remove(index);
    this.refreshScrollbar();
  }

  void clearFields() {
    this.fields.clear();
    this.refreshScrollbar();
  }

  void refreshScrollbar() {
    float currY = this.yStart;
    for (int i = 0; i < this.fields.size(); i++) {
      currY += this.fields.get(i).getHeight();
      if (i > 0) {
        currY += this.fieldCushion;
      }
      if (currY + 2 > this.yf) {
        this.scrollbar.updateMaxValue(this.fields.size());
        return;
      }
    }
    this.scrollbar.updateMaxValue(0);
  }


  void update(int millis) {
    rectMode(CORNERS);
    fill(this.color_background);
    stroke(this.color_stroke);
    strokeWeight(1);
    rect(this.xi, this.yi, this.xf, this.yf);
    if (this.text_title_ref != null) {
      fill(this.color_header);
      textSize(this.title_size);
      rect(this.xi, this.yi, this.xf, this.yi + textAscent() + textDescent() + 1);
      fill(this.color_title);
      textAlign(CENTER, TOP);
      float center = this.xi + 0.5 * (this.xf - this.xi);
      if (this.cancel != null) {
        center -= 0.5 * this.cancel.button_width();
      }
      text(this.text_title, center, this.yi + 1);
    }
    if (this.cancel != null) {
      this.cancel.update(millis);
    }
    float currY = this.yStart;
    translate(this.xi + 1, 0);
    for (int i = int(floor(this.scrollbar.value)); i < this.fields.size(); i++) {
      if (currY + this.fields.get(i).getHeight() > this.yf) {
        break;
      }
      translate(0, currY);
      FormFieldSubmit submit = this.fields.get(i).update(millis);
      if (submit == FormFieldSubmit.SUBMIT) {
        this.submitForm();
      }
      else if (submit == FormFieldSubmit.CANCEL) {
        this.cancelForm();
      }
      else if (submit == FormFieldSubmit.BUTTON) { // alternate button
        this.buttonPress(i);
      }
      translate(0, -currY);
      currY += this.fields.get(i).getHeight() + this.fieldCushion;
    }
    translate(-this.xi - 1, 0);
    if (this.scrollbar.maxValue != this.scrollbar.minValue) {
      this.scrollbar.update(millis);
    }
  }

  void mouseMove(float mX, float mY) {
    this.scrollbar.mouseMove(mX, mY);
    if (this.cancel != null) {
      this.cancel.mouseMove(mX, mY);
    }
    if (this.dragging) {
      this.moveForm(mouseX - this.dragX, mouseY - this.dragY);
      this.dragX = mouseX;
      this.dragY = mouseY;
    }
    this.hovered_header = false;
    if (mX > this.xi && mX < this.xf && mY > this.yi && mY < this.yf) {
      this.hovered = true;
      if (this.text_title_ref != null) {
        if (mY < this.yStart) {
          if (this.cancel == null || !this.cancel.hovered) {
            this.hovered_header = true;
          }
        }
      }
    }
    else {
      this.hovered = false;
    }
    mX -= this.xi + 1;
    mY -= this.yStart;
    float currY = this.yStart;
    for (int i = int(floor(this.scrollbar.value)); i < this.fields.size(); i++) {
      if (currY + this.fields.get(i).getHeight() > this.yf) {
        break;
      }
      this.fields.get(i).mouseMove(mX, mY);
      mY -= this.fields.get(i).getHeight() + this.fieldCushion;
      currY += this.fields.get(i).getHeight() + this.fieldCushion;
    }
  }

  void mousePress() {
    this.scrollbar.mousePress();
    if (this.cancel != null) {
      this.cancel.mousePress();
    }
    for (int i = 0; i < int(floor(this.scrollbar.value)); i++) {
      this.fields.get(i).defocus();
    }
    float currY = this.yStart;
    for (int i = int(floor(this.scrollbar.value)); i < this.fields.size(); i++) {
      if (currY + this.fields.get(i).getHeight() > this.yf) {
        this.fields.get(i).defocus();
        continue;
      }
      this.fields.get(i).mousePress();
      currY += this.fields.get(i).getHeight() + this.fieldCushion;
    }
    if (this.hovered_header && this.draggable) {
      this.dragging = true;
      this.dragX = mouseX;
      this.dragY = mouseY;
    }
  }

  void mouseRelease(float mX, float mY) {
    this.scrollbar.mouseRelease(mX, mY);
    if (this.cancel != null) {
      this.cancel.mouseRelease(mX, mY);
    }
    mX -= this.xi + 1;
    mY -= this.yStart;
    float currY = this.yStart;
    for (int i = int(floor(this.scrollbar.value)); i < this.fields.size(); i++) {
      if (currY + this.fields.get(i).getHeight() > this.yf) {
        break;
      }
      this.fields.get(i).mouseRelease(mX, mY);
      mY -= this.fields.get(i).getHeight() + this.fieldCushion;
      currY += this.fields.get(i).getHeight() + this.fieldCushion;
    }
    this.dragging = false;
  }

  void scroll(int amount) {
    if (this.hovered) {
      this.scrollbar.increaseValue(amount);
    }
    for (FormField field : this.fields) {
      field.scroll(amount);
    }
  }

  void keyPress() {
    for (FormField field : this.fields) {
      field.keyPress();
    }
    if (key != CODED && key == TAB) {
      this.focusNextField();
    }
  }

  void focusNextField() {
    int field_focused = 0;
    for (int i = 0; i < this.fields.size(); i++) {
      if (this.fields.get(i).focused()) {
        field_focused = i;
        break;
      }
    }
    ClockInt index = new ClockInt(0, this.fields.size() - 1, field_focused);
    for (int i = 0; i < this.fields.size(); i++, index.add(1)) {
      if (this.fields.get(index.value).focusable()) {
        this.fields.get(index.value).focus();
        break;
      }
    }
    if (index.value != field_focused) {
      this.fields.get(field_focused).defocus();
    }
  }

  void keyRelease() {
    for (FormField field : this.fields) {
      field.keyRelease();
    }
  }


  void submitForm() {
    for (FormField field : this.fields) {
      field.submit();
    }
    this.submit();
  }

  void cancelForm() {
    this.cancel();
  }

  abstract void submit();
  abstract void cancel();
  abstract void buttonPress(int i);
}





class ClockInt {
  protected int min;
  protected int max;
  protected int value;

  ClockInt(int max) {
    this(0, max, int(random(max)));
  }
  ClockInt(int max, int start) {
    this(0, max, start);
  }
  ClockInt(int min, int max, int start) {
    if (min > max) {
      this.min = max;
      this.max = min;
    }
    else {
      this.min = min;
      this.max = max;
    }
    this.value = start;
    this.resolve();
  }

  void resolve() {
    this.value = this.min + (this.value - this.min) % (this.max - this.min + 1);
  }

  void add(int amount) {
    this.value += amount;
    this.resolve();
  }

  void set(int amount) {
    this.value = amount;
    this.resolve();
  }
}


class ClockFloat {
  protected float min;
  protected float max;
  protected float value;

  ClockFloat(float max) {
    this(0, max, random(max));
  }
  ClockFloat(float max, float start) {
    this(0, max, start);
  }
  ClockFloat(float min, float max, float start) {
    if (min > max) {
      this.min = max;
      this.max = min;
    }
    else {
      this.min = min;
      this.max = max;
    }
    this.value = start;
    this.resolve();
  }

  void resolve() {
    if (this.min == this.max) {
      this.value = this.min;
    }
    else {
      this.value = this.min + (this.value - this.min) % (this.max - this.min);
    }
  }

  void add(float amount) {
    this.value += amount;
    this.resolve();
  }

  void set(float amount) {
    this.value = amount;
    this.resolve();
  }
}

class BounceInt {
  protected int min;
  protected int max;
  protected int value;
  protected boolean moving_forward = true;

  BounceInt(int max) {
    this(0, max, int(random(max)));
  }
  BounceInt(int max, int start) {
    this(0, max, start);
  }
  BounceInt(int min, int max, int start) {
    if (min > max) {
      this.min = max;
      this.max = min;
    }
    else {
      this.min = min;
      this.max = max;
    }
    this.value = start;
    this.resolve();
  }

  void resolve() {
    while(true) {
      if (this.moving_forward) {
        if (this.value > this.max) {
          this.moving_forward = false;
          this.value = this.max + this.max - this.value;
          continue;
        }
        else {
          break;
        }
      }
      else {
        if (this.value < this.min) {
          this.moving_forward = true;
          this.value = this.min + this.min - this.value;
          continue;
        }
        else {
          break;
        }
      }
    }
  }

  void add(int amount) {
    if (this.moving_forward) {
      this.value += amount;
    }
    else {
      this.value -= amount;
    }
    this.resolve();
  }

  void set(int amount) {
    this.value = amount;
    this.resolve();
  }
}

class BounceFloat {
  protected float min;
  protected float max;
  protected float value;
  protected boolean moving_forward = true;

  BounceFloat(float max) {
    this(0, max, random(max));
  }
  BounceFloat(float max, float start) {
    this(0, max, start);
  }
  BounceFloat(float min, float max, float start) {
    if (min > max) {
      this.min = max;
      this.max = min;
    }
    else {
      this.min = min;
      this.max = max;
    }
    this.value = start;
    this.resolve();
  }

  void resolve() {
    while(true) {
      if (this.moving_forward) {
        if (this.value > this.max) {
          this.moving_forward = false;
          this.value = this.max + this.max - this.value;
          continue;
        }
        else {
          break;
        }
      }
      else {
        if (this.value < this.min) {
          this.moving_forward = true;
          this.value = this.min + this.min - this.value;
          continue;
        }
        else {
          break;
        }
      }
    }
  }

  void add(float amount) {
    if (this.moving_forward) {
      this.value += amount;
    }
    else {
      this.value -= amount;
    }
    this.resolve();
  }

  void set(float amount) {
    this.value = amount;
    this.resolve();
  }
}




class Panel {
  class PanelButton extends RectangleButton {
    protected float image_rotation = 0;
    protected float image_rotation_speed = 0.01;
    protected float image_rotation_target = 0;
    protected PImage icon;
    protected boolean removed = false;

    PanelButton() {
      super(0, 0, 0, 0);
      this.setColors(color(220), ccolor(1, 0), ccolor(170, 80), ccolor(170, 180), ccolor(0));
      this.noStroke();
      this.roundness = 0;
      this.hover_check_after_release = false;
    }

    @Override
    void update(int millis) {
      if (this.removed) {
        return;
      }
      super.update(millis);
      if (this.icon != null) {
        float rotate_change = (millis - Panel.this.lastUpdateTime) * this.image_rotation_speed;
        if (this.image_rotation < this.image_rotation_target) {
          this.image_rotation += rotate_change;
          if (this.image_rotation > this.image_rotation_target) {
            this.image_rotation = this.image_rotation_target;
          }
        }
        else if (this.image_rotation > this.image_rotation_target) {
          this.image_rotation -= rotate_change;
          if (this.image_rotation < this.image_rotation_target) {
            this.image_rotation = this.image_rotation_target;
          }
        }
        translate(this.xCenter(), this.yCenter());
        rotate(this.image_rotation);
        imageMode(CENTER);
        image(this.icon, 0, 0, this.button_width(), this.button_height());
        rotate(-this.image_rotation);
        translate(-this.xCenter(), -this.yCenter());
      }
    }

    void hover() {}
    void dehover() {}
    void click() {}
    void release() {
      if (this.removed) {
        return;
      }
      if (this.hovered) {
        Panel.this.collapse();
        this.hovered = false;
      }
    }
  }


  protected int location;
  protected float size_min;
  protected float size_max;
  protected float size_curr;
  protected float size;

  protected boolean hovered = false;
  protected boolean cant_resize = false;
  protected boolean clicked = false;
  protected float hovered_delta = 5;

  protected boolean open = true;
  protected boolean collapsing = false;
  protected float collapse_speed = 1.2;
  protected int lastUpdateTime = 0;
  protected PImage img;

  protected PanelButton button = new PanelButton();
  protected float panelButtonSize = 30;

  protected color color_background = ccolor(220);

  Panel(int location, float size) {
    this(location, size, size, size);
  }
  Panel(int location, float size_min, float size_max, float size) {
    switch(location) {
      case LEFT:
      case RIGHT:
      case UP:
      case DOWN:
        this.location = location;
        break;
      default:
        this.location = LEFT;
        break;
    }
    this.size_min = size_min;
    this.size_max = size_max;
    this.size_curr = size;
    this.size = size;
    this.resetButtonLocation();
  }


  void resetButtonLocation() {
    switch(this.location) {
      case LEFT:
        this.button.setLocation(this.size, 0, this.size + this.panelButtonSize, this.panelButtonSize);
        if (this.open) {
          this.button.image_rotation_target = -HALF_PI;
        }
        else {
          this.button.image_rotation_target = HALF_PI;
        }
        break;
      case RIGHT:
        this.button.setLocation(width - this.size - this.panelButtonSize, 0, width - this.size, this.panelButtonSize);
        if (this.open) {
          this.button.image_rotation_target = HALF_PI;
        }
        else {
          this.button.image_rotation_target = -HALF_PI;
        }
        break;
      case UP:
        this.button.setLocation(width - this.panelButtonSize, this.size, width, this.size + this.panelButtonSize);
          if (this.open) {
            this.button.image_rotation_target = 0;
          }
          else {
            this.button.image_rotation_target = PI;
          }
        break;
      case DOWN:
        this.button.setLocation(width - this.panelButtonSize, height - this.size - this.panelButtonSize, width, height - this.size);
          if (this.open) {
            this.button.image_rotation_target = PI;
          }
          else {
            this.button.image_rotation_target = 0;
          }
        break;
    }
  }
  void addIcon(PImage icon) {
    this.button.icon = icon;
  }
  void removeButton() {
    this.button.removed = true;
  }

  void changeSize(float size_delta) {
    if (this.size_curr + size_delta > this.size_max) {
      this.size_curr = this.size_max;
    }
    else if (this.size_curr + size_delta < this.size_min) {
      this.size_curr = this.size_min;
    }
    else {
      this.size_curr += size_delta;
    }
    if (this.open) {
      this.size = this.size_curr;
    }
    this.resetButtonLocation();
  }


  void collapse() {
    this.collapsing = true;
    switch(this.location) {
      case LEFT:
        this.img = getCurrImage(0, 0, int(round(this.size_curr)), height);
        break;
      case RIGHT:
        this.img = getCurrImage(width - int(round(this.size_curr)), 0, width, height);
        break;
      case UP:
        this.img = getCurrImage(0, 0, width, int(round(this.size_curr)));
        break;
      case DOWN:
        this.img = getCurrImage(0, height - int(round(this.size_curr)), width, height);
        break;
    }
  }


  void update(int millis) {
    int timeElapsed = millis - this.lastUpdateTime;
    this.button.update(millis);
    rectMode(CORNER);
    fill(this.color_background);
    noStroke();
    switch(this.location) {
      case LEFT:
        rect(0, 0, this.size, height);
        break;
      case RIGHT:
        rect(width - this.size, 0, this.size, height);
        break;
      case UP:
        rect(0, 0, width, this.size);
        break;
      case DOWN:
        rect(0, height - this.size, width, this.size);
        break;
    }
    if (this.collapsing) {
      this.button.clicked = false;
      this.button.hovered = false;
      float buttonMove = 0;
      boolean buttonReset = false;
      if (this.open) {
        buttonMove = -this.collapse_speed * timeElapsed;
        this.size += buttonMove;
        if (this.size < 0) {
          this.size = 0;
          this.open = false;
          this.collapsing = false;
          this.resetButtonLocation();
          buttonReset = true;
        }
        if (this.img != null) {
          imageMode(CORNER);
          switch(this.location) {
            case LEFT:
              image(this.img, this.size - this.size_curr, 0);
              break;
            case RIGHT:
              image(this.img, width - this.size, 0);
              break;
            case UP:
              image(this.img, 0, this.size - this.size_curr);
              break;
            case DOWN:
              image(this.img, 0, height - this.size);
              break;
          }
        }
      }
      else {
        buttonMove = this.collapse_speed * timeElapsed;
        this.size += buttonMove;
        if (this.size > this.size_curr) {
          this.size = this.size_curr;
          this.open = true;
          this.collapsing = false;
          this.resetButtonLocation();
          buttonReset = true;
        }
      }
      if (!buttonReset) {
        switch(this.location) {
          case LEFT:
            this.button.moveButton(buttonMove, 0);
            break;
          case RIGHT:
            this.button.moveButton(-buttonMove, 0);
            break;
          case UP:
            this.button.moveButton(0, buttonMove);
            break;
          case DOWN:
            this.button.moveButton(0, -buttonMove);
            break;
        }
      }
    }
    this.lastUpdateTime = millis;
  }

  void mouseMove(float mX, float mY) {
    this.button.mouseMove(mX, mY);
    if (this.cant_resize) {
      return;
    }
    if (!this.open || this.button.hovered) {
      this.hovered = false;
      return;
    }
    switch(this.location) {
      case LEFT:
        if (this.clicked) {
          this.changeSize(mX - this.size);
        }
        else if (abs(mX - this.size) < this.hovered_delta) {
          this.hovered = true;
        }
        else {
          this.hovered = false;
        }
        break;
      case RIGHT:
        if (this.clicked) {
          this.changeSize(width - this.size - mX);
        }
        else if (abs(mX - width + this.size) < this.hovered_delta) {
          this.hovered = true;
        }
        else {
          this.hovered = false;
        }
        break;
      case UP:
        if (this.clicked) {
          this.changeSize(mY - this.size);
        }
        else if (abs(mY - this.size) < this.hovered_delta) {
          this.hovered = true;
        }
        else {
          this.hovered = false;
        }
        break;
      case DOWN:
        if (this.clicked) {
          this.changeSize(height - this.size - mY);
        }
        else if (abs(mY - height + this.size) < this.hovered_delta) {
          this.hovered = true;
        }
        else {
          this.hovered = false;
        }
        break;
    }
  }

  void mousePress() {
    this.button.mousePress();
    if (this.hovered && mouseButton == LEFT) {
      this.clicked = true;
    }
  }

  void mouseRelease(float mX, float mY) {
    this.button.mouseRelease(mX, mY);
    this.clicked = false;
    this.mouseMove(mX, mY);
  }
}
