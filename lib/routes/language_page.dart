import 'package:flutter/material.dart';
import 'package:github_client_app/l10n/l10n.dart';
import 'package:github_client_app/states/index.dart';
import 'package:provider/provider.dart';

class LanguageRoute extends StatelessWidget {
  const LanguageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryColor;
    var localeModel = Provider.of<LocaleModel>(context);
    var appLocale = AppLocale.of(context);

    Widget _buildLanguageItem(String lan, value) {
      return ListTile(
        title: Text(
          lan,
          style: TextStyle(color: localeModel.locale == value ? color : null),
        ),
        trailing: localeModel.locale == value ? const Icon(Icons.done) : null,
        onTap: () {
          localeModel.locale = value;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocale.language),
      ),
      body: ListView(
        children: [
          _buildLanguageItem('中文简体', 'zh_CN'),
          _buildLanguageItem('English', 'en_US'),
          _buildLanguageItem(appLocale.auto, null),
        ],
      ),
    );
  }
}
