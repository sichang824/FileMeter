import 'package:filemeter/widgets/overwrite_file_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/file_controller.dart';
import 'package:file_picker/file_picker.dart';

class ActionButtons extends GetView<FileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: controller.files.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'clear',
              onPressed: () {
                controller.clearFiles();
              },
              tooltip: '清空',
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          Visibility(
            visible: controller.files.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'refresh',
              onPressed: () => controller.loadFiles(),
              tooltip: '刷新',
              child: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 16),
          Visibility(
            visible: controller.files.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'run',
              onPressed: () {
                if (controller.isPaused.value) {
                  controller.run(
                    onOverwrite: (src, dst) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            OverwriteAlertDialog(context, src, dst),
                      );
                    },
                  );
                } else {
                  controller.pause();
                }
              },
              tooltip: controller.isPaused.value ? '运行' : '暂停',
              child: controller.isPaused.value
                  ? const Icon(Icons.play_arrow)
                  : const Icon(Icons.pause),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'select',
            onPressed: _pickDirectory,
            tooltip: '选择需要整理的目录',
            child: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      controller.setDirectory(selectedDirectory);
    } catch (e) {
      print("Error: $e");
    }
  }
}
