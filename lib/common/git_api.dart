import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:github_client_app/models/index.dart';

import 'index.dart';

/// 专门用于Github API接口调用
class Git {
  Git([this.context]) {
    _options = Options(extra: {'context': context});
  }

  // 在网络请求过程中可能会需要使用当前的context信息，比如在请求失败时
  // 打开一个新路由，而打开新路由需要context信息。
  BuildContext? context;
  late Options _options;

  /// 请求用Dio实例
  static Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com/',
      headers: {
        HttpHeaders.acceptHeader:
            "application/vnd.github.squirrel-girl-preview,"
                "application/vnd.github.symmetra-preview+json",
      },
    ),
  );

  /// 初始化
  static void init() {
    // 添加缓存拦截器
    dio.interceptors.add(Global.netCache);
    // 配置登录信息，null为未登录
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
/* 
    if (!Global.isRelease) {
      // 抓包代理，调试
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          return "PROXY 192.168.33.112:9527";
        };
        // 禁用证书认证
        client.badCertificateCallback = (cert, host, port) => true;
      };
    } */
  }

  /// 登录接口
  Future<User> login(String login, String pwd) async {
    String basic = 'Basic ' + base64.encode(utf8.encode('$login:$pwd'));
    var r = await dio.get(
      '/user',
      options: _options.copyWith(headers: {
        HttpHeaders.authorizationHeader: basic
      }, extra: {
        'noCache': true, // 此接口禁用缓存
      }),
    );

    // 登录成功后，更新公共头，做完凭证
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    // 清空所有缓存
    Global.netCache.cache.clear();
    // 更新profile的token
    Global.profile.token = basic;
    return User.fromJson(r.data);
  }

  /// 用户库
  Future<List<Repo>> getRepos({
    Map<String, dynamic>? queryParameters,
    refresh = false,
  }) async {
    if (refresh) {
      // 列表下拉刷新，需要删除缓存
      _options.extra!.addAll({'refresh': true, 'list': true});
    }
    var r = await dio.get<List>(
      'user/repos',
      queryParameters: queryParameters,
      options: _options,
    );

    return r.data?.map((e) => Repo.fromJson(e)).toList() ?? [];
  }
}
