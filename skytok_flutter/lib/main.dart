import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/components/video_comments.dart';
import 'package:skytok_flutter/components/video_pageview.dart';
import 'package:skytok_flutter/models/comment.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/routes.dart';
import 'package:skytok_flutter/screens/explore.dart';
import 'package:skytok_flutter/screens/login_register.dart';
import 'package:skytok_flutter/screens/notifications_view.dart';
import 'package:skytok_flutter/screens/profile.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:skytok_flutter/services/read_write_data.dart';

void main() async {
  //Ensure initializing the shared preferences
  WidgetsFlutterBinding.ensureInitialized();
  if (await ReadWriteData().readData()) {
    runApp(MyApp());
  } else {
    runApp(Login());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: routes,
      // Set default Dark Theme
      theme: ThemeData.dark(),
      home: const Main(),
    );
  }
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: routes,
      // Set default Dark Theme
      theme: ThemeData.dark(),
      home: const LoginRegisterScreen(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  GlobalKey<HomeState> homeKey = GlobalKey();

  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int duration = 0;
  late DateTime startPause;
  late DateTime endPause;
  int pauseDuration = 0;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    _sendDurationToApi();
  }

  _sendDurationToApi() async {
    endTime = DateTime.now();
    duration = endTime.difference(startTime).inSeconds;
    print(
        'Time while App was open: ${duration} seconds. (Start: ${startTime}, End: ${endTime})');
    await Api()
        .sendAppDuration(startTime, endTime, duration, pauseDuration, context)
        .timeout(Duration(seconds: 3));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('App is paused');
      startPause = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      endPause = DateTime.now();
      pauseDuration = endPause.difference(startPause).inSeconds;
      print('Pause duration: $pauseDuration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Center(
          child: Column(children: [
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              Home(key: homeKey),
              const ExploreView(),
              const NotificationsView(),
              const ProfileScreen(),
            ],
          ),
        ),
        Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: SafeArea(
                top: false,
                // child: SizedBox(
                //     height: 65, width: double.infinity,
                child: footer()))
      ])),
    ]));
  }

  _changeIndex(int index) {
    // print("Selecting index $index from ${_selectedIndex}");
    // if (index == _selectedIndex && index == 0) {
    //   Navigator.pushReplacementNamed(context, "/main");
    // } else {
    //TODO Reactivate this
    homeKey.currentState?.pauseCurrentVideo();
    setState(() {
      _selectedIndex = index;
    });
    // }
  }

  // List of colors for the footer map string
  Color _selectedFooterColor(int index) {
    if (index == _selectedIndex) {
      return Colors.white;
    } else {
      return Colors.grey;
    }
  }

  footer() {
    return Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Divider(color: Colors.white.withOpacity(0.5)),
            Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                        onTap: () => _changeIndex(0),
                        onLongPress: () => _sendDurationToApi(),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 11),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.home,
                                    color: _selectedFooterColor(0), size: 30),
                                const Text('Home',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10))
                              ],
                            ))),
                    InkWell(
                      onTap: () => _changeIndex(1),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 11),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.search,
                                  color: _selectedFooterColor(1), size: 30),
                              Text('Explore',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10))
                            ],
                          )),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 3),
                        child: buttonplus()),
                    InkWell(
                      onTap: () => _changeIndex(2),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.inbox,
                                  color: _selectedFooterColor(2), size: 30),
                              Text('Notifications',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10))
                            ],
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        _changeIndex(3);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(left: 9, right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.person,
                                  color: _selectedFooterColor(3), size: 30),
                              Text('Profile',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10))
                            ],
                          )),
                    )
                  ],
                ))
          ],
        ));
  }

  buttonplus() {
    return InkWell(
        onTap: () {
          homeKey.currentState!.pauseCurrentVideo();
          Navigator.pushNamed(context, "/Recorder");
        },
        child: Container(
          width: 46,
          height: 30,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.transparent),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: const Color(0x002dd3e7).withOpacity(1)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 28,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: const Color(0x00ed316a).withOpacity(1)),
                ),
              ),
              Center(
                child: Container(
                  width: 28,
                  height: 30,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white),
                  child:
                      const Center(child: Icon(Icons.add, color: Colors.black)),
                ),
              )
            ],
          ),
        ));
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool play = kDebugMode ? false : true;

  late AnimationController animationController;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  PageController foryouController = PageController();

  int currentIndex = 0;

  bool loadingNextVideos = false;

  bool isLoadingInitialVideos = true;

  List<Video> videos = [];
  List<Video> tempVideos = [];

  bool abo = false;
  bool foryou = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    // _getDataFromAPI().then((value) {});
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    animationController.repeat();
  }

  void pauseCurrentVideo() {
    pageViewKey.currentState?.pauseCurrentVideo();
  }

  // Future _getDataFromAPI() async {
  //   Iterable list = await Api().getUserVideos(context);
  //   // Iterable list = await api.getUserVideos(context);

  //   tempVideos = list.map((model) => Video.fromJson(model)).toList();
  //   videos.addAll(tempVideos);
  //   inspect(videos);
  //   setState(() {
  //     isLoadingInitialVideos = false;
  //   });
  //   return;
  // }

  @override
  void dispose() {
    animationController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  GlobalKey<VideoPageViewState> pageViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: VideoPageView(
                key: pageViewKey,
              ),
            ),
          ],
        ),
        SafeArea(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () {
                  setState(() {
                    abo = true;
                    foryou = false;
                  });
                },
                child: Text('Abonnements',
                    style: abo
                        ? const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)
                        : const TextStyle(color: Colors.white, fontSize: 16))),
            const Text('|',
                style: TextStyle(color: Colors.white, fontSize: 10)),
            TextButton(
                onPressed: () {
                  setState(() {
                    abo = false;
                    foryou = true;
                  });
                },
                child: Text('For You',
                    style: foryou
                        ? const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)
                        : const TextStyle(color: Colors.white, fontSize: 16))),
          ],
        ))
      ],
    ));
  }

  // _pageChangedNew(int index) {
  //   setState(() {
  //     play = true;
  //   });
  //   if (index >= videos.length - 3) {
  //     print("Loading next videos");
  //     _getDataFromAPI();
  //   }
  //   keys[currentIndex].currentState!.stopVideo();
  //   keys[index].currentState!.playVideo();
  //   currentIndex = index;
  // }

  // _playOrPause() {
  //   if (play) {
  //     if (kDebugMode) {
  //       print("Pause video");
  //     }
  //     keys[currentIndex].currentState!.pauseVideo();
  //     play = !play;
  //   } else {
  //     if (kDebugMode) {
  //       print("Play video");
  //     }
  //     keys[currentIndex].currentState!.playVideo();
  //     play = !play;
  //   }
  //   setState(() {});
  // }

  // List<GlobalKey<VideoItemsState>> keys = [];

  // homescreen() {
  //   return Container(
  //       decoration: const BoxDecoration(color: Colors.black),
  //       child: PageView.builder(
  //           controller: foryouController,
  //           onPageChanged: (index) {
  //             // _pageChanged(index);
  //             // keys[index].currentState!.playVideo();
  //             _pageChangedNew(index);
  //           },
  //           scrollDirection: Axis.vertical,
  //           itemCount: videos.length,
  //           itemBuilder: (context, index) {
  //             String currUrl = api.serverUrl + "/" + videos[index].path!;
  //             keys.add(GlobalKey());
  //             VideoItems currVideoItem = VideoItems(
  //               autoplay: kDebugMode
  //                   ? false
  //                   : index == 0
  //                       ? true
  //                       : false,
  //               looping: true,
  //               currUrl: currUrl,
  //               key: keys[index],
  //               currentIndex: index,
  //             );
  //             return Stack(
  //               children: <Widget>[
  //                 isLoadingInitialVideos
  //                     ? const Center(child: CircularProgressIndicator())
  //                     : InkWell(
  //                         onTap: () {
  //                           _playOrPause();
  //                         },
  //                         child: SizedBox(
  //                             width: MediaQuery.of(context).size.width,
  //                             height: MediaQuery.of(context).size.height,
  //                             child: currVideoItem)),
  //                 !play
  //                     ? Center(
  //                         child: InkWell(
  //                             onTap: () {
  //                               _playOrPause();
  //                             },
  //                             child: Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.grey.withOpacity(0.5),
  //                                 ),
  //                                 child: const Icon(
  //                                   Icons.pause,
  //                                   size: 30,
  //                                 ))))
  //                     : Container(),
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 5),
  //                   child: Align(
  //                     alignment: Alignment.bottomLeft,
  //                     child: SizedBox(
  //                       width: MediaQuery.of(context).size.width - 100,
  //                       height: 100,
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: <Widget>[
  //                           Padding(
  //                             padding:
  //                                 const EdgeInsets.only(left: 5, bottom: 10),
  //                             child: Text(
  //                               "@" + videos[index].username,
  //                               style: const TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                           Padding(
  //                               padding:
  //                                   const EdgeInsets.only(left: 5, bottom: 5),
  //                               child: DetectableText(
  //                                 text: videos[index].descryption,
  //                                 detectionRegExp: detectionRegExp(url: false)!,
  //                                 detectedStyle: const TextStyle(
  //                                   fontSize: 14,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 basicStyle: const TextStyle(
  //                                   fontSize: 14,
  //                                 ),
  //                                 onTap: (tappedText) {
  //                                   pauseCurrentVideo();
  //                                   if (tappedText.startsWith('#')) {
  //                                     //TODO Go to Tag view
  //                                     // Navigator.push(
  //                                     //   context,
  //                                     //   MaterialPageRoute(
  //                                     //       builder: (context) =>
  //                                     //           SearchScreen(
  //                                     //             tappedText: tappedText,
  //                                     //           )),
  //                                     // );
  //                                   } else {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => ProfileScreen(
  //                                                 username: tappedText,
  //                                               )),
  //                                     );
  //                                   }
  //                                 },
  //                               )),
  //                           //  Text.rich(
  //                           //   TextSpan(text: videos[index].descryption),
  //                           //   style: const TextStyle(
  //                           //       color: Colors.white, fontSize: 14),
  //                           // )),
  //                           Container(
  //                             padding: const EdgeInsets.only(left: 10),
  //                             child: Row(
  //                               children: const <Widget>[
  //                                 Icon(Icons.music_note,
  //                                     size: 16, color: Colors.white),
  //                                 Text('R10 - Oboy',
  //                                     style: TextStyle(color: Colors.white))
  //                               ],
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                     padding: const EdgeInsets.only(bottom: 65, right: 10),
  //                     child: Align(
  //                       alignment: Alignment.bottomRight,
  //                       child: SizedBox(
  //                         width: 70,
  //                         height: 400,
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           children: <Widget>[
  //                             Container(
  //                               margin: const EdgeInsets.only(bottom: 23),
  //                               width: 40,
  //                               height: 50,
  //                               child: Stack(
  //                                 children: <Widget>[
  //                                   InkWell(
  //                                     onTap: () {
  //                                       pauseCurrentVideo();
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 ProfileScreen(
  //                                                   username:
  //                                                       videos[index].username,
  //                                                 )),
  //                                       );
  //                                     },
  //                                     child: CircleAvatar(
  //                                       radius: 20,
  //                                       backgroundColor: Colors.white,
  //                                       child: CircleAvatar(
  //                                         radius: 19,
  //                                         backgroundColor: Colors.black,
  //                                         backgroundImage:
  //                                             videos[index].userPicturePath !=
  //                                                     null
  //                                                 ? NetworkImage(api.serverUrl +
  //                                                     "/" +
  //                                                     videos[index]
  //                                                         .userPicturePath!)
  //                                                 : null,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Align(
  //                                     alignment: Alignment.bottomCenter,
  //                                     child: CircleAvatar(
  //                                       radius: 10,
  //                                       backgroundColor: const Color(0x00fd2c58)
  //                                           .withOpacity(1),
  //                                       child: const Center(
  //                                           child: Icon(Icons.add,
  //                                               size: 15, color: Colors.white)),
  //                                     ),
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                             Container(
  //                               padding: const EdgeInsets.only(bottom: 25),
  //                               child: InkWell(
  //                                 onTap: () {
  //                                   if (videos[index].userLikedTheVideo) {
  //                                     api.unlikeVideo(
  //                                         context, videos[index].id);
  //                                     videos[index].userLikedTheVideo = false;
  //                                     videos[index].likeCount--;
  //                                   } else {
  //                                     api.likeVideo(context, videos[index].id);
  //                                     videos[index].userLikedTheVideo = true;
  //                                     videos[index].likeCount++;
  //                                   }
  //                                   setState(() {});
  //                                 },
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   children: <Widget>[
  //                                     Icon(Icons.favorite,
  //                                         size: 35,
  //                                         color: videos[index].userLikedTheVideo
  //                                             ? Colors.red
  //                                             : Colors.white),
  //                                     Text(videos[index].likeCount.toString(),
  //                                         style: const TextStyle(
  //                                             color: Colors.white))
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                             Container(
  //                                 padding: const EdgeInsets.only(bottom: 20),
  //                                 child: InkWell(
  //                                   onTap: () {
  //                                     _showComments(videos[index].id);
  //                                   },
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.center,
  //                                     children: <Widget>[
  //                                       Transform(
  //                                           alignment: Alignment.center,
  //                                           transform:
  //                                               Matrix4.rotationY(math.pi),
  //                                           child: const Icon(Icons.sms,
  //                                               size: 35, color: Colors.white)),
  //                                       Text(
  //                                           videos[index]
  //                                               .commentCount
  //                                               .toString(),
  //                                           style: const TextStyle(
  //                                               color: Colors.white))
  //                                     ],
  //                                   ),
  //                                 )),
  //                             InkWell(
  //                                 hoverColor: Colors.blue,
  //                                 onTap: () {
  //                                   pauseCurrentVideo();
  //                                   api.shareVideo(context, videos[index].id);
  //                                   Share.share(
  //                                       'Check out this video on Spookify!\n' +
  //                                           api.serverUrl +
  //                                           '/' +
  //                                           videos[index].path!);
  //                                 },
  //                                 child: Container(
  //                                   padding: const EdgeInsets.only(bottom: 50),
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.center,
  //                                     children: <Widget>[
  //                                       Transform(
  //                                           alignment: Alignment.center,
  //                                           transform:
  //                                               Matrix4.rotationY(math.pi),
  //                                           child: const Icon(Icons.reply,
  //                                               size: 35, color: Colors.white)),
  //                                       Text(videos[index].shares.toString(),
  //                                           style: const TextStyle(
  //                                               color: Colors.white))
  //                                     ],
  //                                   ),
  //                                 )),
  //                             AnimatedBuilder(
  //                               animation: animationController,
  //                               child: CircleAvatar(
  //                                 radius: 22,
  //                                 backgroundColor:
  //                                     const Color(0x00222222).withOpacity(1),
  //                                 child: const CircleAvatar(
  //                                   radius: 12,
  //                                   // backgroundImage:
  //                                   //     AssetImage('assets/oboy.jpg'),
  //                                 ),
  //                               ),
  //                               builder: (context, _widget) {
  //                                 return Transform.rotate(
  //                                     angle: animationController.value * 6.3,
  //                                     child: _widget);
  //                               },
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ))
  //               ],
  //             );
  //           }));
  // }

  // _showComments(int currVideoID) async {
  //   await _loadComments(currVideoID);
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return VideoComments(comments, currVideoID, context,
  //             (() => _loadComments(currVideoID)));
  //       });
  // }

  // List<Comment> comments = [];

  // Future<void> _loadComments(int currVideoID) async {
  //   var value = await Api().getCommentsForVideo(context, currVideoID);
  //   Iterable list = value;
  //   comments = list.map((model) => Comment.fromJson(model)).toList();
  //   // inspect(comments);
  // }
}
