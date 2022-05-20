import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:video_player/video_player.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:async/async.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class UploadScreen extends StatefulWidget {
  final String filePath;

  const UploadScreen({Key? key, required this.filePath}) : super(key: key);
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class VideoType {
  int id;
  String name;

  VideoType(this.id, this.name);

  static List<VideoType> getVideoTypes() {
    return <VideoType>[
      VideoType(0, 'Public'),
      VideoType(1, 'Followers'),
      VideoType(2, 'Private'),
    ];
  }
}

class _UploadScreenState extends State<UploadScreen> {
  VideoPlayerController? videoController;
  XFile? videoFile;
  final TextEditingController _descriptionController = TextEditingController();

  List<VideoType> _videoTypes = VideoType.getVideoTypes();
  late VideoType _selectedVideoType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            fillColor: Colors.blue,
                            hintText: 'Enter a description',
                          ),
                        ),
                      ),
                      _thumbnailWidget(),
                    ],
                  ),
                ),
                Expanded(
                    child: IconButton(
                        onPressed: () {
                          if (_descriptionController.text.isEmpty) {
                            return;
                          }
                          uploadFile(File(videoFile!.path));
                        },
                        icon: const Icon(Icons.upload_file))),
                // Dropdown with 3 items
                DropdownButton<VideoType>(
                  value: _selectedVideoType,
                  items: _videoTypes.map((VideoType videoType) {
                    return DropdownMenuItem<VideoType>(
                      value: videoType,
                      child: Text(videoType.name),
                    );
                  }).toList(),
                  onChanged: (VideoType? newValue) {
                    setState(() {
                      _selectedVideoType = newValue!;
                    });
                  },
                ),
              ],
            )));
  }

  @override
  void initState() {
    _selectedVideoType = _videoTypes[0];
    super.initState();

    videoFile = XFile(widget.filePath);
    if (kIsWeb) {
      videoController = VideoPlayerController.network(videoFile!.path);
    } else {
      videoController = VideoPlayerController.file(File(videoFile!.path));
    }

    videoController!.initialize().then((_) {
      setState(() {
        videoController!.setLooping(true);
        videoController!.play();
      });
    });
  }

  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return localVideoController == null
        ? const Text('Loading...')
        : InkWell(
            onTap: () {
              print("Tapped");
              setState(() {
                if (videoController!.value.isPlaying) {
                  print('pausing');
                  videoController!.pause();
                } else {
                  print('playing');
                  videoController!.play();
                }
              });
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height,
              child: AspectRatio(
                aspectRatio: localVideoController.value.aspectRatio,
                child: VideoPlayer(localVideoController),
              ),
            ));
  }

  uploadFile(File fileForUpload) async {
    var stream =
        // ignore: deprecated_member_use
        http.ByteStream(DelegatingStream.typed(fileForUpload.openRead()));
    var length = await fileForUpload.length();
    var uri = Uri.parse(api.serverUrl + "/videos/upload");
    var request = http.MultipartRequest("POST", uri);
    var fileNameforRequest = "";

    fileNameforRequest = path.basename(fileForUpload.path);

    var multipartFile = http.MultipartFile('uploadVideoFile', stream, length,
        filename: fileNameforRequest);
    request.files.add(multipartFile);

    request.headers['Authorization'] = api.token;
    request.headers['Content-Type'] = 'video/mp4';
    request.fields['descryption'] = _descriptionController.text;
    request.fields['isPrivate'] = _selectedVideoType.id.toString();
    print("Type: " + _selectedVideoType.id.toString());
    var response = await request.send();
    videoController!.dispose();
    response.stream.transform(utf8.decoder).listen((value) {
      if (value == "Uploaded") {
        Navigator.pop(context);
      }
    });
  }
}
