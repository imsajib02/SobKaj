import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/theme/app_theme.dart';
import 'package:sobkaj/theme/apptheme_notifier.dart';
import 'package:sobkaj/utils/custom_log.dart';
import 'package:sobkaj/utils/custom_trace.dart';
import 'package:sobkaj/utils/fcm_setup.dart';
import 'package:sobkaj/utils/shared_preference.dart';
import 'package:sobkaj/utils/size_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_localization.dart';

void main() {

  LicenseRegistry.addLicense(() async* {

    final license1 = await rootBundle.loadString('google_fonts/BOR_OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license1);

    final license2 = await rootBundle.loadString('google_fonts/KO_OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license2);
  });

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {

    runApp(
      ChangeNotifierProvider<AppThemeNotifier>(
        create: (context) => AppThemeNotifier(),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {

  static Locale appLocale;

  @override
  _MyAppState createState() => _MyAppState();


  static void setLocale(BuildContext context, Locale locale) {

    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {

  Locale _locale;
  MySharedPreference _mSharedPreference;


  @override
  void initState() {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(0xffFFFFF0),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
    ));

    FCMSetup().conFigureFirebase(context);
    _mSharedPreference = MySharedPreference();

    super.initState();
  }


  @override
  void didChangeDependencies() {

    _mSharedPreference.getLanguageCode().then((locale) {
      setLocale(locale);
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {

              SizeConfig().init(constraints, orientation);

              return Consumer<AppThemeNotifier>(
                builder: (context, appThemeState, child) {

                  return MaterialApp(
                    title: "Kaj",
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: appThemeState.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
                    locale: _locale,
                    localizationsDelegates: [
                      AppLocalization.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: [
                      Locale("en", "US"),
                      Locale("bn", "BD"),
                    ],
                    localeResolutionCallback: (Locale deviceLocale, Iterable<Locale> supportedLocales) {

                      for(var locale in supportedLocales) {

                        if(locale.languageCode == deviceLocale.languageCode &&
                            locale.countryCode == deviceLocale.countryCode) {

                          return deviceLocale;
                        }
                      }

                      return supportedLocales.first;
                    },
                    onGenerateRoute: RouteManager.generate,
                    initialRoute: RouteManager.SPLASH_SCREEN,
                  );
                },
              );
            },
          );
        }
    );
  }


  void setLocale(Locale locale) {

    CustomLogger.info(trace: CustomTrace(StackTrace.current),
        tag: "App Language",
        message: locale.languageCode);

    setState(() {
      MyApp.appLocale = locale;
      _locale = locale;
    });
  }
}
