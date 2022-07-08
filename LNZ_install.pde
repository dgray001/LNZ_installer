import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.net.URL;
import java.io.*;
import java.nio.file.*;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import static java.nio.file.StandardOpenOption.CREATE;
import static java.nio.file.StandardOpenOption.WRITE;
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
          println(e.getStackTrace());
          println(e.toString());
          println(e.getMessage());
        }
    }
}

void download(File selection) {
  if (selection == null) {
    selected = false;
    return;
  }
  try {
    ZipUtils.unzip(new URL("https://github.com/dgray001/LNZ/archive/refs/heads/release_alpha_v0.7_windows.zip"), selection.toPath());
  } catch (Exception e) {
    println(e.getMessage());
    selected = false;
  }
}
