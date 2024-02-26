import 'dart:io';
import 'package:filemeter/settings.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' hide context;
import 'package:intl/intl.dart';

void main() async {
  await GetStorage.init('settings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SettingsController settingsController = Get.put(SettingsController());

  List<FileSystemEntity> _files = [];
  String _selectedDirectory = "";
  bool _pauseFlag = true; // 增加一个暂停标识，默认为false
  Widget _buildOverwriteAlertDialog(FileSystemEntity src, File dst) {
    return AlertDialog(
      title: const Text(
        '文件已经存在',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '您希望覆盖现有文件吗？',
              style: TextStyle(fontSize: 16.0, color: Colors.orange),
            ),
            const SizedBox(height: 8.0), // 添加间距
            Text(
              '源文件路径：${src.path}',
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              src.statSync().toString(),
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              '目标路径：${dst.path}',
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              dst.statSync().toString(),
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 将按钮水平居中对齐
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(0); // 确认覆盖
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                child: const Text(
                  '覆盖',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(1); // 保留两者
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: const Text(
                  '共存',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 20), // 添加水平间距
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(2); // 取消覆盖
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey),
                ),
                child: const Text(
                  '不覆盖',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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

  Future<void> _run() async {
    _pauseFlag = false;
    List<FileSystemEntity> filesToMove = List.from(_files); // 创建一个副本用于迭代和修改

    for (var src in filesToMove) {
      if (_pauseFlag) {
        break;
      }
      var modifiedTime = src.statSync().modified;
      var year = modifiedTime.year.toString();
      var month = modifiedTime.month.toString().padLeft(2, '0');
      var destinationDirectory = Directory('$_selectedDirectory/$year$month');

      if (!destinationDirectory.existsSync()) {
        print('Make $destinationDirectory');
        destinationDirectory.createSync(recursive: true);
      }

      if (settingsController.settings.onlyCreateDirectories) {
        continue;
      }

      var fileName = src.path.split('/').last;
      var dstFileName = fileName;
      if (settingsController.settings.renameFilesByDate) {
        var fileExtension = dstFileName.split('.').last;
        dstFileName =
            '${DateFormat(settingsController.settings.dateFormatForRenaming).format(modifiedTime)}.$fileExtension';
      }
      var destinationPath = '${destinationDirectory.path}/$dstFileName';

      // 如果目标文件已经存在，弹出确认对话框
      File dst = File(destinationPath);
      if (dst.existsSync()) {
        int overwrite = await showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildOverwriteAlertDialog(src, dst),
        );

        if (overwrite == 1) {
          destinationPath = getAvailableFileName(destinationPath);
          // destinationPath = '${destinationDirectory.path}/$newFileName';
        }

        if (overwrite == 2) {
          continue;
        }
      }

      if (settingsController.settings.removeSourceFile) {
        print('Moved file $fileName to $destinationPath');
        await src.rename(destinationPath);
      } else {
        print('Copy file $fileName to $destinationPath');
        File(src.path).copy(destinationPath);
      }

      setState(() {
        _files.remove(src);
      });
      // await Future.delayed(Duration(milliseconds: 100));
    }
    _pauseFlag = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件整理工具'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // 将高度设置为100
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('文件数: ${_files.length}'),
                Text('目录: $_selectedDirectory'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildFileList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: _files.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'clear',
              onPressed: () {
                setState(() {
                  _selectedDirectory = '';
                  _files = [];
                });
              },
              tooltip: '清空',
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          Visibility(
            visible: _files.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'refresh',
              onPressed: () => _getFilesInDirectory(),
              tooltip: '刷新',
              child: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 16),
          Visibility(
            visible: _files.isNotEmpty,
            child: FloatingActionButton(
              heroTag: 'run',
              onPressed: () {
                if (_pauseFlag) {
                  _run();
                } else {
                  _pauseFlag = true;
                }
              },
              tooltip: _pauseFlag ? '运行' : '暂停',
              child: _pauseFlag
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
      if (selectedDirectory == null) {
        return;
      }
      _selectedDirectory = selectedDirectory;
      _getFilesInDirectory();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getFilesInDirectory() async {
    try {
      print(_selectedDirectory);
      Directory directory = Directory(_selectedDirectory);
      List<FileSystemEntity> allFiles = [];

      if (settingsController.settings.scanSubDirectories) {
        void listFilesRecursively(Directory dir) {
          dir.listSync().forEach((entity) {
            if (entity is File) {
              allFiles.add(entity);
            } else if (entity is Directory) {
              listFilesRecursively(entity); // 递归调用以获取子目录中的文件
            }
          });
        }

        listFilesRecursively(directory);
      } else {
        allFiles = directory.listSync().whereType<File>().toList();
      }

      if (!settingsController.settings.limitFormatsToScan) {
        setState(() {
          _files = allFiles;
        });
        return;
      }

      List<String> allowedFormats = [];
      settingsController.settings.fileFormatsToScan.forEach((key, value) {
        if (value) {
          allowedFormats.add(key);
        }
      });

      List<FileSystemEntity> files = allFiles.where((file) {
        String e = extension(file.path).toLowerCase();
        return allowedFormats.contains(e.substring(1));
      }).toList();

      setState(() {
        _files = files;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget _buildFileList() {
    if (_files.isEmpty) {
      return const Center(
        child: Text('请选择目录以扫描文件'),
      );
    } else {
      return GridView.count(
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 10),
        crossAxisCount: 1,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: List.generate(_files.length, (index) {
          return Card(
            child: GridTile(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      basename(_files[index].path),
                      overflow: TextOverflow.ellipsis,
                      maxLines: null,
                    ),
                    Text(
                      _files[index].statSync().modified.toString(),
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
        }),
      );
    }
  }
}
