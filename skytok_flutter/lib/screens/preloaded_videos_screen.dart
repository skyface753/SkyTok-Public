import 'package:flutter/material.dart';
import 'package:skytok_flutter/components/video_pageview.dart';
import 'package:skytok_flutter/models/video.dart';

class PreLoadedVideosScreen extends StatefulWidget {
  List<Video> videos;
  int startIndex;

  PreLoadedVideosScreen(
      {required this.videos, required this.startIndex, Key? key})
      : super(key: key);
  @override
  _PreLoadedVideosScreenState createState() => _PreLoadedVideosScreenState();
}

class _PreLoadedVideosScreenState extends State<PreLoadedVideosScreen> {
  @override
  void dispose() {
    _key.currentState?.pauseCurrentVideo();
    _key.currentState?.stopAllVideos();
    // widget.videos.clear();
    print('dispose');
    super.dispose();
  }

  GlobalKey<VideoPageViewState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    _key = GlobalKey();
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Pre-loaded Videos'),
        // ),
        body: Stack(children: [
      Column(
        children: [
          Expanded(
              child: VideoPageView(
            videos: widget.videos,
            startAtIndex: widget.startIndex,
            key: _key,
          )),
          Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Colors.blueAccent)
        ],
      ),
      SafeArea(
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
              color: Colors.white)),
    ]));
  }
}
