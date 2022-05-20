import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:skytok_flutter/components/videos_grid.dart';
import 'package:skytok_flutter/models/user.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/screens/followers_screen.dart';
import 'package:skytok_flutter/screens/messages_screen.dart';
import 'package:skytok_flutter/screens/preloaded_videos_screen.dart';
import 'package:skytok_flutter/screens/stream/watch_screen.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:skytok_flutter/services/api_requests.dart';
// import 'package:video_player/video_player.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;
  const ProfileScreen({this.username, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class FollowerSuggestion {
  int id;
  String username;
  String? picturePath;
  bool? isFollowing;

  FollowerSuggestion(
      this.id, this.username, this.picturePath, this.isFollowing);

  FollowerSuggestion.fromJson(Map json)
      : id = json['id'],
        username = json['username'],
        picturePath = json['picturePath'],
        isFollowing = json['isFollowing'] ?? false;

  Map toJson() {
    return {
      'id': id,
      'username': username,
      'picturePath': picturePath,
      'isFollowing': isFollowing,
    };
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<FollowerSuggestion> _followerSuggestions = [];
  List<Video> _userVideos = [];
  late User currentUser;
  List<Video> _likedVideos = [];

  List<Followers> _followers = [];
  List<Following> _following = [];
  int followersCount = 0;
  int followingCount = 0;
  int likeCountVideos = 0;

  bool userVideosLoaded = false;
  bool likedVideosLoaded = false;
  bool userInfoLoaded = false;
  bool showFollowerSuggestions = false;
  bool isLive = false;

  int currentVideoView = 0; // 0 = video, 1 = liked

  _changeUserVideosIndex(int index) {
    setState(() {
      currentVideoView = index;
    });
  }

  _getFollowerSuggestions() async {
    Iterable list = await Api().followerSuggestions(context);
    _followerSuggestions =
        list.map((model) => FollowerSuggestion.fromJson(model)).toList();
    // inspect(_followerSuggestions);
    setState(() {});
  }

  _getUserVideos() async {
    String? username = widget.username == null ? null : widget.username!;
    Iterable list = await api.getVideosForUser(context, username);
    _userVideos = list.map((model) => Video.fromJson(model)).toList();
    setState(() {
      userVideosLoaded = true;
    });
  }

  _getLikedVideos() async {
    String? username = widget.username == null ? null : widget.username!;
    Iterable list = await Api().getLikedForUser(context, username);
    _likedVideos = list.map((model) => Video.fromJson(model)).toList();
    setState(() {
      likedVideosLoaded = true;
    });
  }

  _getUserInfo() async {
    String? username = widget.username == null ? null : widget.username!;
    var value = await Api().getUserInfo(context, username);
    currentUser = User.fromJson(value['user']);
    Iterable followersList = value['followers']['followers'];
    Iterable followingList = value['following']['following'];
    followersCount = value['followers']['count'];
    followingCount = value['following']['count'];
    likeCountVideos = int.parse(value['likeCountUser']);
    isLive = value['isLive'];
    _followers =
        followersList.map((model) => Followers.fromJson(model)).toList();
    _following =
        followingList.map((model) => Following.fromJson(model)).toList();
    setState(() {
      userInfoLoaded = true;
    });
    if (api.myId == currentUser.id) {
      api.myPicturePath = currentUser.picturePath;
    }
  }

  _loadResources() {
    _getUserVideos();
    _getUserInfo();
    _getLikedVideos();
    _getFollowerSuggestions();
  }

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  double heightWithFollowerSuggestions = 510;
  double heightWithoutFollowerSuggestions = 310;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: userInfoLoaded
              ? Text(currentUser.username)
              : widget.username == null
                  ? const Text("Profile")
                  : Text(widget.username!),
          actions: userInfoLoaded
              ? <Widget>[
                  // Refresh button
                  kDebugMode
                      ? IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              userVideosLoaded = false;
                              likedVideosLoaded = false;
                              userInfoLoaded = false;
                              _loadResources();
                            });
                          },
                        )
                      : Container(),
                  api.myId == currentUser.id
                      ? IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        )
                      : Container(),
                  api.myId == currentUser.id
                      ? IconButton(
                          icon: Icon(Icons.analytics),
                          onPressed: () {
                            Navigator.pushNamed(context, '/analytics');
                          },
                        )
                      : Container(),
                ]
              : <Widget>[],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              userVideosLoaded = false;
              likedVideosLoaded = false;
              userInfoLoaded = false;
              _loadResources();
            });
          },
          child: CustomScrollView(
            primary: false,
            slivers: <Widget>[
              !userInfoLoaded
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: showFollowerSuggestions
                            ? heightWithFollowerSuggestions + (isLive ? 41 : 0)
                            : heightWithoutFollowerSuggestions +
                                (isLive ? 41 : 0),
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Container(
                        height: showFollowerSuggestions
                            ? heightWithFollowerSuggestions + (isLive ? 41 : 0)
                            : heightWithoutFollowerSuggestions +
                                (isLive ? 41 : 0),
                        width: double.infinity,
                        child: Container(
                            child: SizedBox(
                          width: double.infinity,
                          height: 200.0,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                    onTap: () {
                                      isLive
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WatchLiveStreamScreen(
                                                          currentUser.id)))
                                          : null;
                                    },
                                    child: Column(
                                      children: [
                                        currentUser.picturePath != null
                                            ? CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: NetworkImage(
                                                    api.serverUrl +
                                                        "/" +
                                                        currentUser
                                                            .picturePath!,
                                                    headers: {
                                                      'Authorization': api.token
                                                    }),
                                                radius: 50.0,
                                              )
                                            : const CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: AssetImage(
                                                    "assets/images/avatar.png"),
                                                radius: 50.0,
                                              ),
                                        isLive
                                            ? SizedBox(height: 5)
                                            : SizedBox(),
                                        isLive
                                            ? Container(
                                                width: 100,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Live",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    )),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "@" + currentUser.username,
                                      style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                //Goto Messages Screen
                                currentUser.id != api.myId
                                    ? Center(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MessagesScreen(
                                                          otherUserId:
                                                              currentUser.id,
                                                          otherUserName:
                                                              currentUser
                                                                  .username,
                                                          picturePath: currentUser
                                                                  .picturePath ??
                                                              null,
                                                        )),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.circular(10.0),
                                                color: Colors.black87,
                                              ),
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                "Message",
                                                style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )))
                                    // ? Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.center,
                                    //     children: <Widget>[
                                    //       FlatButton(
                                    //         child: const Text(
                                    //           "Message",
                                    //           style: TextStyle(
                                    //               fontSize: 15.0,
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Colors.white),
                                    //         ),
                                    //         onPressed: () {
                                    //           Navigator.push(
                                    //             context,
                                    //             MaterialPageRoute(
                                    //                 builder: (context) =>
                                    //                     MessagesScreen(
                                    //                       otherUserId:
                                    //                           currentUser.id,
                                    //                       otherUserName:
                                    //                           currentUser
                                    //                               .username,
                                    //                     )),
                                    //           );
                                    //         },
                                    //       ),
                                    //     ],
                                    //   )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                //Followers and Following count
                                IntrinsicHeight(
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowersScreen(
                                                _followers,
                                                _following,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Text(
                                                  followersCount.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                                const Text(
                                                  "Followers",
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            const VerticalDivider(
                                              color: Colors.white,
                                              width: 10.0,
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Text(
                                                  followingCount.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                                const Text(
                                                  "Following",
                                                  style: const TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            const VerticalDivider(
                                              color: Colors.white,
                                              width: 10.0,
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Text(
                                                  likeCountVideos.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                                const Text(
                                                  "Likes",
                                                  style: const TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ))),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                //Follow button
                                currentUser.id != api.myId &&
                                        currentUser.userFollowing != null
                                    ? currentUser.userFollowing!
                                        ? Center(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 40.0,
                                                width: 100.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  // borderRadius:
                                                  //     BorderRadius.circular(
                                                  //         20.0)
                                                ),
                                                child: Center(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await Api().unFollowUser(
                                                          context,
                                                          currentUser.id);
                                                      setState(() {
                                                        currentUser
                                                                .userFollowing =
                                                            false;
                                                      });
                                                    },
                                                    child: Text(
                                                      "Unfollow",
                                                      style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Container(
                                                height: 40.0,
                                                width: 40.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  // borderRadius:
                                                  //     BorderRadius.(
                                                  //         20.0)
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    icon: showFollowerSuggestions
                                                        ? Icon(
                                                            Icons.arrow_upward)
                                                        : Icon(Icons
                                                            .arrow_downward),
                                                    onPressed: () {
                                                      setState(() {
                                                        showFollowerSuggestions =
                                                            !showFollowerSuggestions;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                        : Center(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 40.0,
                                                width: 100.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  // borderRadius:
                                                  //     BorderRadius.circular(
                                                  //         20.0)
                                                ),
                                                child: Center(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await Api().followUser(
                                                          context,
                                                          currentUser.id);
                                                      setState(() {
                                                        currentUser
                                                                .userFollowing =
                                                            true;
                                                      });
                                                    },
                                                    child: Text(
                                                      "Follow",
                                                      style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Container(
                                                height: 40.0,
                                                width: 40.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  // borderRadius:
                                                  //     BorderRadius.(
                                                  //         20.0)
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    icon: showFollowerSuggestions
                                                        ? Icon(
                                                            Icons.arrow_upward)
                                                        : Icon(Icons
                                                            .arrow_downward),
                                                    onPressed: () {
                                                      setState(() {
                                                        showFollowerSuggestions =
                                                            !showFollowerSuggestions;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                    : Container(),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                showFollowerSuggestions
                                    ? Container(
                                        alignment: Alignment.center,
                                        height: 200.0,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                _followerSuggestions.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                height: 200.0,
                                                width: 200.0,
                                                child: Column(
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () => _gotoProfile(
                                                          _followerSuggestions[
                                                                  index]
                                                              .username),
                                                      child: Container(
                                                        height: 100.0,
                                                        width: 100.0,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image: _followerSuggestions[
                                                                            index]
                                                                        .picturePath !=
                                                                    null
                                                                ? DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: NetworkImage(
                                                                        _followerSuggestions[index]
                                                                            .picturePath!))
                                                                : DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: AssetImage(
                                                                        "assets/images/avatar.png"))),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    InkWell(
                                                      onTap: () => _gotoProfile(
                                                          _followerSuggestions[
                                                                  index]
                                                              .username),
                                                      child: Text(
                                                        _followerSuggestions[
                                                                index]
                                                            .username,
                                                        style: const TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    InkWell(
                                                        onTap: () async {
                                                          await Api().followUser(
                                                              context,
                                                              _followerSuggestions[
                                                                      index]
                                                                  .id);
                                                          setState(() {
                                                            _followerSuggestions[
                                                                        index]
                                                                    .isFollowing =
                                                                true;
                                                          });
                                                        },
                                                        child: Container(
                                                            height: 40.0,
                                                            width: 100.0,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0)),
                                                            child: Center(
                                                              child: Text(
                                                                "Follow",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            )))
                                                  ],
                                                ),
                                              );
                                            }),
                                      )
                                    : Container(),
                                Text(
                                  currentUser.biography ?? "No Bio Available",
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        )),
                      ),
                    ),
              SliverToBoxAdapter(
                child: Container(
                    height: 56,
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(children: [
                          IconButton(
                            icon: Icon(Icons.list),
                            color: currentVideoView == 0
                                ? Colors.white
                                : Colors.grey,
                            onPressed: () {
                              _changeUserVideosIndex(0);
                            },
                          ),
                          Container(
                            width: 40,
                            color: currentVideoView == 0
                                ? Colors.white
                                : Colors.transparent,
                            height: 1,
                          ),
                        ])),
                        Expanded(
                            child: Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              color: currentVideoView == 1
                                  ? Colors.white
                                  : Colors.grey,
                              onPressed: () {
                                _changeUserVideosIndex(1);
                              },
                            ),
                            Container(
                              width: 40,
                              color: currentVideoView == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              height: 1,
                            ),
                          ],
                        )),
                      ],
                    )),
              ),
              userVideosLoaded && likedVideosLoaded
                  ? buildVideosGrid(
                      context,
                      currentVideoView == 0 ? _userVideos : _likedVideos,
                      "From Profile")
                  : SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 0.0),
              )
            ],
          ),
        ));
  }

  _gotoProfile(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(username: username),
      ),
    );
  }
}

/*
"to_user_id": 2,
                    "username": "dfeldbusch"
  */
class Following {
  int toUserId;
  String username;
  String? picturePath;
  Following(this.toUserId, this.username, this.picturePath);

  Following.fromJson(Map json)
      : toUserId = json['to_user_id'],
        username = json['username'],
        picturePath = json['picturePath'];

  Map toJson() {
    return {
      'to_user_id': toUserId,
      'username': username,
      'picturePath': picturePath,
    };
  }
}

/*
"from_user_id": 8,
                    "username": "skyface1"
                    */
class Followers {
  int fromUserId;
  String username;
  String? picturePath;
  Followers(this.fromUserId, this.username, this.picturePath);

  Followers.fromJson(Map json)
      : fromUserId = json['from_user_id'],
        username = json['username'],
        picturePath = json['picturePath'];

  Map toJson() {
    return {
      'from_user_id': fromUserId,
      'username': username,
      'picturePath': picturePath,
    };
  }
}
