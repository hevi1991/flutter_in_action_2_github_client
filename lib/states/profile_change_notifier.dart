import 'package:flutter/material.dart';
import 'package:github_client_app/common/app_global.dart';
import 'package:github_client_app/models/index.dart';

///
class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile();
    super.notifyListeners();
  }
}

/// 用户状态
class UserModel extends ProfileChangeNotifier {
  User? get user => _profile.user;

  /// 用户是否已登录
  bool get isLogin => user != null;

  /// 用户信息发生变化，通知更新
  set user(User? user) {
    // 检查用户名是否变化
    if (user?.login != _profile.user?.login) {
      _profile.lastLogin = _profile.user?.login; // 上一次登录的用户名
      _profile.user = user; // 这次登录的用户
      notifyListeners();
    }
  }
}

/// 主题状态
class ThemeModel extends ProfileChangeNotifier {
  /// 当前主题
  MaterialColor get theme => Global.themes.firstWhere(
        (element) => element.value == _profile.theme,
        orElse: () => Colors.blue,
      );

  /// 设置主题，通知更新
  set theme(MaterialColor color) {
    if (color != theme) {
      _profile.theme = color[500]!.value;
      notifyListeners();
    }
  }
}

/// 本地化语言状态
class LocaleModel extends ProfileChangeNotifier {
  /// 获取当前用户的APP语言配置Locale类，如果为null，则语言跟随系统语言
  Locale? getLocale() {
    if (_profile.locale == null) return null;
    var t = _profile.locale!.split('_');
    return Locale(t[0], t[1]);
  }

  /// 获取当前Locale字符串
  String? get locale => _profile.locale;

  /// 设置语言，通知更新
  set locale(String? locale) {
    if (locale != _profile.locale) {
      _profile.locale = locale;
      notifyListeners();
    }
  }
}
