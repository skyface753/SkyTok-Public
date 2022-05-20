import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:video_player/video_player.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:web_socket_channel/io.dart';

class WatchLiveStreamScreen extends StatefulWidget {
  final int userId;
  const WatchLiveStreamScreen(this.userId, {Key? key}) : super(key: key);

  @override
  _WatchLiveStreamScreenState createState() => _WatchLiveStreamScreenState();
}

class _WatchLiveStreamScreenState extends State<WatchLiveStreamScreen> {
  late VideoPlayerController _videoPlayerController1;
  late ChewieController _chewieController;

  late IOWebSocketChannel channel;
  bool connected = false;
  bool joined = false;
  String streamKey = "";
  bool hasError = false;

  int liveCount = 0;

  late Timer timer;

  List<MessageData> msglist = [];

  TextEditingController msgtext = TextEditingController();

  _getStreamName() async {
    try {
      var value = await Api().joinLive(context, widget.userId);
      String streamName = value['streamName'];
      if (streamName != null) {
        setState(() {
          streamKey = streamName;
          channelconnect();
        });
        _initController(streamName);
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

  _initController(String streamName) {
    String streamUrl = api.serverUrl + ':8000/live/$streamName/index.m3u8';
    print("Stream url: $streamUrl");
    context.showSuccessBar(content: Text("Stream url: $streamUrl"));
    _videoPlayerController1 = VideoPlayerController.network(streamUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      isLive: true,
      autoInitialize: true,
    );

    setState(() {});
  }

  @override
  void initState() {
    _getStreamName();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      if (streamKey != "") {
        var respone = await Api().countLive(context, streamKey);
        if (respone != null) {
          setState(() {
            liveCount = respone;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Watch Live Stream: " + liveCount.toString()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              channelconnect();
            },
          )
        ],
      ),
      body: Stack(children: [
        Expanded(
          child: Chewie(
            controller: _chewieController,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            msglist.isNotEmpty
                ? SizedBox(height: MediaQuery.of(context).size.height * 0.5)
                : SizedBox(height: 0),

            msglist.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                    itemCount: msglist.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(msglist[index].picturePath ?? ""),
                        ),
                        title: Text(msglist[index].msgtext),
                        subtitle: Text(msglist[index].username),
                      );
                    },
                  ))
                : Container(),

            // SizedBox(height: 20),
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgtext,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Message",
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  RaisedButton(
                    child: Text("Send"),
                    onPressed: () {
                      sendmsg(msgtext.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://localhost:6060"); //channel IP : Port

      channel.stream.listen(
        (message) {
          print("Message: $message");
          setState(() {
            if (message == "connected") {
              connected = true;
              print("Connection establised.");
              _joinChannel();
            } else if (message == "joined") {
              joined = true;
              print("Joined the channel.");
              setState(() {});
            } else {
              message = jsonDecode(message);
              var userid = message["userid"];
              if (userid == api.myId) {
              } else {
                MessageData newmsg = MessageData(message['msg'],
                    message['userid'], false, message['username'],
                    picturePath: message['picturePath']);
                msglist.add(newmsg);
                setState(() {});
              }
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
            joined = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (e) {
      print("error on connecting to websocket.");
      print(e);
    }
  }

  _joinChannel() {
    var newMessage = {"join": streamKey};
    String jsonString = json.encode(newMessage);
    channel.sink.add(jsonString);
    setState(() {});
  }

  Future<void> sendmsg(String sendmsg) async {
    if (connected == true && joined == true) {
      String msg =
          jsonEncode({"msg": sendmsg, "room": streamKey, "token": api.token});
      setState(() {
        msgtext.text = "";
        msglist.add(MessageData(sendmsg, api.myId, true, api.myUsername,
            picturePath: api.myPicturePath));
      });
      channel.sink.add(msg); //send message to reciever channel
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }
}

class MessageData {
  //message data model
  String msgtext;
  int userid;
  bool isme;
  String? picturePath;
  String username;
  MessageData(this.msgtext, this.userid, this.isme, this.username,
      {this.picturePath});
}
