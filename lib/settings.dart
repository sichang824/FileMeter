import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Settings {
  bool onlyCreateDirectories;
  bool scanSubDirectories;
  bool limitFormatsToScan;
  Map<String, bool> fileFormatsToScan;
  bool renameFilesByDate;
  String dateFormatForRenaming;
  bool removeSourceFile; // 新增的属性

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

class SettingsController extends GetxController {
  final _settings = Settings().obs;

  Settings get settings => _settings.value;

  final _box = GetStorage('settings');

  @override
  void onInit() {
    _loadSettings();
    super.onInit();
  }

  void _saveSettings() {
    log("_saveSettings");
    _box.write('onlyCreateDirectories', settings.onlyCreateDirectories);
    _box.write('scanSubDirectories', settings.scanSubDirectories);
    _box.write('limitFormatsToScan', settings.limitFormatsToScan);
    _box.write('fileFormatsToScan', settings.fileFormatsToScan);
    _box.write('renameFilesByDate', settings.renameFilesByDate);
    _box.write('dateFormatForRenaming', settings.dateFormatForRenaming);
    _box.write('removeSourceFile', settings.removeSourceFile);
  }

  void _loadSettings() {
    log("_loadSettings");
    _settings.update((val) {
      val!.onlyCreateDirectories = _box.read('onlyCreateDirectories') ?? false;
      val.scanSubDirectories = _box.read('scanSubDirectories') ?? false;
      val.limitFormatsToScan = _box.read('limitFormatsToScan') ?? false;
      val.fileFormatsToScan = Map<String, bool>.from(
          _box.read('fileFormatsToScan') ?? {'pdf': false, 'png': false});
      val.renameFilesByDate = _box.read('renameFilesByDate') ?? false;
      val.dateFormatForRenaming =
          _box.read('dateFormatForRenaming') ?? "yyyy-MM-dd HH:mm:ss";
      val.removeSourceFile = _box.read('removeSourceFile') ?? true;
    });
  }

  void toggleCreateDirectoriesOnly() {
    _settings().onlyCreateDirectories = !_settings().onlyCreateDirectories;
    _saveSettings();
  }

  void toggleScanSubdirectories() {
    _settings().scanSubDirectories = !_settings().scanSubDirectories;
    _saveSettings();
  }

  void toggleLimitFormatsToScan() {
    _settings().limitFormatsToScan = !_settings().limitFormatsToScan;
    _saveSettings();
  }

  void toggleRemoveSourceFile() {
    _settings().removeSourceFile = !_settings().removeSourceFile;
    _saveSettings();
  }

  void addFileFormatToScan(String format) {
    _settings.update((val) {
      val!.fileFormatsToScan[format] = true;
    });
    _saveSettings();
  }

  void removeFileFormatToScan(String format) {
    _saveSettings();
  }

  void clearFileFormatsToScan() {
    _saveSettings();
  }

  void toggleRenameByDate() {
    _settings().renameFilesByDate = !_settings().renameFilesByDate;
    _saveSettings();
  }

  void updateDateFormatForRenaming(String format) {
    _settings().dateFormatForRenaming = format;
    _saveSettings();
  }

  void updateFileFormatToScan(String format, bool value) {
    _settings.update((val) {
      val!.fileFormatsToScan[format] = value;
    });
    _saveSettings();
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController controller = Get.put(SettingsController());

  Widget _buildFileFormatSelectionAlertDialog() {
    final TextEditingController customFormatController =
        TextEditingController();

    void handleSubmit() {
      String value = customFormatController.text.trim();
      if (value.isNotEmpty) {
        controller.addFileFormatToScan(value);
        customFormatController.clear(); // Clear input after submission
      }
    }

    return Obx(
      () => AlertDialog(
        title: const Text('选择需要整理的文件格式'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  controller: customFormatController,
                  decoration: InputDecoration(
                    labelText: '自定义文件格式',
                    suffixIcon: IconButton(
                      onPressed: handleSubmit,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
              ...controller.settings.fileFormatsToScan.keys.map((format) {
                bool isChecked =
                    controller.settings.fileFormatsToScan[format] ?? false;
                return CheckboxListTile(
                  title: Text(format),
                  value: isChecked,
                  onChanged: (value) {
                    controller.updateFileFormatToScan(format, value!);
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFormatForRenamingAlertDialog() {
    final TextEditingController customFormatController =
        TextEditingController(text: controller.settings.dateFormatForRenaming);

    return AlertDialog(
      title: const Text('重命名文件为日期的格式'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: TextFormField(
                controller: customFormatController,
                decoration: const InputDecoration(labelText: '自定义文件格式'),
                onChanged: ((value) {
                  customFormatController.text = value;
                }),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            controller.updateDateFormatForRenaming(customFormatController.text);
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('仅创建分析目录（不移动文件）'),
            value: controller.settings.onlyCreateDirectories,
            onChanged: (value) {
              setState(() {
                controller.toggleCreateDirectoriesOnly();
              });
            },
          ),
          SwitchListTile(
            title: const Text('递归扫描目录所有的子目录'),
            value: controller.settings.scanSubDirectories,
            onChanged: (value) {
              setState(() {
                controller.toggleScanSubdirectories();
              });
            },
          ),
          SwitchListTile(
            title: const Text('限制需要整理的文件格式'),
            value: controller.settings.limitFormatsToScan,
            onChanged: (value) {
              setState(() {
                controller.toggleLimitFormatsToScan();
              });
            },
          ),
          Visibility(
            visible: controller.settings.limitFormatsToScan,
            child: ListTile(
              title: const Text('需要整理的文件格式'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildFileFormatSelectionAlertDialog(),
                );
              },
            ),
          ),
          SwitchListTile(
            title: const Text('文件名修改为日期格式'),
            value: controller.settings.renameFilesByDate,
            onChanged: (value) {
              setState(() {
                controller.toggleRenameByDate();
              });
            },
          ),
          Visibility(
            visible: controller.settings.renameFilesByDate,
            child: ListTile(
              title: const Text('文件名的日期格式'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildDateFormatForRenamingAlertDialog(),
                );
              },
            ),
          ),
          SwitchListTile(
            title: const Text('移除源文件（取消时为拷贝模式）'),
            value: controller.settings.removeSourceFile,
            onChanged: (value) {
              setState(() {
                controller.toggleRemoveSourceFile();
              });
            },
          ),
        ],
      ),
    );
  }
}
