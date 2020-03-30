import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'deviceInfo.dart';

final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final String _myServerUrl = "http://10.0.2.2:8080";

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
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String _token = "";

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  void initFirebaseCloudMessagingListeners() {
    if (Platform.isIOS) _iosPermission();

    _firebaseMessaging.getToken().then((token) {
      _token = token;
      print('my token:' + token);

      http.post("$_myServerUrl/notifications/tokens", body: {
        "userId": _deviceData['deviceId'],
        "token": token
      }).then((response) {
        if (response.statusCode == 200) {
          print("토큰 등록 성공!");
        } else {
          print("토큰 등록 실패!");
        }
      });
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message["notification"]["title"]),
              subtitle: Text(message["notification"]["body"]),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  void _iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initFirebaseCloudMessagingListeners();
  }

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

  void _handlePushMySelfEvent(BuildContext context) {
    http.post("$_myServerUrl/notifications/messages",
        body: jsonEncode({
          "targetTokens": [_token],
          "title": "제목이다.",
          "content": "내용이다."
        }),
        headers: {'Content-Type': "application/json"}).then((response) {
      print(jsonDecode(response.body));
      if (jsonDecode(response.body)["failureCount"] == 0) {
        print("푸시 전송 성공!");
      } else {
        print("푸시 전송 실패!");
      }
    });
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
                Row(
                  children: [
                    FlatButton(
                      child: Text("Push my self"),
                      onPressed: () => _handlePushMySelfEvent(context),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
