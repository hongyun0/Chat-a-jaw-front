import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '찾아줘',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '찾아줘'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _showToast(BuildContext context, String message) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: new Text(message),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void _handleApplyEvent(BuildContext context) {
    http
        .get("https://google.com")
        .then((response) => _showToast(context, response.body));
  }

  void _handleClearEvent(BuildContext context) {
    http
        .get("https://google.com")
        .then((response) => _showToast(context, response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'KEYWORD',
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal)),
                        enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal)),
                      ),
                    )),
                Row(
                  children: [
                    FlatButton(
                      child: Text("Apply"),
                      onPressed: () => _handleApplyEvent(context),
                    ),
                    FlatButton(
                        child: Text("Clear"),
                        onPressed: () => _handleClearEvent(context)),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
            ),
          ),
        ));
  }
}
