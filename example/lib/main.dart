import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:static_webview/static_webview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = "Google search";
    urlController.text = "https://google.com?q=Salam";
  }

  void showStaticWebView() {
    StaticWebView.showStaticWebView(StaticWebViewConfig(
            Uri.parse(urlController.text.trim()), titleController.text.trim()))
        .then((value) => print("Closed static webview"))
        .catchError((error) => print("Error occurred ${error.toString()}"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            height: 400,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(labelText: "URL"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Title"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(height: 44.0, width: double.infinity, child: RaisedButton(child: Text("Show") , onPressed: showStaticWebView))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
