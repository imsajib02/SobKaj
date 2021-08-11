import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sobkaj/models/constructor/my_web_view.dart';

class WebViewLoader extends StatefulWidget {

  final MyWebView _view;

  WebViewLoader(this._view);

  @override
  _WebViewLoaderState createState() => _WebViewLoaderState();
}

class _WebViewLoaderState extends State<WebViewLoader> with TickerProviderStateMixin {

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
          title: Text(widget._view.title,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {

            return SafeArea(
              child: WebView(
                initialUrl: widget._view.url,
                javascriptMode: JavascriptMode.unrestricted,
              ),
            );
          },
        ),
      ),
    );
  }
}