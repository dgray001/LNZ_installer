import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.net.URL;
import java.io.*;
import java.nio.file.*;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;
import static java.nio.file.StandardOpenOption.CREATE;
import static java.nio.file.StandardOpenOption.WRITE;
import java.awt.event.KeyEvent;


Global global;

class InstallButton extends RectangleButton {
  InstallButton() {
    super(60, 70, 140, 120);
    this.message = "Install";
    this.text_size = 20;
    this.show_message = true;
  }
  void hover() {}
  void dehover() {}
  void click() {}
  void release() {
    if (!this.hovered) {
      return;
    }
    this.disabled = true;
    chooseFolder();
  }
}
InstallButton button;
class InstallThread extends Thread {
  File selection;
  InstallThread(File selection) {
    super("InstallThread");
    this.selection = selection;
    this.setDaemon(true);
  }
  @Override
  void run() {
    if (this.selection == null) {
      return;
    }
    try {
      message = "downloading from github";
      ZipUtils.unzip(new URL("https://github.com/dgray001/LNZ/archive/refs/heads/release_alpha_v0.7_windows.zip"), this.selection.toPath());
      message = "managing files";
      deleteFile(this.selection.toPath().toString() + "/LNZ-release_alpha_v0.7_windows/java/lib/modules");
      message = "downloading from onedrive";
      ZipUtils.download(new URL("https://dl.dropboxusercontent.com/s/8ycy6e0w0qqjdge/modules?dl=0"),
        this.selection.toPath().toString() + "/LNZ-release_alpha_v0.7_windows/java/lib/modules");
      message = "finished";
    } catch (Exception e) {
      message = e.toString();
    }
  }
}
InstallThread thread;
String message = "";

void setup() {
  fullScreen();
  surface.setSize(200, 200);
  surface.setLocation(int(0.5 * (displayWidth - 200)), int(0.5 * (displayHeight - 200)));
  button = new InstallButton();
  message = Constants.credits;
  mouseX = 0;
  mouseY = 0;
}

void draw() {
  background(0);
  fill(100, 255, 100);
  textSize(34);
  textAlign(CENTER, TOP);
  text("LNZ", map(min(mouseX, width), 0, width, 80, 120), map(min(mouseY, height), 0, height, 0, 20));
  button.update(0);
  fill(255);
  textSize(12);
  textAlign(CENTER, BOTTOM);
  text(message, 100, height - 10);
}

void mouseMoved() {
  mouseMove(mouseX, mouseY);
}
void mouseDragged() {
  mouseMove(mouseX, mouseY);
}

void mouseMove(float mX, float mY) {
  button.mouseMove(mX, mY);
}

void mousePressed() {
  button.mousePress();
}

void mouseReleased() {
  button.mouseRelease(mouseX, mouseY);
}

void chooseFolder() {
  selectFolder("Where to install", "download");
}

public static class ZipUtils {

    public static void unzip(final URL url, final Path decryptTo) {
        try (ZipInputStream zipInputStream = new ZipInputStream(Channels.newInputStream(Channels.newChannel(url.openStream())))) {
            for (ZipEntry entry = zipInputStream.getNextEntry(); entry != null; entry = zipInputStream.getNextEntry()) {
                Path toPath = decryptTo.resolve(entry.getName());
                if (entry.isDirectory()) {
                    Files.createDirectory(toPath);
                } else try (FileChannel fileChannel = FileChannel.open(toPath, WRITE, CREATE/*, DELETE_ON_CLOSE*/)) {
                    fileChannel.transferFrom(Channels.newChannel(zipInputStream), 0, Long.MAX_VALUE);
                }
            }
        } catch (Exception e) {
          println(e.toString());
        }
    }

    public static void download(final URL url, final String decryptTo) {
      try {
        ReadableByteChannel rbc = Channels.newChannel(url.openStream());
        FileOutputStream fos = new FileOutputStream(decryptTo);
        fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
      } catch (Exception e) {
        println(e.toString());
      }
    }
}

void download(File selection) {
  thread = new InstallThread(selection);
  thread.start();
}
