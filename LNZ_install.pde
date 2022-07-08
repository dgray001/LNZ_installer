import java.util.*;
import java.io.*;
import java.nio.file.*;
import java.awt.event.KeyEvent;

Global global;

boolean selected = false;

void setup() {
}

void draw() {
}

void mousePressed() {
  if (selected) {
    return;
  }
  selected = true;
  chooseFolder();
}

void chooseFolder() {
  selectFolder("Where to install", "download");
}

void download(File selection) {
  if (selection == null) {
    selected = false;
    return;
  }
  println("selected", selection);
}
