import 'package:flutter/material.dart';
import 'package:skytok_flutter/main.dart';
import 'package:skytok_flutter/screens/analytics_screen.dart';
import 'package:skytok_flutter/screens/chats_screen.dart';
import 'package:skytok_flutter/screens/profile.dart';
import 'package:skytok_flutter/screens/record.dart';
import 'package:skytok_flutter/screens/video_upload.dart';
// import 'package:skytok_flutter/temp.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  // "/Temp": (BuildContext context) => Home(),
  "/Recorder": (BuildContext context) => const RecorderScreen(),
  "/upload": (BuildContext context) => UploadScreen(
      filePath: ModalRoute.of(context)!.settings.arguments.toString()),
  "/home": (BuildContext context) => const Home(),
  "/main": (BuildContext context) => const Main(),
  "/profile": (BuildContext context) => const ProfileScreen(),
  "/chats": (BuildContext context) => const ChatsScreen(),
  "/analytics": (BuildContext context) => const AnalyticsScreen(),
};
