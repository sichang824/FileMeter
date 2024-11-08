import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

// 设置服务 (Settings Service)
//
// 这是一个基于 GetStorage 的持久化设置管理系统。使用前需要在 main 函数中初始化：
// await GetStorage.init('settings');
//
// 主要功能：
// 1. 支持多种数据类型：String、double、int、bool
// 2. 支持数据验证
// 3. 支持数据持久化
// 4. 支持数据监听
// 5. 支持重置为默认值
//
// 使用示例：
//
// final themeSetting = BoolSetting(
//   settingKey: SettingKey(prefix: 'app', key: 'darkMode'),
//   settingValue: SettingValue<bool>(initial: false),
// );
//
// // 读取设置
// await themeSetting.load();
//
// // 更新设置
// await themeSetting.update(true);
//
// // 监听变化
// themeSetting.addListener((value) {
//   print('主题更改为: $value');
// });
//
// // 重置为默认值
// await themeSetting.reset();

abstract class Setting<T> {
  final SettingKey settingKey;
  final SettingValue<T> settingValue;
  static final _storage = GetStorage('settings');

  Setting({required this.settingKey, required this.settingValue});

  T get value => settingValue.value.value;

  void addListener(void Function(T) listener) {
    settingValue.value.listen((value) => listener(value));
  }

  Future<void> init() async {
    final value = await _storage.read(settingKey.value) as T?;
    if (value != null) {
      settingValue.update(value);
    } else {
      settingValue.reset();
    }
  }

  Future<void> save() async {
    try {
      final value = settingValue.value.value;
      if (value is String || value is bool || value is int || value is double) {
        await _storage.write(settingKey.value, value);
      } else {
        throw UnsupportedError('不支持的值类型: ${value.runtimeType}');
      }
    } catch (e) {
      throw Exception('保存设置失败: $e');
    }
  }

  bool validate(T value) => true;

  Future<bool> update(T newValue) async {
    if (!validate(newValue)) return false;

    try {
      settingValue.update(newValue);
      await save();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFromString(String newValue) async {
    final parsedValue = settingValue.parseValue(newValue);
    if (parsedValue != null) {
      return await update(parsedValue);
    }
    return false;
  }

  Future<void> erase() async {
    final key = settingKey.value;
    await _storage.remove(key);
  }

  Future<void> reset() async {
    settingValue.reset();
    await save();
  }
}

class SettingKey {
  final String prefix;
  final String key;
  late final String value;

  SettingKey({required this.prefix, required this.key}) {
    value = 'settings.$prefix.$key';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingKey &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class SettingValue<T> {
  final Rx<T> value;
  final T initial;
  final TextEditingController controller;

  final bool Function(T)? validator;

  SettingValue({
    required this.initial,
    this.validator,
  })  : value = Rx<T>(initial),
        controller = TextEditingController(text: initial.toString());

  T? parseValue(String newValue) {
    try {
      if (T == double) {
        return double.tryParse(newValue) as T?;
      } else if (T == int) {
        return int.tryParse(newValue) as T?;
      } else if (T == bool) {
        return (newValue.toLowerCase() == 'true') as T?;
      } else if (T == String) {
        return newValue as T?;
      }
    } catch (e) {
      debugPrint('解析值失败: $e');
    }
    return null;
  }

  bool update(T newValue) {
    if (validator?.call(newValue) ?? true) {
      value.value = newValue;
      controller.text = stringValue;
      return true;
    }
    return false;
  }

  void reset() {
    value.value = initial;
    controller.text = stringValue;
  }

  String get stringValue {
    return value.value.toString();
  }

  @override
  String toString() {
    return 'SettingValue(type: $T, initial: $initial, value: ${value.value})';
  }
}

class StringSetting extends Setting<String> {
  StringSetting({
    required super.settingKey,
    required super.settingValue,
  });
}

class DoubleSetting extends Setting<double> {
  DoubleSetting({
    required super.settingKey,
    required super.settingValue,
  });
}

class NumberSetting extends Setting<double> {
  NumberSetting({
    required super.settingKey,
    required super.settingValue,
  });
}

class RangeIntSetting extends Setting<int> {
  final int min;
  final int max;

  RangeIntSetting({
    required super.settingKey,
    required super.settingValue,
    required this.min,
    required this.max,
  });

  @override
  bool validate(int value) {
    if (value < min) return false;
    if (value > max) return false;
    return true;
  }
}

class BoolSetting extends Setting<bool> {
  BoolSetting({
    required super.settingKey,
    required super.settingValue,
  });
}

class ListSetting<T> extends Setting<List<T>> {
  ListSetting({
    required super.settingKey,
    required super.settingValue,
  });

  Future<String> dump(List<T> value) async {
    return jsonEncode(value);
  }

  Future<List<T>> load(dynamic value) async {
    if (value == null) return [];

    final List<dynamic> jsonList = value is String ? jsonDecode(value) : value;

    if (T == String) {
      return jsonList.map((e) => e.toString()).cast<T>().toList();
    } else if (T == int) {
      return jsonList.map((e) => int.parse(e.toString())).cast<T>().toList();
    } else if (T == double) {
      return jsonList.map((e) => double.parse(e.toString())).cast<T>().toList();
    } else if (T == bool) {
      return jsonList
          .map((e) => (e.toString().toLowerCase() == 'true'))
          .cast<T>()
          .toList();
    }
    throw UnsupportedError('不支持的列表元素类型: $T');
  }

  @override
  Future<void> init() async {
    try {
      final value = await Setting._storage.read(settingKey.value);
      if (value != null) {
        final loadedList = await load(value);
        settingValue.update(loadedList);
      } else {
        settingValue.reset();
      }
    } catch (e) {
      debugPrint('初始化列表设置失败: $e');
      settingValue.reset();
    }
  }

  @override
  Future<void> save() async {
    try {
      final value = await dump(settingValue.value.value);
      await Setting._storage.write(settingKey.value, value);
    } catch (e) {
      throw Exception('保存设置失败: $e');
    }
  }
}
