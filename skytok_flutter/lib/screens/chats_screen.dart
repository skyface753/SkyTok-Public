import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skytok_flutter/models/chat.dart';
import 'package:skytok_flutter/screens/messages_screen.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;

import 'package:path/path.dart';
import 'package:skytok_flutter/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late Timer _timer;
  final NotificationService _notificationService = NotificationService();
  Function eq = const ListEquality().equals;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _notificationService.init();
    _timer = Timer.periodic(Duration(seconds: 20), (Timer t) {
      _loadChats();
    });
    _loadChats();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool chatsLoaded = false;

  List<Chat> chats = [];

  _loadChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (chats.isEmpty) {
      prefs.getString('chats')?.isNotEmpty ?? false
          ? setState(
              () {
                print("Chats loaded from prefs");
                var tempChats = (json.decode(prefs.getString('chats')!) as List)
                    .map((chat) => Chat.fromJson(chat))
                    .toList();
                if (tempChats != chats) {
                  chats = tempChats;
                }
                chatsLoaded = true;
              },
            )
          : chats = [];
    }
    var value = await api.getChats(this.context);
    Iterable list = value;
    chats = list.map((model) => Chat.fromJson(model)).toList();

    setState(() {
      print("Chats loaded from API");
      chatsLoaded = true;
    });

    // Init shared prefs
    prefs.setString('chats', json.encode(chats));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadChats();
            },
          ),
        ],
      ),
      body: chatsLoaded
          ? ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chats[index].username),
                  subtitle: chats[index].message.startsWith("§§")
                      ? Text(chats[index].latest + '\n' + "Video")
                      : Text(chats[index].latest + '\n' + chats[index].message),
                  // Rounded unReaded Text as a badge
                  trailing: chats[index].unReaded == "0"
                      ? null
                      : Text(
                          chats[index].unReaded.toString(),
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // textDirection: TextDirection.rtl,
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagesScreen(
                          otherUserId: chats[index].userId,
                          otherUserName: chats[index].username,
                          picturePath: chats[index].picturePath ?? null,
                        ),
                      ),
                    ).then((value) {
                      _loadChats();
                      // inspect(chats);
                    });
                  },
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
