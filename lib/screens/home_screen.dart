import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/file_controller.dart';
import '../widgets/file_list.dart';
import '../widgets/action_buttons.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final fileController = Get.find<FileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件整理工具'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: _buildAppBarBottom(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => SettingsScreen()),
          ),
        ],
      ),
      body: FileListView(),
      floatingActionButton: ActionButtons(),
    );
  }

  Widget _buildAppBarBottom() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16.0),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('文件数: ${fileController.files.length}'),
              Text('目录: ${fileController.selectedDirectory.value}'),
            ],
          )),
    );
  }
}
