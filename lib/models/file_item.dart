import 'dart:io';

class FileItem {
  final FileSystemEntity file;
  final String path;
  final DateTime modifiedTime;
  final String fileName;

  FileItem({
    required this.file,
    required this.path,
    required this.modifiedTime,
    required this.fileName,
  });

  factory FileItem.fromFile(FileSystemEntity file) {
    return FileItem(
      file: file,
      path: file.path,
      modifiedTime: file.statSync().modified,
      fileName: file.path.split('/').last,
    );
  }
}
