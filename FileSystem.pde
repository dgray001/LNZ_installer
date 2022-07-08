// default to if file does not exist create file
void mkFile(String path) {
  mkFile(path, false);
}
void mkFile(String path, boolean replace) {
  mkFile(Paths.get(sketchPath(path)), replace);
}
void mkFile(Path p, boolean replace) {
  if (!Files.exists(p)) {
    try {
      Files.createFile(p);
    } catch (IOException e) {
      println("ERROR: IOException at mkFile(" + p + ")");
    }
  }
  else if (replace && !Files.isDirectory(p)) {
    deleteFile(p);
    try {
      Files.createFile(p);
    } catch (IOException e) {
      println("ERROR: IOException at mkFile(" + p + ")");
    }
  }
}

// move file
void moveFile(String source_path, String target_path) {
  moveFile(Paths.get(sketchPath(source_path)), Paths.get(sketchPath(target_path)));
}
void moveFile(Path source, Path target) {
  try {
    Files.move(source, target);
  } catch(IOException e) {
    println("ERROR: IOException at moveFile(" + source + ", " + target + ")");
  }
}

// copy file
void copyFile(String source_path, String target_path) {
  copyFile(Paths.get(sketchPath(source_path)), Paths.get(sketchPath(target_path)));
}
void copyFile(Path source, Path target) {
  try {
    Files.copy(source, target);
  } catch(IOException e) {
    println("ERROR: IOException at copyFile(" + source + ", " + target + ")");
  }
}

// delete file
void deleteFile(String path) {
  deleteFile(Paths.get(sketchPath(path)));
}
void deleteFile(Path p) {
  try {
    Files.deleteIfExists(p);
  } catch(IOException e) {
    println("ERROR: IOException at deleteFile(" + p + ")");
  }
}

// list all entries in directory
ArrayList<Path> listEntries(String path) {
  return listEntries(Paths.get(sketchPath(path)));
}
ArrayList<Path> listEntries(Path p) {
  ArrayList<Path> entries = new ArrayList<Path>();
  try {
    if (Files.isDirectory(p)) {
      Files.list(p).forEach(entry -> entries.add(entry));
    }
    else {
      println("ERROR: Not a directory at listEntries(" + p + ")");
    }
  } catch(IOException e) {
    println("ERROR: IOException at listEntries(" + p + ")");
  }
  return entries;
}

// list all files in directory
ArrayList<Path> listFiles(String path) {
  return listFiles(Paths.get(sketchPath(path)));
}
ArrayList<Path> listFiles(Path p) {
  ArrayList<Path> files = listEntries(p);
  for (int i = 0; i < files.size(); i++) {
    if (Files.isDirectory(files.get(i))) {
      files.remove(i);
      i--;
    }
  }
  return files;
}

// list all folder in directory
ArrayList<Path> listFolders(String path) {
  return listFolders(Paths.get(sketchPath(path)));
}
ArrayList<Path> listFolders(Path p) {
  ArrayList<Path> folders = listEntries(p);
  for (int i = 0; i < folders.size(); i++) {
    if (!Files.isDirectory(folders.get(i))) {
      folders.remove(i);
      i--;
    }
  }
  return folders;
}

// default to if folder does not exist create folder
void mkdir(String path) {
  mkdir(path, false);
}
void mkdir(String path, boolean replace) {
  mkdir(path, replace, false);
}
void mkdir(String path, boolean replace, boolean replace_file) {
  mkdir(Paths.get(sketchPath(path)), replace, replace_file);
}
void mkdir(Path p, boolean replace, boolean replace_file) {
  if (!Files.exists(p)) {
    try {
      Files.createDirectory(p);
    } catch (IOException e) {
      println("ERROR: IOException at mkdir(" + p + ")");
    }
  }
  else if (replace && Files.isDirectory(p)) {
    deleteFolder(p);
    try {
      Files.createDirectory(p);
    } catch (IOException e) {
      println("ERROR: IOException at mkdir(" + p + ")");
    }
  }
  else if (replace_file && !Files.isDirectory(p)) {
    deleteFile(p);
    try {
      Files.createDirectory(p);
    } catch (IOException e) {
      println("ERROR: IOException at mkdir(" + p + ")");
    }
  }
}

// move folder
void moveFolder(String source_path, String target_path) {
  moveFolder(Paths.get(sketchPath(source_path)), Paths.get(sketchPath(target_path)));
}
void moveFolder(Path source, Path target) {
  if (Files.isDirectory(source)) {
    mkdir(target, false, false);
    for (Path filePath : listFiles(source)) {
      moveFile(filePath, target.resolve(filePath.getFileName()));
    }
    for (Path folderPath : listFolders(source)) {
      moveFolder(folderPath, target.resolve(folderPath.getFileName()));
    }
  }
  else {
    moveFile(source, target);
  }
  deleteFolder(source);
}

// copy folder
void copyFolder(String source_path, String target_path) {
  copyFolder(Paths.get(sketchPath(source_path)), Paths.get(sketchPath(target_path)));
}
void copyFolder(Path source, Path target) {
  if (Files.isDirectory(source)) {
    mkdir(target, false, false);
    for (Path filePath : listFiles(source)) {
      copyFile(filePath, target.resolve(filePath.getFileName()));
    }
    for (Path folderPath : listFolders(source)) {
      copyFolder(folderPath, target.resolve(folderPath.getFileName()));
    }
  }
  else {
    copyFile(source, target);
  }
}

// recursively deletes folder
void deleteFolder(String path) {
  deleteFolder(Paths.get(sketchPath(path)));
}
void deleteFolder(Path p) {
  if (Files.isDirectory(p)) {
    for (Path filePath : listFiles(p)) {
      deleteFile(filePath);
    }
    for (Path folderPath : listFolders(p)) {
      deleteFolder(folderPath);
    }
    try {
      Files.delete(p);
    } catch(IOException e) {
      println("ERROR: IOException at deleteFolder(" + p + ")");
    }
  }
  else {
    deleteFile(p);
  }
}


// Entry exists
boolean entryExists(String path) {
  return entryExists(Paths.get(sketchPath(path)));
}
boolean entryExists(Path p) {
  return Files.exists(p);
}

// File exists
boolean fileExists(String path) {
  return fileExists(Paths.get(sketchPath(path)));
}
boolean fileExists(Path p) {
  return (Files.exists(p) && !Files.isDirectory(p));
}

// Folder exists
boolean folderExists(String path) {
  return folderExists(Paths.get(sketchPath(path)));
}
boolean folderExists(Path p) {
  return (Files.exists(p) && Files.isDirectory(p));
}
