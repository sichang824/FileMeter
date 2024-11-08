import 'package:get/get.dart';
import '../services/settings.dart';

class SettingsController extends GetxController {
  static const prefix = "files";
  final Set<String> defaultFileFormatsToScan = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
  };

  final onlyCreateDirectories = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'onlyCreateDirectories'),
    settingValue: SettingValue<bool>(initial: false),
  );
  final scanSubDirectories = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'scanSubDirectories'),
    settingValue: SettingValue<bool>(initial: true),
  );
  final limitFormatsToScan = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'limitFormatsToScan'),
    settingValue: SettingValue<bool>(initial: false),
  );
  final renameFilesByDate = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'renameFilesByDate'),
    settingValue: SettingValue<bool>(initial: false),
  );
  final removeSourceFile = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'removeSourceFile'),
    settingValue: SettingValue<bool>(initial: true),
  );
  final moveInsteadOfCopy = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'moveInsteadOfCopy'),
    settingValue: SettingValue<bool>(initial: false),
  );
  final dateFormatForRenaming = StringSetting(
    settingKey: SettingKey(prefix: prefix, key: 'dateFormatForRenaming'),
    settingValue: SettingValue<String>(initial: "yyyy-MM-dd HH:mm:ss"),
  );

  final customFormatsList = ListSetting<String>(
    settingKey: SettingKey(prefix: prefix, key: "customFormatsListKey"),
    settingValue: SettingValue<List<String>>(initial: []),
  );

  final fileFormatsToScan = RxMap<String, BoolSetting>({});

  final organizeAllFiles = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'organizeAllFiles'),
    settingValue: SettingValue<bool>(initial: true),
  );

  final removeSpecificFiles = BoolSetting(
    settingKey: SettingKey(prefix: prefix, key: 'removeSpecificFiles'),
    settingValue: SettingValue<bool>(initial: false),
  );

  final filesToRemove = RxMap<String, BoolSetting>({});

  final customFilesToRemoveList = ListSetting<String>(
    settingKey: SettingKey(prefix: prefix, key: "customFilesToRemoveList"),
    settingValue: SettingValue<List<String>>(initial: []),
  );

  @override
  void onInit() async {
    super.onInit();
    await onlyCreateDirectories.init();
    await scanSubDirectories.init();
    await limitFormatsToScan.init();
    await renameFilesByDate.init();
    await removeSourceFile.init();
    await moveInsteadOfCopy.init();
    await dateFormatForRenaming.init();
    await customFormatsList.init();
    await organizeAllFiles.init();
    await removeSpecificFiles.init();
    await customFilesToRemoveList.init();

    final allFormats = {
      ...customFormatsList.value,
      ...defaultFileFormatsToScan
    };

    for (var format in allFormats) {
      fileFormatsToScan[format] = BoolSetting(
        settingKey: SettingKey(prefix: prefix, key: 'formats.$format'),
        settingValue: SettingValue<bool>(initial: false),
      );
      await fileFormatsToScan[format]!.init();
    }

    for (var fileName in customFilesToRemoveList.value) {
      filesToRemove[fileName] = BoolSetting(
        settingKey: SettingKey(prefix: prefix, key: 'filesToRemove.$fileName'),
        settingValue: SettingValue<bool>(initial: false),
      );
      await filesToRemove[fileName]!.init();
    }
  }

  Future<void> toggleCreateDirectoriesOnly() async {
    await onlyCreateDirectories.update(!onlyCreateDirectories.value);
  }

  Future<void> toggleScanSubdirectories() async {
    await scanSubDirectories.update(!scanSubDirectories.value);
  }

  Future<void> toggleLimitFormatsToScan() async {
    await limitFormatsToScan.update(!limitFormatsToScan.value);
  }

  Future<void> toggleRemoveSourceFile() async {
    await removeSourceFile.update(!removeSourceFile.value);
  }

  Future<void> toggleMoveInsteadOfCopy() async {
    await moveInsteadOfCopy.update(!moveInsteadOfCopy.value);
  }

  Future<void> toggleRenameByDate() async {
    await renameFilesByDate.update(!renameFilesByDate.value);
  }

  Future<void> updateDateFormatForRenaming(String format) async {
    await dateFormatForRenaming.update(format);
  }

  Future<void> updateFileFormatToScan(String format, bool value) async {
    if (fileFormatsToScan.containsKey(format)) {
      await fileFormatsToScan[format]!.update(value);
      fileFormatsToScan.refresh();
    }
  }

  Future<void> addFileFormatToScan(String format) async {
    if (!fileFormatsToScan.containsKey(format)) {
      final newSetting = BoolSetting(
        settingKey: SettingKey(prefix: prefix, key: 'formats.$format'),
        settingValue: SettingValue<bool>(initial: true),
      );
      await newSetting.save();
      fileFormatsToScan[format] = newSetting;

      await _saveCustomFormatsList();
      fileFormatsToScan.refresh();
    }
  }

  Future<void> removeFileFormatToScan(String format) async {
    if (fileFormatsToScan.containsKey(format)) {
      await fileFormatsToScan[format]!.erase();
      fileFormatsToScan.remove(format);

      await _saveCustomFormatsList();
      fileFormatsToScan.refresh();
    }
  }

  Future<void> clearFileFormatsToScan() async {
    for (var format in fileFormatsToScan.keys.toList()) {
      await removeFileFormatToScan(format);
    }
  }

  Future<void> _saveCustomFormatsList() async {
    await customFormatsList.update(fileFormatsToScan.keys.toList());
  }

  Future<void> toggleOrganizeAllFiles() async {
    await organizeAllFiles.update(!organizeAllFiles.value);
  }

  Future<void> toggleRemoveSpecificFiles() async {
    await removeSpecificFiles.update(!removeSpecificFiles.value);
  }

  Future<void> updateFileToRemove(String fileName, bool value) async {
    if (filesToRemove.containsKey(fileName)) {
      await filesToRemove[fileName]!.update(value);
      filesToRemove.refresh();
    }
  }

  Future<void> addFileToRemove(String fileName) async {
    if (!filesToRemove.containsKey(fileName)) {
      final newSetting = BoolSetting(
        settingKey: SettingKey(prefix: prefix, key: 'filesToRemove.$fileName'),
        settingValue: SettingValue<bool>(initial: true),
      );
      await newSetting.save();
      filesToRemove[fileName] = newSetting;

      await _saveCustomFilesToRemoveList();
      filesToRemove.refresh();
    }
  }

  Future<void> removeFileFromRemoveList(String fileName) async {
    if (filesToRemove.containsKey(fileName)) {
      await filesToRemove[fileName]!.erase();
      filesToRemove.remove(fileName);

      await _saveCustomFilesToRemoveList();
      filesToRemove.refresh();
    }
  }

  Future<void> _saveCustomFilesToRemoveList() async {
    await customFilesToRemoveList.update(filesToRemove.keys.toList());
  }
}
