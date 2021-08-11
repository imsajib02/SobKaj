import 'package:flutter/material.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/localization/localization_constrants.dart';
import 'package:sobkaj/main.dart';
import 'package:sobkaj/utils/shared_preference.dart';

class AppLanguage extends StatefulWidget {

  @override
  _AppLanguageState createState() => _AppLanguageState();
}

class _AppLanguageState extends State<AppLanguage> {

  MySharedPreference _preference = MySharedPreference();

  String _currentValue;


  @override
  void initState() {

    _currentValue = MyApp.appLocale.languageCode;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: Row(
        children: <Widget>[

          Icon(Icons.translate),

          SizedBox(width: 10),

          Text(AppLocalization.of(context).getTranslatedValue("language"),
            style: Theme.of(context).textTheme.subtitle1,
          )
        ],
      ),
      children: <Widget>[

        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            RadioListTile(
              title: Text(AppLocalization.of(context).getTranslatedValue("english")),
              activeColor: Colors.blue,
              value: ENGLISH,
              groupValue: _currentValue,
              onChanged: (val) {

                _setAppLanguage(val);
              },
            ),

            RadioListTile(
              title: Text(AppLocalization.of(context).getTranslatedValue("bangla")),
              activeColor: Colors.blue,
              value: BANGLA,
              groupValue: _currentValue,
              onChanged: (val) {

                _setAppLanguage(val);
              },
            ),
          ],
        ),

        SizedBox(height: 20),
      ],
    );
  }


  Future<void> _setAppLanguage(String val) async {

    setState(() {
      _currentValue = val;
    });

    Locale locale = await _preference.saveLanguageCode(val);

    MyApp.setLocale(context, locale);
  }
}
