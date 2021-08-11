import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/size_config.dart';

class AllService extends StatefulWidget {

  @override
  _AllServiceState createState() => _AllServiceState();
}

class _AllServiceState extends State<AllService> {

  List<Color> _colors = [Color(0xffd0fffe), Color(0xfffffddb), Color(0xffe4ffde), Color(0xffffd3fd), Color(0xffffe7d3)];

  TextEditingController _controller = TextEditingController();

  List<JobService> _filterList = [];


  @override
  void initState() {

    _controller.text = "";
    _filterList = settings.value.services.list;

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
          elevation: 3,
          automaticallyImplyLeading: true,
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("services"),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[

                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onChanged: (string) {

                            _search(string);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.black45,),
                            hintText: AppLocalization.of(context).getTranslatedValue("search"),
                            hintStyle: Theme.of(context).textTheme.subtitle2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 8,
                      child: GridView.builder(
                        itemCount: _filterList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: .85,
                        ),
                        itemBuilder: (context, index) {

                          return Visibility(
                            visible: _filterList[index].status == Constants.ACTIVE,
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {

                                  final result = await Navigator.of(context).pushNamed(RouteManager.JOB_POST, arguments: settings.value.services.list.first);

                                  if(result != null && result.toString().isNotEmpty) {

                                    Scaffold.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(SnackBar(content: Text("$result")));
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: _colors[index % _colors.length],
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CachedNetworkImage(imageUrl: _filterList[index].imageUrl, fit: BoxFit.cover,),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(_filterList[index].name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w500)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  void _search(String string) {

    List<JobService> _mList = [];

    for(int i=0; i<settings.value.services.list.length; i++) {

      if(settings.value.services.list[i].name.toLowerCase().startsWith(string.toLowerCase())) {

        _mList.add(settings.value.services.list[i]);
      }
    }

    setState(() {
      _filterList = _mList;
    });
  }
}