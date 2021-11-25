import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:github_client_app/common/index.dart';
import 'package:github_client_app/l10n/l10n.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/states/index.dart';
import 'package:github_client_app/widgets/pull_refresh_indicator.dart';
import 'package:github_client_app/widgets/repo_avatar.dart';
import 'package:github_client_app/widgets/repo_item.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({Key? key}) : super(key: key);

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  int page = 1;
  int _perPage = 30;
  List<Repo> _data = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // 初始数据
    _getData(page, true);
    super.initState();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        showLoading(context);
        page = ((_data.length / _perPage).ceil()) + 1;
        await _getData(page, true);
        hideLoading(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.of(context).home),
      ),
      body: _buildBody(context),
      drawer: const MyDrawer(),
    );
  }

  _buildBody(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    if (!userModel.isLogin) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('login');
          },
          child: Text(AppLocale.of(context).login),
        ),
      );
    } else {
      return PullRefreshIndicator(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _data.length,
          itemBuilder: (BuildContext context, int index) {
            return RepoItem(_data[index]);
          },
        ),
        onRefresh: () async {
          try {
            page = 1;
            await _getData(page, true);
          } on Exception catch (e) {
            log(e.toString());
          }
        },
      );
    }
  }

  _getData(int page, bool refresh) async {
    var data = await Git(context).getRepos(
      refresh: refresh,
      queryParameters: {'page': page, 'per_page': _perPage},
    );
    if (data.length < _perPage) {
      showToast(AppLocale.of(context).noMore);
    }
    setState(() {
      if (page == 1) {
        _data = data;
      } else {
        _data.addAll(data);
      }
    });
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildMeus()),
          ],
        ),
      ),
    );
  }

  /// 抽屉头
  Widget _buildHeader() {
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel value, Widget? child) {
        return GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipOval(
                    child: value.isLogin
                        ? AppAvatar(
                            value.user!.avatar_url!,
                            width: 80,
                          )
                        : Image.asset(
                            'imgs/avatar-default.png',
                            width: 80,
                          ),
                  ),
                ),
                Text(
                  value.isLogin
                      ? value.user!.login!
                      : AppLocale.of(context).login,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            if (!value.isLogin) {
              Navigator.of(context).pushNamed('login');
            }
          },
        );
      },
    );
  }

  /// 抽屉菜单
  Widget _buildMeus() {
    return Consumer2<UserModel, LocaleModel>(builder: (BuildContext context,
        UserModel userModel, LocaleModel localeModel, Widget? child) {
      var appLocale = AppLocale.of(context);
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(appLocale.theme),
            onTap: () {
              Navigator.of(context).pushNamed('themes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(appLocale.language),
            onTap: () {
              Navigator.of(context).pushNamed('language');
            },
          ),
          if (userModel.isLogin)
            ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: Text(appLocale.logout),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(appLocale.logoutTip),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // 关闭Dialog
                            Navigator.pop(context);
                          },
                          child: Text(appLocale.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            userModel.user = null;
                            Navigator.pop(context);
                          },
                          child: Text(appLocale.yes),
                        ),
                      ],
                    );
                  },
                );
              },
            )
        ],
      );
    });
  }
}
