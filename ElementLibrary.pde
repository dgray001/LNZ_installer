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
