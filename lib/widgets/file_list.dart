import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/file_controller.dart';
import '../models/file_item.dart';
import '../controllers/settings_controller.dart';

class FileListView extends GetView<FileController> {
  final settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.files.isEmpty) {
        return const Center(
          child: Text('请选择目录以扫描文件'),
        );
      }

      return GridView.count(
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 10),
        crossAxisCount: 1,
        children: controller.files.map((file) => _buildFileCard(file)).toList(),
      );
    });
  }

  Widget _buildFileCard(FileItem file) {
    return Card(
      child: GridTile(
        child: ListTile(
          leading: Obx(() {
            final isInRemoveList =
                settingsController.filesToRemove.containsKey(file.fileName);
            return IconButton(
              icon: Icon(
                isInRemoveList
                    ? Icons.remove_circle
                    : Icons.remove_circle_outline,
                color: isInRemoveList ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                if (isInRemoveList) {
                  settingsController.removeFileFromRemoveList(file.fileName);
                } else {
                  settingsController.addFileToRemove(file.fileName);
                }
              },
              tooltip: isInRemoveList ? '从删除列表中移除' : '添加到删除列表',
            );
          }),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.fileName,
                overflow: TextOverflow.ellipsis,
                maxLines: null,
              ),
              Text(
                file.modifiedTime.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
