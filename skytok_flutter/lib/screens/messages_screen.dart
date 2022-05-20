import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skytok_flutter/models/chat.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/screens/preloaded_videos_screen.dart';
import 'package:skytok_flutter/screens/profile.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skytok_flutter/components/audio_seekbar.dart';
import 'package:audio_session/audio_session.dart';
import 'package:giphy_get/giphy_get.dart';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class MessagesScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String? picturePath;
  const MessagesScreen(
      {required this.otherUserId,
      required this.otherUserName,
      required this.picturePath,
      Key? key})
      : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

//other_user_id
class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  List<ChatMessage> _messages = <ChatMessage>[];

  List<Video> videos = [];
  FocusNode _focusNode = FocusNode();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _getMessages();
    // Get messages every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _getMessages();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  List<ChatMessage> _tempMessages = [];

  bool _isOnline = true;

  _getMessages() async {
    // Shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Get messages from prefs
      prefs
                  .getString('messages-' + widget.otherUserId.toString())
                  ?.isNotEmpty ??
              false
          ? setState(
              () {
                // print("Get Messages from prefs");
                String jsonString = prefs
                    .getString('messages-' + widget.otherUserId.toString())!;
                // print(jsonString);
                Iterable list = json.decode(jsonString);
                _tempMessages =
                    list.map((model) => ChatMessage.fromJson(model)).toList();
                if (_tempMessages != _messages) {
                  _messages = _tempMessages;
                }
              },
            )
          : null;
    } catch (e) {
      print(e);
    }
    // print("getting messages");
    Iterable list =
        await api.getMessages(context, widget.otherUserId).then((value) {
      // print("Got messages");
      _isOnline = true;
      return value;
    }, onError: (error) {
      // print("error getting messages");
      _isOnline = false;
    });
    // } _isOnline = true);
    _tempMessages.clear();

    _tempMessages = list.map((model) => ChatMessage.fromJson(model)).toList();
    if (_tempMessages != _messages) {
      videos.clear();
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].video != null) {
          videos.add(_messages[i].video!);
        }
      }
      setState(() {
        _messages = _tempMessages;
        prefs.setString('messages-' + widget.otherUserId.toString(),
            json.encode(_messages));
      });
    }

    // setState(() {
    //   _focusNode.requestFocus();
    // });
  }

  //Start recording
  final record = Record();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            //TODO Show fullscreen on Picture and Profile on Username
            Row(
          children: <Widget>[
            widget.picturePath != null
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(api.serverUrl + "/" + widget.picturePath!),
                    radius: 20,
                  )
                : const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/avatar.png"),
                    radius: 20,
                  ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      username: widget.otherUserName,
                    ),
                  ),
                );
              },
              child: Text('@${widget.otherUserName}',
                  style: TextStyle(color: Colors.blue)),
            )
            // Text(widget.otherUserName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getMessages();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) {
                    return _buildMessage(_messages[index]);
                  },
                  itemCount: _messages.length,
                ),
              ),
              const Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: SafeArea(
                  child: _buildTextComposer(),
                ),
              ),
            ],
          ),
          !_isOnline
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Text(
                          "You are offline",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  bool isRecording = false;
  DateTime startTimeRecording = DateTime.now();

  _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: 50.0,
        child: Row(
          children: <Widget>[
            isRecording
                ? Expanded(
                    child: Text(
                      "Recording... ${(DateTime.now().difference(startTimeRecording).inSeconds).toString()}s",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Flexible(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      onSubmitted: _handleSubmitted,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Send a message"),
                    ),
                  ),
            _textController.text.isEmpty
                ? GestureDetector(
                    onLongPressStart: (details) async {
                      if (kIsWeb) {
                        return;
                      }

                      // Check and request permission
                      bool result = await record.hasPermission();
                      if (result) {
                        print("Permission granted");
                      } else {
                        print("Permission denied");
                        context.showErrorBar(
                            content: Text("Permission denied"));
                        return;
                      }

                      Directory tempDir = await path.getTemporaryDirectory();
                      String tempPath = tempDir.path;
                      // Start recording
                      await record.start(
                        path: '$tempPath/voiceRecord.m4a',
                      );

                      setState(() {
                        isRecording = true;
                        startTimeRecording = DateTime.now();
                      });
                    },
                    onLongPressEnd: (details) async {
                      await record.stop();
                      Directory tempDir = await path.getTemporaryDirectory();
                      String tempPath = tempDir.path;
                      File file = File('$tempPath/voiceRecord.m4a');
                      await _sendAudio(file, widget.otherUserId);
                      setState(() {
                        isRecording = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.mic,
                          color: isRecording ? Colors.red : null),
                    ),
                  )
                : Container(),
            IconButton(
              onPressed: () async {
                GiphyGif? gif = await GiphyGet.getGif(
                  context: context, //Required
                  apiKey: "YvSdvWtjJ4UtavAxyFmXhy0MzScKT1f7", //Required.
                  lang: GiphyLanguage.english, //Optional - Language for query.
                  randomID:
                      "abcd", // Optional - An ID/proxy for a specific user.
                  tabColor: Colors.teal, // Optional- default accent color.
                );
              },
              icon: Icon(Icons.gif),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmitted(String messages) async {
    _textController.clear();
    await api.sendMessage(context, widget.otherUserId, messages, null);
    _focusNode.requestFocus();
    _getMessages();
  }

  final List<GlobalKey<AudioMessageState>> _audioKeys = [];
  int currentAudioKeyIndex = 0;
  _buildMessage(ChatMessage message) {
    bool isCurrentUser = message.fromUserID == api.myId;
    final String? myAvatarUrl = api.myPicturePath == null
        ? null
        : api.serverUrl + "/" + api.myPicturePath!;
    final String? otherAvatarUrl = widget.picturePath == null
        ? null
        : api.serverUrl + "/" + widget.picturePath!;
    // if (message.video == null && message.recordPath != null) {
    //   print("Add key");
    //   _audioKeys.add(GlobalKey<AudioMessageState>());
    //   currentAudioKeyIndex++;
    // }
    return Padding(
      // asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 0,
        4,
        isCurrentUser ? 0 : 64.0,
        4,
      ),
      child: Align(
        // align the child within the container
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isCurrentUser
                ? Container()
                : otherAvatarUrl != null
                    ? CircleAvatar(
                        maxRadius: 15,
                        backgroundImage: NetworkImage(otherAvatarUrl),
                      )
                    : const CircleAvatar(
                        maxRadius: 15,
                        backgroundImage: AssetImage("assets/images/avatar.png"),
                      ),
            isCurrentUser ? Container() : const SizedBox(width: 8),
            Flexible(
              child: DecoratedBox(
                // chat bubble decoration
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: message.video != null
                    ? _buildImage(message)
                    : message.recordPath != null
                        ? AudioMessage(
                            api.serverUrl + "/" + message.recordPath!,
                            isCurrentUser,
                            key: Key(
                              message.id.toString(),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              message.message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black87),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _pauseAllAudios() {
    for (int i = 0; i < _audioKeys.length; i++) {
      _audioKeys[i].currentState!.stopAudio();
    }
  }

  _buildImage(ChatMessage message) {
    // videos.add(message.video!);
    return InkWell(
        onTap: () {
          videos.clear();
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].video != null) {
              videos.add(_messages[i].video!);
            }
          }
          // print("To preloaded videos");
          // inspect(videos);
          // inspect(_messages);
          Navigator.push(
            context,
            MaterialPageRoute(
              //TODO One Video always doubles
              builder: (context) => PreLoadedVideosScreen(
                  videos: videos, startIndex: videos.indexOf(message.video!)),
            ),
          ).then((value) => _getMessages());
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child:
              Image.network(api.serverUrl + "/" + message.video!.thumbnailPath,
                  errorBuilder: (context, error, stackTrace) {
            print("Error: $error");
            print("StackTrace: $stackTrace");
            return Image.asset("assets/images/avatar.png");
          }, fit: BoxFit.fill, headers: {'Authorization': api.token}),
        ));
  }

  _sendAudio(File fileForUpload, int receiver_id) async {
    var stream =
        // ignore: deprecated_member_use
        http.ByteStream(DelegatingStream.typed(fileForUpload.openRead()));
    var length = await fileForUpload.length();
    var uri = Uri.parse(api.serverUrl + "/messages/upload/record");
    var request = http.MultipartRequest("POST", uri);
    var fileNameforRequest = "";

    fileNameforRequest = path.basename(fileForUpload.path);

    var multipartFile = http.MultipartFile('uploadRecord', stream, length,
        filename: fileNameforRequest);
    request.files.add(multipartFile);

    request.headers['Authorization'] = api.token;
    request.headers['Content-Type'] = 'video/mp4';
    request.fields['receiver_id'] = receiver_id.toString();
    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      if (value == "Uploaded") {
        _getMessages();
      }
    });
  }
}

class AudioMessage extends StatefulWidget {
  final String url;
  final bool isCurrentUser;

  const AudioMessage(this.url, this.isCurrentUser, {Key? key})
      : super(key: key);

  @override
  AudioMessageState createState() => AudioMessageState();
}

class AudioMessageState extends State<AudioMessage>
    with WidgetsBindingObserver {
  bool isPlaying = false;

  final player = AudioPlayer();

  void stopAudio() {
    player.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initPlayer();
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        player.seek(Duration(seconds: 0));
        player.stop();
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  initPlayer() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
    player.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream, (position, bufferedPosition, duration) {
        //TODO Fix this
        print("Stream position: ${player.position}");
        return PositionData(
            position, bufferedPosition, duration ?? Duration.zero);
      });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: isPlaying
                  ? Icon(Icons.stop)
                  : Icon(Icons.play_circle_outline),
              onPressed: () async {
                if (isPlaying) {
                  stopAudio();
                } else {
                  isPlaying = true;
                  String currUrl = widget.url;
                  await player.setUrl(currUrl, headers: {
                    "Authorization": api.token,
                  });
                  // try {
                  //   await player.setAudioSource(AudioSource.uri(
                  //       Uri.parse(currUrl),
                  //       headers: {'Authorization': api.token}));
                  // } catch (e) {
                  //   print("Error loading audio source: $e");
                  // }
                  player.play();
                }
                setState(() {});
              },
            ),
            Expanded(
              child: StreamBuilder<PositionData>(
                key: widget.key!,
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  // print("Position data in Builder: $positionData");
                  //TODO Fix PositionData

                  return SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                        positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: player.seek,
                  );
                },
              ),
            ),
            // Expanded(
            //   child: Slider(
            //     thumbColor:
            //         widget.isCurrentUser ? Colors.white : Colors.black87,
            //     activeColor:
            //         widget.isCurrentUser ? Colors.white : Colors.black87,
            //     inactiveColor:
            //         widget.isCurrentUser ? Colors.black87 : Colors.white,
            //     value: (positionData?.position ?? Duration.zero)
            //         .inMilliseconds
            //         .toDouble(),
            //     max: (positionData?.duration ?? Duration.zero)
            //         .inMilliseconds
            //         .toDouble(),
            //     onChanged: (value) {
            //       player.seek(Duration(milliseconds: value.toInt()));
            //     },
            //   ),
            // ),
            // Text((positionData?.position ?? Duration.zero)
            //         .inSeconds
            //         .toString() +
            //     "s / " +
            //     (positionData?.duration ?? Duration.zero)
            //         .inSeconds
            //         .toString() +
            //     "s"),
          ],
        ));
  }
}

typedef AudioCallback = void Function();

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
