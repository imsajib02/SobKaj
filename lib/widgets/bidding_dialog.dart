import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/bid.dart';

class BiddingDialog extends StatefulWidget {

  final void Function(Bid) onSubmit;

  BiddingDialog({this.onSubmit});

  @override
  _BiddingDialogState createState() => _BiddingDialogState();
}

class _BiddingDialogState extends State<BiddingDialog> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _amount = TextEditingController();
  TextEditingController _note = TextEditingController();


  @override
  void initState() {

    _amount.text = "";
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

          Icon(Icons.account_circle, color: Colors.green, size: 35,),

          SizedBox(width: 10),

          Text(AppLocalization.of(context).getTranslatedValue("bid"),
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
                controller: _amount,
                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400),
                keyboardType: TextInputType.number,
                validator: (value) {

                  if(value == null || value.isEmpty) {
                    return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                  }

                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, style: BorderStyle.solid, color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, style: BorderStyle.solid, color: Colors.black26),
                  ),
                  hintText: AppLocalization.of(context).getTranslatedValue("amount"),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  hintStyle: Theme.of(context).textTheme.subtitle1.merge(
                    TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.normal),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),

              SizedBox(height: 30,),

              TextFormField(
                controller: _note,
                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 4,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(200),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, style: BorderStyle.solid, color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, style: BorderStyle.solid, color: Colors.black26),
                  ),
                  hintText: AppLocalization.of(context).getTranslatedValue("short_note"),
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

        SizedBox(height: 30),

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
              child: Text(AppLocalization.of(context).getTranslatedValue("submit"),
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

      widget.onSubmit(Bid(fee: _amount.text, note: _note.text));
      Navigator.pop(context);
    }
  }
}
