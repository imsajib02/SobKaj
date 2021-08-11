import 'package:flutter/material.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/user_presenter.dart';

class ChangePhone extends StatefulWidget {

  final void Function(User) onSubmit;

  ChangePhone({this.onSubmit});

  @override
  _ChangePhoneState createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _newPhone = TextEditingController();


  @override
  void initState() {

    _newPhone.text = "";
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: Row(
        children: <Widget>[

          Icon(Icons.phone, color: Colors.green, size: 35,),

          SizedBox(width: 10),

          Text(AppLocalization.of(context).getTranslatedValue("change_phone"),
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
                controller: _newPhone,
                style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                keyboardType: TextInputType.phone,
                validator: (value) {

                  if(value == null || value.isEmpty) {
                    return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                  }
                  else if(value.length != 11) {
                    return AppLocalization.of(context).getTranslatedValue("invalid_phone");
                  }
                  else if(value == currentUser.value.phone) {
                    return AppLocalization.of(context).getTranslatedValue("enter_new_phone");
                  }

                  return null;
                },
                decoration: InputDecoration(
                  labelText: AppLocalization.of(context).getTranslatedValue("new_phone"),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),
                  contentPadding: EdgeInsets.all(8),
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).getTranslatedValue("cancel"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
              ),
            ),

            SizedBox(width: 10,),

            MaterialButton(
              color: Colors.lightBlue,
              onPressed: _submit,
              child: Text(
                  AppLocalization.of(context).getTranslatedValue("change"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),

        SizedBox(height: 10),
      ],
    );
  }


  void _submit() {

    if(_formKey.currentState.validate()) {

      widget.onSubmit(User(
          id: currentUser.value.id,
          phone: _newPhone.text,
          accessToken: currentUser.value.accessToken
      ));

      Navigator.pop(context);
    }
  }
}
