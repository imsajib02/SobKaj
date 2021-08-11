import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/job_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/main.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/job_detail.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/payment.dart';
import 'package:sobkaj/presenter/JobPresenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/image_compressor.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_datetime.dart';
import 'package:sobkaj/utils/size_config.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class JobPost extends StatefulWidget {

  final JobService _service;

  JobPost(this._service);

  @override
  _JobPostState createState() => _JobPostState();
}

class _JobPostState extends State<JobPost> with TickerProviderStateMixin implements JobContract, Connectivity {

  JobPresenter _presenter;

  JobContract _contract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  CameraPosition _initialPosition = CameraPosition(
    bearing: 0.0,
    tilt: 0.0,
    target: LatLng(23.759398, 90.378904),
    zoom: 6.5,
  );

  LatLng _centerLatLng;

  List<bool> _posterCheck = [true, false];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _desController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _feeController = TextEditingController();

  FocusNode _phoneNode = FocusNode();
  FocusNode _titleNode = FocusNode();
  FocusNode _desNode = FocusNode();
  FocusNode _feeNode = FocusNode();

  final _bounceKey = GlobalKey<BounceState>();
  final _formKey = GlobalKey<FormState>();

  Job _job = Job(details: JobDetails(list: List()));

  List<File> _images = [File(""), File(""), File("")];


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();
    
