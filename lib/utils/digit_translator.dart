import 'package:sobkaj/utils/constants.dart';

class DigitTranslator {

  static Future<String> toBangla(int number) async {

    String inBangla = "";

    for(int i=0; i<number.toString().length; i++) {

      for(int j=0; j<Constants.englishNumeric.length; j++) {

        if(number.toString()[i] == Constants.englishNumeric[j]) {

          inBangla = inBangla + Constants.banglaNumeric[j];
          break;
        }
      }
    }

    return inBangla;
  }
}