import 'package:intl/intl.dart';
import 'package:sobkaj/main.dart';

class MyDateTime {

  static final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  static final DateFormat _yearMonthDay = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormatter = DateFormat('MMMM d, y hh:mm a');
  static final DateFormat _dateFormatter = DateFormat('MMMM d, y');
  static final DateFormat _localeFormatter = DateFormat('dd-MM-yyyy', MyApp.appLocale.languageCode);

  static String getDate(DateTime dateTime) {

    return _formatter.format(dateTime);
  }

  static String getDatabaseFormat(DateTime dateTime) {

    return _yearMonthDay.format(dateTime);
  }

  static String getDateTime(DateTime dateTime) {

    return _dateTimeFormatter.format(dateTime);
  }

  static String getLocaleDate(DateTime dateTime) {

    return _localeFormatter.format(dateTime);
  }

  static String getMonthData(DateTime dateTime) {

    return _dateFormatter.format(dateTime);
  }
}