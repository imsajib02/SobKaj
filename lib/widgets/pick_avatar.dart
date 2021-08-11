import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/utils/image_compressor.dart';

class PickAvatar extends StatefulWidget {

  final void Function(File) onSubmit;

  PickAvatar({this.onSubmit});

  @override
  _PickAvatarState createState() => _PickAvatarState();
}

class _PickAvatarState extends State<PickAvatar> {

  File _file;
  FileImage _image;

  @override
  Widget build(BuildContext context) {

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Text(AppLocalization.of(context).getTranslatedValue("profile_image"),
              style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w300),
            ),

            SizedBox(height: 20,),

            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: CircleAvatar(
                radius: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(300)),
                  child: Icon(Icons.camera_alt, size: 65, color: _image == null ? Colors.white : Colors.transparent,),
                ),
                backgroundImage: _image,
              ),
            ),

            SizedBox(height: 25,),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text(AppLocalization.of(context).getTranslatedValue("cancel"),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10,),

                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {

                      widget.onSubmit(_file);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      color: Colors.lightBlue,
                      child: Text(AppLocalization.of(context).getTranslatedValue("update"),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }


  void _pickImage() async {

    try {

      var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
      _file = await ImageCompressor.compress(File(pickedFile.path), 20);

      setState(() {
        _image = FileImage(_file);
      });

    } catch(error) {

      print(error);
    }
  }
}