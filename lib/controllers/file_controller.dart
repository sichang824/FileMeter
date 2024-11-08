import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';
import 'settings_controller.dart';

class FileController extends GetxController with StateMixin {
  final FileService fileService;

  RxList<FileItem> files = <FileItem>[].obs;
  RxString selectedDirectory = ''.obs;
  RxBool isPaused = true.obs;

  FileController({required this.fileService});
  final SettingsController settingsController = Get.find<SettingsController>();

  void clearFiles() {
    selectedDirectory.value = '';
    files.clear();
  }

  Future<void> loadFiles() async {
    if (selectedDirectory.isEmpty) return;
    log('loadFiles: ${selectedDirectory.value}');

    final loadedFiles =
        await fileService.getFilesInDirectory(selectedDirectory.value);
    files.value = loadedFiles;
  }

  void setDirectory(String? directory) {
    if (directory == null) return;
    selectedDirectory.value = directory;
    loadFiles();
  }

  void run({required Function(FileSystemEntity, File) onOverwrite}) async {
    isPaused.value = false;

    await fileService.processFiles(
      baseDirectory: selectedDirectory.value,
      files: files,
      isPaused: isPaused.value,
      onOverwrite: onOverwrite,
      settingsController: settingsController,
    );

    isPaused.value = true;
  }

  void pause() {
    isPaused.value = true;
  }
}
