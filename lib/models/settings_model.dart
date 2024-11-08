class Settings {
  bool onlyCreateDirectories;
  bool scanSubDirectories;
  bool limitFormatsToScan;
  Map<String, bool> fileFormatsToScan;
  bool renameFilesByDate;
  String dateFormatForRenaming;
  bool removeSourceFile;

  Settings({
    this.onlyCreateDirectories = false,
    this.scanSubDirectories = false,
    this.limitFormatsToScan = false,
    Map<String, bool>? fileFormatsToScan,
    this.renameFilesByDate = false,
    this.dateFormatForRenaming = "yyyy-MM-dd HH:mm:ss",
    this.removeSourceFile = true,
  }) : fileFormatsToScan = fileFormatsToScan ?? {'pdf': false, 'png': false};
}
