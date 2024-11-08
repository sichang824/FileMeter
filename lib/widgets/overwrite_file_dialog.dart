import 'dart:io';

import 'package:flutter/material.dart';

Widget OverwriteAlertDialog(
    BuildContext context, FileSystemEntity src, File dst) {
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
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
