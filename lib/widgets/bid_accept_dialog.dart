import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/theme/apptheme_notifier.dart';

class BidAcceptDialog extends StatefulWidget {

  final void Function(String) onSubmit;

  BidAcceptDialog({this.onSubmit});

  @override
  _BidAcceptDialogState createState() => _BidAcceptDialogState();
}

class _BidAcceptDialogState extends State<BidAcceptDialog> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _note = TextEditingController();


  @override
  void initState() {

    _note.text = "";
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: Row(
        children: <Widget>[

          Icon(Icons.info, color: Colors.green, size: 35,),

          SizedBox(width: 10),

          Text(AppLocalization.of(context).getTranslatedValue("confirmation"),
            style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w300),
          )
        ],
      ),
      children: <Widget>[

        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              TextFormField(
                controller: _note,
                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 5,
                validator: (value) {

                  if(value == null || value.isEmpty) {
                    return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                  }

                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(200),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                  ),
                  filled: true,
                  fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.black12.withOpacity(.035) : Colors.white.withOpacity(.3),
                  hintText: AppLocalization.of(context).getTranslatedValue("short_note"),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  hintStyle: Theme.of(context).textTheme.subtitle1.merge(
                    TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.normal),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[

            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).getTranslatedValue("no")),
            ),

            SizedBox(width: 20,),

            MaterialButton(
              color: Colors.lightBlueAccent,
              textColor: Colors.white,
              onPressed: _submit,
              child: Text(
                  AppLocalization.of(context).getTranslatedValue("yes")),
            ),
          ],
        ),

        SizedBox(height: 10),
      ],
    );
  }


  void _submit() {

    if(_formKey.currentState.validate()) {

      widget.onSubmit(_note.text);
      Navigator.pop(context);
    }
  }
}
