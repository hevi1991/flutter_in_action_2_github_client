import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:github_client_app/l10n/l10n.dart';
import 'package:github_client_app/states/index.dart';
import 'package:provider/provider.dart';

import 'common/index.dart';
import 'routes/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Global.init(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        debugPrint(snapshot.connectionState.toString());
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Center(
              child: Text('Initing.'),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ThemeModel()),
            ChangeNotifierProvider.value(value: UserModel()),
            ChangeNotifierProvider.value(value: LocaleModel()),
          ],
          child: Consumer2<ThemeModel, LocaleModel>(
            builder: (
              BuildContext context,
              ThemeModel themeModel,
              LocaleModel localeModel,
              Widget? child,
            ) {
              return MaterialApp(
                theme: ThemeData(
                  primarySwatch: themeModel.theme,
                ),
                locale: localeModel.getLocale(),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  AppLocale.delegate,
                ],
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('zh', 'CN'),
                ],
                localeResolutionCallback:
                    (Locale? _locale, Iterable<Locale> supportedLocales) {
                  if (localeModel.getLocale() != null) {
                    // 选了语言，不跟随系统
                    return localeModel.getLocale();
                  } else {
                    Locale locale;
                    //APP语言跟随系统语言，如果系统语言不是中文简体或美国英语，
                    //则默认使用美国英语
                    if (supportedLocales.contains(_locale)) {
                      locale = _locale!;
                    } else {
                      locale = const Locale('en', 'US');
                    }
                    return locale;
                  }
                },
                onGenerateTitle: (context) => AppLocale.of(context).title,
                routes: {
                  "login": (context) => const LoginRoute(),
                  "themes": (context) => const ThemeChangeRoute(),
                  "language": (context) => const LanguageRoute(),
                },
                home: const HomeRoute(),
              );
            },
          ),
        );
      },
    );
  }
}
