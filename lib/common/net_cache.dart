import 'dart:collection';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:github_client_app/common/app_global.dart';

/// 缓存对象
class CacheObject {
  CacheObject(this.response)
      : timeStamp = DateTime.now().millisecondsSinceEpoch;
  Response response;

  /// 缓存创建时间
  int timeStamp;

  // 比对是否同一uri
  @override
  bool operator ==(other) {
    return response.hashCode == other.hashCode;
  }

  @override
  int get hashCode => response.realUri.hashCode;
}

/// dio 拦截器
class NetCache extends Interceptor {
  // 为确保迭代器顺序和对象插入时间的顺序一致 <uri, CacheObject>
  // ignore: prefer_collection_literals
  var cache = LinkedHashMap<String, CacheObject>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 全局不需要缓存
    if (!(Global.profile.cache!.enable!)) {
      handler.next(options);
      return;
    }
    // refresh标记是否是下拉刷新
    bool refresh = options.extra['refresh'] == true;
    // 如果是下拉刷新，删除缓存
    if (refresh) {
      // 如果是列表，则url中包含当前path的缓存全部删除
      if (options.extra['list'] == true) {
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        _deleteCache(options.uri.toString());
      }
      handler.next(options);
      return;
    }
    // 如果未声明是【不缓存】且为【get】方法，则判断是否未过期可用
    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      String key = options.extra['cacheKey'] ?? options.uri.toString();
      var obj = cache[key];
      if (obj != null) {
        if ((DateTime.now().millisecondsSinceEpoch - obj.timeStamp) / 1000 <
            Global.profile.cache!.maxAge!) {
          handler.resolve(obj.response);
        } else {
          // 过期，删除缓存，重新获取
          cache.remove(key);
          handler.next(options);
        }
        return;
      }
    }
    // TODO: Check 如果都不是; return作用
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 拿到响应先缓存
    if (Global.profile.cache!.enable!) {
      _saveCache(response);
    }
    handler.resolve(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 错误状态不缓存
    log(err.message);
    handler.reject(err);
  }

  /// 删除缓存
  void _deleteCache(String key) {
    cache.remove(key);
  }

  /// 缓存
  void _saveCache(Response response) {
    var options = response.requestOptions;
    // 需要缓存
    if (options.extra['noCache'] != true &&
        options.method.toLowerCase() == 'get') {
      // 如果超过缓存数量，删除首位
      if (cache.length == Global.profile.cache!.maxCount) {
        cache.remove(cache.keys.first);
      }
      String key = options.extra['cacheKey'] ?? options.uri.toString();
      cache[key] = CacheObject(response);
    }
  }
}