    _contract = this;
    _connectivity = this;
    _presenter = JobPresenter(_connectivity, jobContract: _contract);
    
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {

        return Future(() => true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 3,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("post_job"),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {

            return SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 50),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("post_for"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(width: 1, color: Colors.black54)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    Checkbox(
                                      activeColor: Colors.blueAccent,
                                      checkColor: Colors.white,
                                      value: _posterCheck[0],
                                      onChanged: (value) {

                                        _setPosterType(0);
                                      },
                                    ),

                                    Text(AppLocalization.of(context).getTranslatedValue("myself"),
                                      style: Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 20,),

                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(width: 1, color: Colors.black54)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    Checkbox(
                                      activeColor: Colors.blueAccent,
                                      checkColor: Colors.white,
                                      value: _posterCheck[1],
                                      onChanged: (value) {

                                        _setPosterType(1);
                                      },
                                    ),

                                    Text(AppLocalization.of(context).getTranslatedValue("guest"),
                                      style: Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        Visibility(
                          visible: _posterCheck[1],
                          child: Padding(
                            padding: EdgeInsets.only(top: 40, bottom: 15, left: 5),
                            child: Text(AppLocalization.of(context).getTranslatedValue("guest_name"),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),

                        Visibility(
                          visible: _posterCheck[1],
                          child: TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                            onFieldSubmitted: (string) {
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {

                              if(value == null || value.isEmpty) {
                                return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                              }
                              else if(value.length < 3) {
                                return AppLocalization.of(context).getTranslatedValue("invalid_name");
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              fillColor: Colors.white70,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: _posterCheck[1] ? 20 : 40, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("mdate"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {

                            _selectDate(context);
                          },
                          child: TextFormField(
                            controller: _dateController,
                            keyboardType: TextInputType.text,
                            enabled: false,
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.date_range, color: Colors.transparent,),
                              suffixIcon: Icon(Icons.date_range, color: Colors.grey,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              fillColor: Colors.white70,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("time"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {

                            _selectTime(context);
                          },
                          child: TextFormField(
                            controller: _timeController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            enabled: false,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.date_range, color: Colors.transparent,),
                              suffixIcon: Icon(Icons.date_range, color: Colors.grey,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                              fillColor: Colors.white70,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("phone"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          focusNode: _phoneNode,
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                          onFieldSubmitted: (string) {
                            _titleNode.requestFocus();
                          },
                          validator: (value) {

                            if(value == null || value.isEmpty) {
                              return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                            }
                            else if(value.length != 11) {
                              return AppLocalization.of(context).getTranslatedValue("invalid_phone");
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            prefixStyle: Theme.of(context).textTheme.subtitle2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                            fillColor: Colors.white70,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 40, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("job_title"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        TextFormField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusNode: _titleNode,
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                          onFieldSubmitted: (string) {
                            _desNode.requestFocus();
                          },
                          validator: (value) {

                            if(value == null || value.isEmpty) {
                              return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            prefixStyle: Theme.of(context).textTheme.subtitle2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                            fillColor: Colors.white70,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("description"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        TextFormField(
                          controller: _desController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 6,
                          textInputAction: TextInputAction.next,
                          focusNode: _desNode,
                          style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(250),
                          ],
                          onFieldSubmitted: (string) {
                            _feeNode.requestFocus();
                          },
                          validator: (value) {

                            if(value == null || value.isEmpty) {
                              return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            prefixStyle: Theme.of(context).textTheme.subtitle2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                            fillColor: Colors.white70,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("your_fee"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        TextFormField(
                          controller: _feeController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          focusNode: _feeNode,
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                          onFieldSubmitted: (string) {

                            FocusScope.of(context).unfocus();
                          },
                          validator: (value) {

                            if(value == null || value.isEmpty) {
                              return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            prefixStyle: Theme.of(context).textTheme.subtitle2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                            fillColor: Colors.white70,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 40, bottom: 25, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("location"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        Visibility(
                          visible: _job.address != null && _job.address.isNotEmpty,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
                            child: Text(_job.address == null ? "" : _job.address,
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black.withOpacity(.65), fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),

                        Container(
                          height: 450,
                          child: Stack(
                            children: <Widget>[

                              GoogleMap(
                                initialCameraPosition: _initialPosition,
                                onTap: (LatLng latLng) {},
                                onLongPress: (LatLng latLng) {},
                                onMapCreated: (GoogleMapController controller) async {

                                  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                                  controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 18));
                                },
                                onCameraMove: (CameraPosition cameraPosition) {

                                  _centerLatLng = cameraPosition.target;
                                  _job.location = _centerLatLng.latitude.toString() + "," + _centerLatLng.longitude.toString();
                                },
                                onCameraIdle: () async {

                                  try {

                                    if(_centerLatLng != null) {

                                      final coordinates = Coordinates(_centerLatLng.latitude, _centerLatLng.longitude);
                                      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

                                      setState(() {
                                        _job.address = addresses.first.addressLine;
                                      });
                                    }
                                  }
                                  catch(error) {}
                                },
                                compassEnabled: false,
                                zoomControlsEnabled: true,
                                mapToolbarEnabled: false,
                                mapType: MapType.normal,
                                myLocationEnabled: false,
                                myLocationButtonEnabled: false,
                                trafficEnabled: false,
                                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                  new Factory<OneSequenceGestureRecognizer>(
                                        () => new EagerGestureRecognizer(),
                                  ),
                                ].toSet(),
                              ),

                              Align(
                                alignment: Alignment.center,
                                child: Image.asset("assets/images/location_marker.png", height: 55,),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 40, bottom: 15, left: 5),
                          child: Text(AppLocalization.of(context).getTranslatedValue("add_images"),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[

                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {

                                  _pickImage(0);
                                },
                                child: Stack(
                                  children: <Widget>[

                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(image: FileImage(_images[0]), fit: BoxFit.cover),
                                      ),
                                      child: Visibility(
                                        visible: _images[0] == null || _images[0].path.isEmpty,
                                        child: Icon(Icons.add, color: Theme.of(context).accentColor, size: 25,),
                                      ),
                                    ),

                                    Visibility(
                                      visible: _images[0] != null && _images[0].path.isNotEmpty,
                                      child: Positioned(
                                        top: 7,
                                        right: 7,
                                        child: GestureDetector(
                                          onTap: () {

                                            _clearImage(0);
                                          },
                                          child: CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Theme.of(context).accentColor,
                                            child: Icon(Icons.clear, size: 18, color: Colors.red,),
                                      ),
                                        )),
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {

                                  _pickImage(1);
                                },
                                child: Stack(
                                  children: <Widget>[

                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(image: FileImage(_images[1]), fit: BoxFit.cover),
                                      ),
                                      child: Visibility(
                                        visible: _images[1] == null || _images[1].path.isEmpty,
                                        child: Icon(Icons.add, color: Theme.of(context).accentColor, size: 25,),
                                      ),
                                    ),

                                    Visibility(
                                      visible: _images[1] != null && _images[1].path.isNotEmpty,
                                      child: Positioned(
                                          top: 7,
                                          right: 7,
                                          child: GestureDetector(
                                            onTap: () {

                                              _clearImage(1);
                                            },
                                            child: CircleAvatar(
                                              radius: 13,
                                              backgroundColor: Theme.of(context).accentColor,
                                              child: Icon(Icons.clear, size: 18, color: Colors.red,),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {

                                  _pickImage(2);
                                },
                                child: Stack(
                                  children: <Widget>[

                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(image: FileImage(_images[2]), fit: BoxFit.cover),
                                      ),
                                      child: Visibility(
                                        visible: _images[2] == null || _images[2].path.isEmpty,
                                        child: Icon(Icons.add, color: Theme.of(context).accentColor, size: 25,),
                                      ),
                                    ),

                                    Visibility(
                                      visible: _images[2] != null && _images[2].path.isNotEmpty,
                                      child: Positioned(
                                          top: 7,
                                          right: 7,
                                          child: GestureDetector(
                                            onTap: () {

                                              _clearImage(2);
                                            },
                                            child: CircleAvatar(
                                              radius: 13,
                                              backgroundColor: Theme.of(context).accentColor,
                                              child: Icon(Icons.clear, size: 18, color: Colors.red,),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 65),
                          child: BounceAnimation(
                            key: _bounceKey,
                            childWidget: RaisedButton(
                              padding: EdgeInsets.all(0),
                              elevation: 5,
                              onPressed: () {

                                _bounceKey.currentState.animationController.forward();
                                FocusScope.of(context).unfocus();

                                _validateForm(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0))
                                ),
                                child: Text(AppLocalization.of(context).getTranslatedValue("post").toUpperCase(),
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  void dispose() {

    _connectivityChecker.removeStatusListener();
    _connectionAlert.controller.dispose();
    super.dispose();
  }


  void _setPosterType(int position) {

    if(position < _posterCheck.length && !_posterCheck[position]) {

      _nameController.text = "";
      _phoneController.text = "";

      _job.guestName = null;
      _job.phone = null;

      for(int i=0; i<_posterCheck.length; i++) {

        setState(() {

          if(i == position) {

            _posterCheck[i] = true;
          }
          else {

            _posterCheck[i] = false;
          }
        });
      }
    }
  }


  Future<void> _selectDate(BuildContext context) async {

    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.day,
      helpText: AppLocalization.of(context).getTranslatedValue("birthdate"),
      locale: MyApp.appLocale,
    );

    _dateController.text = MyDateTime.getDate(dateTime);
    _job.date = _dateController.text;

    FocusScope.of(context).requestFocus(FocusNode());
  }


  Future<void> _selectTime(BuildContext context) async {

    final TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    _timeController.text = time.format(context);
    _job.time = _timeController.text;

    FocusScope.of(context).requestFocus(FocusNode());
  }


  void _pickImage(int position) async {

    try {

      var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
      File file = await ImageCompressor.compress(File(pickedFile.path), 20);

      setState(() {
        _images[position] = file;
      });

    } catch(error) {

      print(error);
    }
  }


  void _clearImage(int position) {

    setState(() {
      _images[position] = File("");
    });
  }


  void _validateForm(BuildContext context) {

    if(_dateController.text.isEmpty) {

      _onInvalid(context, AppLocalization.of(context).getTranslatedValue("set_date"));
    }
    else {

      if(_timeController.text.isEmpty) {

        _onInvalid(context, AppLocalization.of(context).getTranslatedValue("set_time"));
      }
      else {

        if(_formKey.currentState.validate()) {

          if(_job.location != null && _job.location.isNotEmpty) {

            if(_images[0].path.isEmpty && _images[1].path.isEmpty && _images[2].path.isEmpty) {

              _onInvalid(context, AppLocalization.of(context).getTranslatedValue("add_related_image"));
            }
            else {

              _job.serviceID = widget._service.id;
              _job.providerID = currentUser.value.id;
              _job.phone = _phoneController.text;
              _job.guestName = _nameController.text;
              _job.title = _titleController.text;
              _job.description = _desController.text;
              _job.fee = _feeController.text;

              _job.details.list.clear();

              for(int i=0; i<_images.length; i++) {

                if(_images[i] != null && _images[i].path.isNotEmpty) {

                  _job.details.list.add(JobDetail(image: _images[i].path));
                }
              }

              _presenter.postJob(context, _job);
            }
          }
          else {

            _onInvalid(context, AppLocalization.of(context).getTranslatedValue("location"));
          }
        }
      }
    }
  }


  void _onInvalid(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  

  @override
  void onConnected(BuildContext context) {

    if(_connectionAlert != null && _connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.reverse();
    }
  }
  

  @override
  void onDisconnected(BuildContext context) {

    if(_connectionAlert != null && !_connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.forward();
    }
  }
  

  @override
  void onJobPosted(BuildContext context, Job job) {

    Navigator.pop(context, AppLocalization.of(context).getTranslatedValue("job_post_success"));
  }
  

  @override
  void onJobUpdated(BuildContext context, Job job) {}
  

  @override
  void onPostFailed(BuildContext context) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("job_post_failed"))));
  }
  

  @override
  void onTimeout(BuildContext context) {

    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).getTranslatedValue("connection_time_out"),
          ),
    ));
  }
  

  @override
  void onUpdateFailed(BuildContext context, String message) {}


  @override
  void onFailedToGetJobs(BuildContext context, String message) {}


  @override
  void showJobList(List<Job> jobs) {}


  @override
  void onPaymentConfirm(BuildContext context, Payment payment) {}


  @override
  void onPaymentConfirmFailed(BuildContext context, String message) {}
}