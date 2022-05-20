// import 'package:better_player/better_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  final bool looping;
  final bool autoplay;
  final int currentIndex;
  final String currUrl;
  final String thumbnailUrl;

  const VideoItems({
    required this.looping,
    required this.autoplay,
    required this.currentIndex,
    required this.currUrl,
    required this.thumbnailUrl,
    required Key key,
  }) : super(key: key);

  @override
  VideoItemsState createState() => VideoItemsState();
}

class VideoItemsState extends State<VideoItems> {
  late ChewieController _chewieController;
  // late BetterPlayerController _betterPlayerController;

  void playVideo() {
    setState(() {
      // videoPlayerController.play();
      _chewieController.play();
    });
  }

  int getCurrentDuration() {
    return _chewieController.videoPlayerController.value.position.inSeconds;
  }

  void pauseVideo() {
    setState(() {
      _chewieController.pause();
    });
  }

  void stopVideo() {
    setState(() {
      _chewieController.pause();
      _chewieController.seekTo(const Duration(seconds: 0));
    });
  }

  bool videoHasError = false;

  bool alreadyStartedZeroIndex = false;

  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    String currUrl = widget.currUrl + ".mp4";
    String token = Api().getToken();
    Map<String, String> headers = {
      "Authorization": token,
      "Content-Type": "application/json",
    };

    videoPlayerController =
        VideoPlayerController.network(currUrl, httpHeaders: headers);

    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      allowFullScreen: false,
      showControls: false,
      aspectRatio: 0.55,
      autoInitialize: true,
      autoPlay: widget.autoplay,
      looping: widget.looping,
      errorBuilder: (context, errorMessage) {
        print("ERROR BUILDER");
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    // videoPlayerController.addListener(() {
    //   //Check for errors
    //   if (videoPlayerController.value.hasError) {
    //     print("ERROR");
    //     print(videoPlayerController.value.errorDescription);
    //     setState(() {
    //       videoHasError = true;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        child: ColoredBox(
            color: Colors.black,
            child: videoHasError
                ? const Center(
                    child: Text(
                        "Make sure you are connected to the \ninternet and have permission to access the video"),
                  )
                // : AspectRatio(
                //     aspectRatio: videoPlayerController.value.aspectRatio,
                //     child: Chewie(
                //       controller: _chewieController,
                //     ))));
                : Chewie(
                    controller: _chewieController,
                  )));
    // : AspectRatio(
    //     aspectRatio: videoPlayerController.value.aspectRatio,
    //     child: VideoPlayer(videoPlayerController),
    //   )));
    // : AspectRatio(
    //     aspectRatio: 5 / 8,
    //     child: BetterPlayer(controller: _betterPlayerController)));
  }
}
