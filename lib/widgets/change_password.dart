import 'package:flutter/material.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/user_presenter.dart';

class ChangePassword extends StatefulWidget {

  final void Function(User) onSubmit;

  ChangePassword({this.onSubmit});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();


  @override
  void initState() {

    _oldPassword.text = "";
    _newPassword.text = "";
    _confirmPassword.text = "";

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: Row(
        children: <Widget>[

          Icon(Icons.lock, color: Colors.green, size: 35,),

          SizedBox(width: 10),

          Text(AppLocalization.of(context).getTranslatedValue("change_password"),
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
                controller: _oldPassword,
                style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                keyboardType: TextInputType.text,
                obscureText: true,
                validator: (value) {

                  if(value == null || value.isEmpty) {
                    return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                  }
                  else if(value.length < 8) {
                    return AppLocalization.of(context).getTranslatedValue("must_be_8_char");
                  }

                  return null;
                },
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  labelText: AppLocalization.of(context).getTranslatedValue("old_password"),
                  hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.normal),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),
                  contentPadding: EdgeInsets.all(5),
                ),
              ),

              SizedBox(height: 20,),

              TextFormField(
                style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: _newPassword,
                validator: (value) {

                  if(value == null || value.isEmpty) {
                    return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                  }
                  else if(value.length < 8) {
                    return AppLocalization.of(context).getTranslatedValue("must_be_8_char");
                  }
                  else if(value == _oldPassword.text) {
                    return AppLocalization.of(context).getTranslatedValue("can_not_be_old_pass");
                  }

                  return null;
                },
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  labelText: AppLocalization.of(context).getTranslatedValue("new_password"),
                  hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.normal),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),
                ),
              ),

              SizedBox(height: 20,),

              TextFormField(
                controller: _confirmPassword,
                style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                keyboardType: TextInputType.text,
                obscureText: true,
                validator: (value) {

                  if(value == null || value.isEmpty) {
                    return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                  }
                  else if(value.length < 8) {
                    return AppLocalization.of(context).getTranslatedValue("must_be_8_char");
                  }
                  else if(value != _newPassword.text) {
                    return AppLocalization.of(context).getTranslatedValue("confirm_pass_not_match");
                  }

                  return null;
                },
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  labelText: AppLocalization.of(context).getTranslatedValue("confirm_password"),
                  hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: Theme.of(context).hintColor, fontWeight: FontWeight.normal),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w300),
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

      widget.onSubmit(User(password: _oldPassword.text,
          newPassword: _newPassword.text,
          confirmPassword: _confirmPassword.text,
          accessToken: currentUser.value.accessToken
      ));

      Navigator.pop(context);
    }
  }
}
