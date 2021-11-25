import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_client_app/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'index.dart';

/// 全局变量
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

class Global {
  static late SharedPreferences _prefs;
  static Profile profile = Profile();
  static NetCache netCache = NetCache(); // 网络缓存对象
  static List<MaterialColor> get themes => _themes; // 可选主题列表
  static bool get isRelease => const bool.fromEnvironment('dart.vm.product');

  /// 初始化必须调用
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    var _profile = _prefs.getString('profile');
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    // 如果没有，使用默认配置
    profile.cache ??= CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // 网络调用 - 接口类
    Git.init();

    return profile;
  }

  /// 持久化保存项目配置
  static saveProfile() =>
      _prefs.setString('profile', jsonEncode(profile.toJson()));
}
