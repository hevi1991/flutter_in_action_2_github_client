import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:github_client_app/common/index.dart';
import 'package:github_client_app/l10n/l10n.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/states/index.dart';
import 'package:provider/provider.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  final TextEditingController _unameController = TextEditingController()
    ..text = '';
  final TextEditingController _pwdController = TextEditingController()
    ..text = '';
  bool pwdShow = false;
  final GlobalKey _formKey = GlobalKey<FormState>();
  bool _nameAutoFocus = true;

  @override
  void initState() {
    // 自动填充上次登录名
    _unameController.text = Global.profile.lastLogin ?? '';
    if (_unameController.text != '') {
      _nameAutoFocus = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appLocale = AppLocale.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.login),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: _nameAutoFocus,
                controller: _unameController,
                decoration: InputDecoration(
                  labelText: appLocale.userName,
                  hintText: appLocale.userName,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) {
                  return v!.trim().isNotEmpty
                      ? null
                      : appLocale.userNameRequired;
                },
              ),
              TextFormField(
                autofocus: !_nameAutoFocus,
                controller: _pwdController,
                decoration: InputDecoration(
                  labelText: appLocale.password,
                  hintText: appLocale.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        pwdShow = !pwdShow;
                      });
                    },
                    icon:
                        Icon(pwdShow ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                obscureText: !pwdShow,
                validator: (v) {
                  return v!.trim().isNotEmpty
                      ? null
                      : appLocale.passwordRequired;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(height: 55.0),
                  child: ElevatedButton(
                    onPressed: _onLogin,
                    child: Text(appLocale.login),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onLogin() async {
    // 验证表单
    if ((_formKey.currentState as FormState).validate()) {
      showLoading(context);
      User? user;
      try {
        user = await Git(context)
            .login(_unameController.text, _pwdController.text);
        Provider.of<UserModel>(context, listen: false).user = user;
      } on DioError catch (e) {
        if (e.response!.statusCode == HttpStatus.unauthorized) {
          showToast(AppLocale.of(context).userNameOrPasswordWrong);
        } else {
          showToast(e.response!.statusCode.toString());
        }
      } finally {
        hideLoading(context);
      }
      if (user != null) {
        // 返回首页
        Navigator.of(context).pop();
      }
    }
  }
}
