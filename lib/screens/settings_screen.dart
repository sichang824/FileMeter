import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  static const double _dialogPadding = 16.0;

  Widget _buildFileFormatSelectionAlertDialog(BuildContext context) {
    final TextEditingController customFormatController =
        TextEditingController();
    final FocusNode focusNode = FocusNode();
    final ScrollController scrollController = ScrollController();

    ever(controller.fileFormatsToScan, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    void handleSubmit() {
      final String value = customFormatController.text.trim();
      if (value.isNotEmpty) {
        controller.addFileFormatToScan(value);
        customFormatController.clear();
        focusNode.requestFocus();
      }
    }

    Widget buildFileFormatItem(int index) {
      final format = controller.fileFormatsToScan.keys.elementAt(index);
      final isDefaultFormat =
          controller.defaultFileFormatsToScan.contains(format);

      return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(format),
        value: controller.fileFormatsToScan[format]!.value,
        onChanged: (value) => controller.updateFileFormatToScan(format, value!),
        dense: true,
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: isDefaultFormat
              ? null
              : () => controller.removeFileFormatToScan(format),
          tooltip: isDefaultFormat ? '默认格式不能删除' : '删除格式',
        ),
      );
    }

    return AlertDialog(
      title: const Text('选择需要整理的文件格式'),
      contentPadding: const EdgeInsets.all(_dialogPadding),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: customFormatController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: '自定义文件格式',
                hintText: '输入文件格式，如: jpg',
                suffixIcon: IconButton(
                  onPressed: handleSubmit,
                  icon: const Icon(Icons.add),
                  tooltip: '添加格式',
                ),
              ),
              onFieldSubmitted: (_) => handleSubmit(),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Obx(() => ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: controller.fileFormatsToScan.length,
                    itemBuilder: (context, index) => buildFileFormatItem(index),
                  )),
            ),
          ],
        ),
      ),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDateFormatForRenamingAlertDialog(BuildContext context) {
    final TextEditingController customFormatController =
        TextEditingController(text: controller.dateFormatForRenaming.value);

    return AlertDialog(
      title: const Text('重命名文件为日期的格式'),
      contentPadding: const EdgeInsets.all(_dialogPadding),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: customFormatController,
            decoration: const InputDecoration(
              labelText: '自定义日期格式',
              hintText: '例如: yyyy-MM-dd',
              helperText: '可用格式: yyyy(年) MM(月) dd(日) HH(时) mm(分) ss(秒)',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '预览: ${DateTime.now().toString()}',
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      ),
      actions: _buildDialogActions(context,
          onSubmit: () => controller
              .updateDateFormatForRenaming(customFormatController.text)),
    );
  }

  List<Widget> _buildDialogActions(
    BuildContext context, {
    VoidCallback? onSubmit,
    VoidCallback? onCancel,
  }) {
    return <Widget>[
      TextButton(
        onPressed: () {
          onCancel?.call();
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[600],
        ),
        child: const Text('取消'),
      ),
      TextButton(
        onPressed: () {
          onSubmit?.call();
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
        ),
        child: const Text('确定'),
      ),
    ];
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    String? subtitle,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildFilesToRemoveSelectionAlertDialog(BuildContext context) {
    final TextEditingController customFileController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    final ScrollController scrollController = ScrollController();

    ever(controller.filesToRemove, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    void handleSubmit() {
      final String value = customFileController.text.trim();
      if (value.isNotEmpty) {
        controller.addFileToRemove(value);
        customFileController.clear();
        focusNode.requestFocus();
      }
    }

    Widget buildFileItem(int index) {
      final fileName = controller.filesToRemove.keys.elementAt(index);

      return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(fileName),
        value: controller.filesToRemove[fileName]!.value,
        onChanged: (value) => controller.updateFileToRemove(fileName, value!),
        dense: true,
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => controller.removeFileFromRemoveList(fileName),
          tooltip: '删除文件',
        ),
      );
    }

    return AlertDialog(
      title: const Text('选择需要删除的文件'),
      contentPadding: const EdgeInsets.all(_dialogPadding),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: customFileController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: '文件名',
                hintText: '输入需要删除的文件名',
                suffixIcon: IconButton(
                  onPressed: handleSubmit,
                  icon: const Icon(Icons.add),
                  tooltip: '添加文件',
                ),
              ),
              onFieldSubmitted: (_) => handleSubmit(),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Obx(() => ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: controller.filesToRemove.length,
                    itemBuilder: (context, index) => buildFileItem(index),
                  )),
            ),
          ],
        ),
      ),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildFileRemovalSettings(BuildContext context) {
    return Column(
      children: [
        _buildSettingSwitch(
          title: '删除指定文件',
          subtitle: '启用后将删除指定的文件',
          value: controller.removeSpecificFiles.value,
          onChanged: (_) => controller.toggleRemoveSpecificFiles(),
        ),
        Visibility(
          visible: controller.removeSpecificFiles.value,
          child: ListTile(
            title: const Text('需要删除的文件'),
            subtitle: const Text('选择需要删除的文件'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildFilesToRemoveSelectionAlertDialog(context),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildBasicSettings(),
              _buildFileFormatTile(context),
              _buildDateSettings(context),
              _buildFileRemovalSettings(context),
            ],
          )),
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      children: [
        _buildSettingSwitch(
          title: '仅创建分析目录（不移动文件）',
          subtitle: '启用后将仅创建分析目录，不移动文件',
          value: controller.onlyCreateDirectories.value,
          onChanged: (_) => controller.toggleCreateDirectoriesOnly(),
        ),
        _buildSettingSwitch(
          title: '递归扫描目录所有的子目录',
          subtitle: '启用后将扫描所有子目录',
          value: controller.scanSubDirectories.value,
          onChanged: (_) => controller.toggleScanSubdirectories(),
        ),
        _buildSettingSwitch(
          title: '移动文件而不是复制',
          subtitle: '启用后将移动文件到目标目录，而不是复制',
          value: controller.moveInsteadOfCopy.value,
          onChanged: (_) => controller.toggleMoveInsteadOfCopy(),
        ),
      ],
    );
  }

  Widget _buildFileFormatTile(BuildContext context) {
    return Column(
      children: [
        _buildSettingSwitch(
          title: '限制需要整理的文件格式',
          subtitle: '启用后将仅整理指定格式的文件',
          value: controller.limitFormatsToScan.value,
          onChanged: (_) => controller.toggleLimitFormatsToScan(),
        ),
        Visibility(
          visible: controller.limitFormatsToScan.value,
          child: _buildSettingSwitch(
            title: '整理所有文件',
            subtitle: '启用后将整理所有文件，不限制格式',
            value: controller.organizeAllFiles.value,
            onChanged: (_) => controller.toggleOrganizeAllFiles(),
          ),
        ),
        Visibility(
          visible: controller.limitFormatsToScan.value &&
              !controller.organizeAllFiles.value,
          child: ListTile(
            title: const Text('需要整理的文件格式'),
            subtitle: const Text('选择需要整理的文件格式'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildFileFormatSelectionAlertDialog(context),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildDateSettings(BuildContext context) {
    return Column(
      children: [
        _buildSettingSwitch(
          title: '文件名修改为日期格式',
          subtitle: '启用后将文件名修改为日期格式',
          value: controller.renameFilesByDate.value,
          onChanged: (value) => controller.toggleRenameByDate(),
        ),
        Visibility(
          visible: controller.renameFilesByDate.value,
          child: ListTile(
            title: const Text('文件名的日期格式'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildDateFormatForRenamingAlertDialog(context),
              );
            },
          ),
        ),
      ],
    );
  }
}
