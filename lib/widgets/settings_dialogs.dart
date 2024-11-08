import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';

class FileFormatDialog extends StatelessWidget {
  final SettingsController controller;
  final TextEditingController customFormatController;

  const FileFormatDialog({
    Key? key,
    required this.controller,
    required this.customFormatController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择需要整理的文件格式'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildFormatInput(),
            ...buildFormatCheckboxes(),
          ],
        ),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildFormatInput() {
    return ListTile(
      title: TextFormField(
        controller: customFormatController,
        decoration: InputDecoration(
          labelText: '自定义文件格式',
          suffixIcon: IconButton(
            onPressed: () => _handleSubmit(),
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  List<Widget> buildFormatCheckboxes() {
    return controller.fileFormatsToScan.keys.map((format) {
      bool isChecked = controller.fileFormatsToScan[format]!.value;
      return CheckboxListTile(
        title: Text(format),
        value: isChecked,
        onChanged: (value) {
          controller.updateFileFormatToScan(format, value!);
        },
      );
    }).toList();
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('确定'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('取消'),
      ),
    ];
  }

  void _handleSubmit() {
    String value = customFormatController.text.trim();
    if (value.isNotEmpty) {
      controller.addFileFormatToScan(value);
      customFormatController.clear();
    }
  }
}
