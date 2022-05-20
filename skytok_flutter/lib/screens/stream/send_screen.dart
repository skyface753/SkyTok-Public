import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:video_stream/camera.dart';

import 'package:skytok_flutter/services/api_requests.dart' as api;

class SendLiveStreamScreen extends StatefulWidget {
  @override
  _SendLiveStreamScreenState createState() => _SendLiveStreamScreenState();
}

class _SendLiveStreamScreenState extends State<SendLiveStreamScreen> {
  late List<CameraDescription> cameras;

  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() async {
    await _stopStream();
    super.dispose();
  }

  _stopStream() async {
    try {
      await Api().stopLive(context);
      await controller.stopVideoStreaming();
      await controller.dispose();
    } catch (e) {
      print("Error in stop stream: $e");
    }
  }

  initCamera() async {
    cameras = await availableCameras();
    selectCamera();
  }

  late CameraController controller;

  selectCamera() async {
    //TODO Change
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      _getStreamUrl();
    });
  }

  _nextCamera() async {
    if (!controller.value.isInitialized) {
      return;
    }
    int index = cameras.indexOf(controller.description!);
    if (index < cameras.length - 1) {
      controller = CameraController(cameras[index + 1], ResolutionPreset.max);
    } else {
      controller = CameraController(cameras[0], ResolutionPreset.max);
    }
    await controller.initialize();
    setState(() {});
  }

  _getStreamUrl() async {
    var streamStart = await Api().startLive(context);
    var isLive = streamStart['isLive'];
    var streamName = streamStart['streamName'];
    var streamUrl = "rtmp://" + api.iporhost + "/live/" + streamName;
    if (isLive) {
      _showUrlDialog(streamUrl);
      setState(() {
        isStarted = true;
      });
    } else {
      context.showErrorBar(content: Text("Error starting stream"));
    }
  }

  void _showUrlDialog(String url, {bool persistent = true}) {
    context.showFlashDialog(
        constraints: BoxConstraints(maxWidth: 300),
        persistent: persistent,
        title: Text('Start Stream from here?'),
        content: Text(
            'You can also start streaming to the following url (eg. with OBS): \n\n' +
                url),
        negativeActionBuilder: (context, controller, _) {
          return TextButton(
            onPressed: () {
              controller.dismiss();
            },
            child: Text('NO'),
          );
        },
        positiveActionBuilder: (context, controller, _) {
          return TextButton(
              onPressed: () {
                _startStreamHere(url);
                controller.dismiss();
              },
              child: Text('YES'));
        });
  }

  _startStreamHere(String streamUrl) async {
    try {
      await controller.startVideoStreaming(streamUrl, androidUseOpenGL: true);
      context.showSuccessBar(
          content: Text("Start live stream to " + streamUrl));
      setState(() {});
    } catch (e) {
      context.showErrorBar(
          content: Text("Failed to start live stream to " + streamUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          child: Padding(
              padding: EdgeInsets.all(1),
              child: controller.value.isInitialized
                  ? CameraPreview(controller)
                  : Center(child: Text("Please wait")))),
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: FloatingActionButton(
            onPressed: () {
              _nextCamera();
            },
            child: Icon(Icons.switch_camera),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: FloatingActionButton(
            onPressed: () {
              if (isStarted) {
                _stopStream();
              } else {
                _getStreamUrl();
              }
            },
            child: isStarted ? Icon(Icons.stop) : Icon(Icons.play_arrow),
          ),
        ),
      ),
    ]);
  }
}
