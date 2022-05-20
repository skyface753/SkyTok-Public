import 'dart:developer';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/components/video_comments.dart';
import 'package:skytok_flutter/components/video_items.dart';
import 'package:skytok_flutter/models/comment.dart';
import 'package:skytok_flutter/models/user.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/routes.dart';
import 'package:skytok_flutter/screens/explore.dart';
import 'package:skytok_flutter/screens/chats_screen.dart';
import 'package:skytok_flutter/screens/profile.dart';
import 'package:skytok_flutter/screens/tag_screen.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:skytok_flutter/services/number_formatter.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';
import 'package:flash/flash.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;

class VideoPageView extends StatefulWidget {
  final List<Video>? videos;
  final int? startAtIndex;
  const VideoPageView({this.videos, this.startAtIndex, Key? key})
      : super(key: key);

  @override
  VideoPageViewState createState() => VideoPageViewState();
}

class VideoPageViewState extends State<VideoPageView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool play = true;

  late AnimationController animationController;
  late PageController pageController;

  int currentIndex = 0;

  bool loadingNextVideos = false;

  bool isLoadingInitialVideos = true;

  bool isPreloadedVideos = false;

  List<Video> videos = [];
  List<Video> tempVideos = [];

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    if (widget.videos != null && widget.startAtIndex != null) {
      videos = widget.videos!;
      pageController = PageController(
        initialPage: widget.startAtIndex!,
        // viewportFraction: 0.8,
      );
      currentIndex = widget.startAtIndex!;
      // pageController.jumpToPage(widget.startAtIndex!);
      isPreloadedVideos = true;
      setState(() {
        isLoadingInitialVideos = false;
      });
    } else {
      pageController = PageController(
          // viewportFraction: 0.8,
          );
      _getDataFromAPI().then((value) {});
    }
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    animationController.repeat();
  }

  void pauseCurrentVideo() {
    if (videos.isNotEmpty) {
      keys[currentIndex].currentState!.pauseVideo();
      setState(() {
        play = false;
      });
    }
  }

  void stopAllVideos() {
    for (int i = 0; i < keys.length; i++) {
      keys[i].currentState!.stopVideo();
    }
  }

  Future _getDataFromAPI() async {
    Iterable list = await Api().getUserVideos(context);
    tempVideos = list.map((model) => Video.fromJson(model)).toList();
    videos.addAll(tempVideos);
    setState(() {
      isLoadingInitialVideos = false;
    });
    return;
  }

  @override
  void dispose() {
    animationController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoPage();
  }

  _pageChangedNew(int index) {
    setState(() {
      play = true;
    });
    if (index >= videos.length - 3) {
      if (!isPreloadedVideos) {
        print("Loading next videos");
        _getDataFromAPI();
      }
    }
    try {
      keys[currentIndex].currentState!.stopVideo();
      keys[index].currentState!.playVideo();
    } catch (e) {
      print("Error in page change");
    }
    currentIndex = index;
  }

  _playOrPause() {
    if (play) {
      if (kDebugMode) {
        print("Pause video");
      }
      keys[currentIndex].currentState?.pauseVideo();
      play = !play;
    } else {
      if (kDebugMode) {
        print("Play video");
      }
      // inspect(keys);
      // print(currentIndex);
      keys[currentIndex].currentState?.playVideo();
      // print(api.serverUrl + "/" + videos[currentIndex].path!);
      play = !play;
    }
    setState(() {});
  }

  // void pauseVideo() {
  //   if (kDebugMode) {
  //     print("Pause video");
  //   }
  //   keys[currentIndex].currentState!.pauseVideo();
  //   play = false;
  //   setState(() {});
  // }

  bool showVideoOverlay = true;

  List<GlobalKey<VideoItemsState>> keys = [];

  videoPage() {
    for (int i = 0; i < videos.length; i++) {
      keys.add(GlobalKey<VideoItemsState>());
    }
    return Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              _pageChangedNew(index);
            },
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              String currUrl =
                  api.serverUrl + "/videos/" + videos[index].id.toString();
              // keys.add(GlobalKey());
              VideoItems currVideoItem = VideoItems(
                autoplay: widget.videos != null &&
                        widget.startAtIndex != 0 &&
                        index == widget.startAtIndex
                    ? true
                    : index == 0
                        ? true
                        : false,
                looping: true,
                currUrl: currUrl,
                thumbnailUrl: api.serverUrl + "/" + videos[index].thumbnailPath,
                key: keys[index],
                currentIndex: index,
              );
              return Stack(
                children: <Widget>[
                  isLoadingInitialVideos
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onLongPressStart: (details) {
                            showVideoOverlay = false;
                            setState(() {});
                          },
                          onLongPressEnd: (details) {
                            showVideoOverlay = true;
                            setState(() {});
                          },
                          onTap: () {
                            _playOrPause();
                          },
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: currVideoItem)),
                  !play
                      ? Center(
                          child: InkWell(
                              onTap: () {
                                _playOrPause();
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: const Icon(
                                    Icons.pause,
                                    size: 30,
                                  ))))
                      : Container(),
                  // Username, Description and Sound
                  showVideoOverlay
                      ? Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 10),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 100,
                              // height: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, bottom: 10),
                                      child: Row(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                _gotoProfile(
                                                    videos[index].username);
                                              },
                                              child: Text(
                                                "@" + videos[index].username,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )),
                                          videos[index].privacyId == 1
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Row(children: [
                                                    Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "Just follower",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ]))
                                              : videos[index].privacyId == 2
                                                  ? //private
                                                  Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(children: [
                                                        Icon(
                                                          Icons.lock,
                                                          color: Colors.white,
                                                        ),
                                                        Text(
                                                          "Private",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ]))
                                                  : Container(),
                                        ],
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, bottom: 5),
                                      child: DetectableText(
                                        text: videos[index].descryption,
                                        detectionRegExp:
                                            detectionRegExp(url: false)!,
                                        detectedStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                        ),
                                        basicStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        onTap: (tappedText) {
                                          pauseCurrentVideo();
                                          if (tappedText.startsWith('#')) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TagScreen(
                                                          tagName: tappedText
                                                              .substring(
                                                                  1,
                                                                  tappedText
                                                                      .length),
                                                        )));
                                          } else {
                                            _gotoProfile(tappedText.substring(
                                                1, tappedText.length));
                                          }
                                        },
                                      )),
                                  Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: const <Widget>[
                                        Icon(Icons.music_note,
                                            size: 16, color: Colors.white),
                                        Text('R10 - Oboy',
                                            style:
                                                TextStyle(color: Colors.white))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  // Profile, Likes, Comments, Share and Sound
                  showVideoOverlay
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 20, right: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                              width: 70,
                              height: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 23),
                                    width: 40,
                                    height: 50,
                                    child: Stack(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            pauseCurrentVideo();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileScreen(
                                                        username: videos[index]
                                                            .username,
                                                      )),
                                            );
                                          },
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius: 19,
                                              backgroundColor: Colors.black,
                                              backgroundImage: videos[index]
                                                          .userPicturePath !=
                                                      null
                                                  ? NetworkImage(api.serverUrl +
                                                      "/" +
                                                      videos[index]
                                                          .userPicturePath!)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        videos[index].userFollowing ||
                                                (api.myId ==
                                                    videos[index].user_id)
                                            ? Container()
                                            : Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor:
                                                      const Color(0x00fd2c58)
                                                          .withOpacity(1),
                                                  child: Center(
                                                    child: InkWell(
                                                        onTap: () async {
                                                          await Api()
                                                              .followUser(
                                                                  context,
                                                                  videos[index]
                                                                      .user_id);
                                                          setState(() {
                                                            videos[index]
                                                                    .userFollowing =
                                                                true;
                                                          });
                                                        },
                                                        child: Icon(Icons.add,
                                                            size: 15,
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: InkWell(
                                      onTap: () {
                                        if (videos[index].userLikedTheVideo) {
                                          api.unlikeVideo(
                                              context, videos[index].id);
                                          videos[index].userLikedTheVideo =
                                              false;
                                          videos[index].likeCount--;
                                        } else {
                                          api.likeVideo(
                                              context,
                                              videos[index].id,
                                              videos[index].type);
                                          videos[index].userLikedTheVideo =
                                              true;
                                          videos[index].likeCount++;
                                        }
                                        setState(() {});
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.favorite,
                                              size: 35,
                                              color: videos[index]
                                                      .userLikedTheVideo
                                                  ? Colors.red
                                                  : Colors.white),
                                          Text(
                                              NumberFormatter.format(
                                                  videos[index].likeCount),
                                              style: const TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: InkWell(
                                        onTap: () {
                                          _showComments(videos[index].id,
                                              videos[index].type);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Transform(
                                                alignment: Alignment.center,
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                child: const Icon(Icons.sms,
                                                    size: 35,
                                                    color: Colors.white)),
                                            Text(
                                                NumberFormatter.format(
                                                    videos[index].commentCount),
                                                style: const TextStyle(
                                                    color: Colors.white))
                                          ],
                                        ),
                                      )),
                                  InkWell(
                                      hoverColor: Colors.blue,
                                      onTap: () {
                                        pauseCurrentVideo();
                                        api.shareVideo(
                                            context,
                                            videos[index].id,
                                            videos[index].type);
                                        _showSharing(videos[index].id);
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 30),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Transform(
                                                alignment: Alignment.center,
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                child: const Icon(Icons.reply,
                                                    size: 35,
                                                    color: Colors.white)),
                                            Text(
                                                NumberFormatter.format(
                                                    videos[index].shares),
                                                style: const TextStyle(
                                                    color: Colors.white))
                                          ],
                                        ),
                                      )),
                                  AnimatedBuilder(
                                    animation: animationController,
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: const Color(0x00222222)
                                          .withOpacity(1),
                                      child: const CircleAvatar(
                                        radius: 12,
                                        // backgroundImage:
                                        //     AssetImage('assets/oboy.jpg'),
                                      ),
                                    ),
                                    builder: (context, _widget) {
                                      return Transform.rotate(
                                          angle:
                                              animationController.value * 6.3,
                                          child: _widget);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ))
                      : Container(),
                ],
              );
            }));
  }

  _gotoProfile(String username) {
    pauseCurrentVideo();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileScreen(
                username: username,
              )),
    );
  }

  _showComments(int currVideoID, int suggestionType) async {
    await _loadComments(currVideoID);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return VideoComments(comments, currVideoID, context, suggestionType,
              (() => _loadComments(currVideoID)));
        });
  }

  List<Comment> comments = [];

  Future<void> _loadComments(int currVideoID) async {
    var value = await Api().getCommentsForVideo(context, currVideoID);
    Iterable list = value;
    comments = list.map((model) => Comment.fromJson(model)).toList();
    // inspect(comments);
  }

  List<User> following = [];

  _showSharing(int videoID) async {
    await _loadFollowing();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: following.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 19,
                              backgroundColor: Colors.black,
                              backgroundImage:
                                  following[index].picturePath != null
                                      ? NetworkImage(api.serverUrl +
                                          "/" +
                                          following[index].picturePath!)
                                      : null,
                            ),
                          ),
                          title: Text(following[index].username),
                          onTap: () async {
                            await api.sendMessage(
                                context, following[index].id, "", videoID);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Share.share('Check out this video on SkyTok!\n' +
                            videoID.toString());
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ));
        });
  }

  _loadFollowing() async {
    Iterable list = await api.getMyFollowing(context);
    following = list.map((model) => User.fromJson(model)).toList();
  }
}
