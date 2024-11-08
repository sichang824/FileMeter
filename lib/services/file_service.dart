import 'dart:io';
import 'dart:developer';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../models/file_item.dart';
import '../controllers/settings_controller.dart';

class FileService {
  final SettingsController settingsController;

  FileService({required this.settingsController});

  Future<List<FileItem>> getFilesInDirectory(String directory) async {
    try {
      Directory dir = Directory(directory);
      List<FileSystemEntity> allFiles = [];

      if (settingsController.scanSubDirectories.value) {
        _listFilesRecursively(dir, allFiles);
      } else {
        allFiles = dir.listSync().whereType<File>().toList();
      }

      if (!settingsController.limitFormatsToScan.value ||
          (settingsController.limitFormatsToScan.value &&
              settingsController.organizeAllFiles.value)) {
        return allFiles.map((f) => FileItem.fromFile(f)).toList();
      }

      List<String> allowedFormats = settingsController.fileFormatsToScan.entries
          .where((e) => e.value.value)
          .map((e) => e.key)
          .toList();
      return allFiles
          .where((file) {
            String e = path.extension(file.path).toLowerCase();
            if (e.isEmpty) return false;
            String ext = e.startsWith('.') ? e.substring(1) : e;
            return allowedFormats.contains(ext);
          })
          .map((f) => FileItem.fromFile(f))
          .toList();
    } catch (e) {
      log("Error111: $e");
      return [];
    }
  }

  void _listFilesRecursively(Directory dir, List<FileSystemEntity> files) {
    dir.listSync().forEach((entity) {
      if (entity is File) {
        files.add(entity);
      } else if (entity is Directory) {
        _listFilesRecursively(entity, files);
      }
    });
  }

  int getSequentialNumber(String fileName) {
    RegExp regExp = RegExp(r'__(\d+)$');
    Match? match = regExp.firstMatch(fileName);
    if (match != null) {
      int number = int.parse(match.group(1)!);
      return number + 1;
    } else {
      return 1;
    }
  }

  String addSequentialNumber(String fileName, int number) {
    int extensionIndex = fileName.lastIndexOf('.');
    if (extensionIndex != -1) {
      // 如果存在文件扩展名，则在文件扩展名前面插入序号
      return '${fileName.substring(0, extensionIndex)}__$number${fileName.substring(extensionIndex)}';
    } else {
      // 如果没有文件扩展名，则直接在文件名后面添加序号
      return '${fileName}__$number';
    }
  }

  String getAvailableFileName(String fileName) {
    int sequentialNumber = getSequentialNumber(fileName);
    String baseName = fileName.replaceAll(RegExp(r'__(\d+)$'), ''); // 移除末尾的序号

    String newFileName =
        addSequentialNumber(baseName, sequentialNumber); // 初始尝试的文件名

    while (File(newFileName).existsSync()) {
      // 如果文件已经存在，尝试增加序号并重新生成文件名
      sequentialNumber++;
      newFileName = addSequentialNumber(baseName, sequentialNumber);
    }

    return newFileName;
  }

  Future<bool> _deleteFileIfNeeded(
    FileItem file,
    SettingsController settingsController,
    bool isPaused,
  ) async {
    if (!settingsController.removeSpecificFiles.value) return false;

    final fileName = file.fileName;
    if (!settingsController.filesToRemove.containsKey(fileName) ||
        !settingsController.filesToRemove[fileName]!.value) {
      return false;
    }

    if (isPaused) return false;

    try {
      print('Deleting file: ${file.fileName}');
      await file.file.delete();
      return true;
    } catch (e) {
      log('Error deleting file ${file.fileName}: $e');
      return false;
    }
  }

  Future<void> processFiles({
    required String baseDirectory,
    required List<FileItem> files,
    required bool isPaused,
    required Function(FileSystemEntity, File) onOverwrite,
    required SettingsController settingsController,
  }) async {
    List<FileItem> filesToProcess = List.from(files);

    for (var src in filesToProcess) {
      if (isPaused) break;

      // 先检查是否需要删除文件
      bool wasDeleted = await _deleteFileIfNeeded(
        src,
        settingsController,
        isPaused,
      );

      if (wasDeleted) {
        files.remove(src);
        continue;
      }

      // 如果文件不需要删除，则进行移动操作
      var modifiedTime = src.modifiedTime;
      var year = modifiedTime.year.toString();
      var month = modifiedTime.month.toString().padLeft(2, '0');
      var destinationDirectory = Directory('$baseDirectory/$year$month');

      if (!destinationDirectory.existsSync()) {
        print('Make $destinationDirectory');
        destinationDirectory.createSync(recursive: true);
      }

      if (settingsController.onlyCreateDirectories.value) {
        continue;
      }

      var fileName = src.path.split('/').last;
      var dstFileName = fileName;
      if (settingsController.renameFilesByDate.value) {
        var fileExtension = dstFileName.split('.').last;
        dstFileName =
            '${DateFormat(settingsController.dateFormatForRenaming.value).format(modifiedTime)}.$fileExtension';
      }
      var destinationPath = '${destinationDirectory.path}/$dstFileName';

      File dst = File(destinationPath);
      if (dst.existsSync()) {
        int overwrite = await onOverwrite(src.file, dst);

        if (overwrite == 1) {
          destinationPath = getAvailableFileName(destinationPath);
        }

        if (overwrite == 2) {
          continue;
        }
      }

      if (settingsController.moveInsteadOfCopy.value) {
        print('Moving file $fileName to $destinationPath');
        await src.file.rename(destinationPath);
      } else {
        print('Copying file $fileName to $destinationPath');
        await File(src.path).copy(destinationPath);
      }

      files.remove(src);
    }
  }
}
