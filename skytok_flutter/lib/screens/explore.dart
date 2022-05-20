import 'package:flutter/material.dart';
import 'package:skytok_flutter/models/tag.dart';
import 'package:skytok_flutter/models/user.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/screens/preloaded_videos_screen.dart';
import 'package:skytok_flutter/screens/profile.dart';
import 'package:skytok_flutter/screens/tag_screen.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:skytok_flutter/services/api_requests.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({Key? key}) : super(key: key);

  @override
  _ExploreViewState createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  List<Video> searchedVideos = [];
  List<Tag> searchedTags = [];
  List<User> searchedUsers = [];

  List<Tag> trendingTags = [];
  List<Video> trendingVideos = [];

  bool isSearching = false;

  _loadTrendingTags() async {
    Iterable list = await Api().trendingTags(context);
    trendingTags = list.map((tag) => Tag.fromJson(tag)).toList();
    return;
  }

  _loadTrendingVideos() async {
    // Wait 10 seconds before loading trending videos
    // await Future.delayed(Duration(seconds: 10));
    //TODO: Implement loading trending videos
    return;
  }

  _loadExplore() async {
    //Promise all for Videos and Tags
    List<Future> futures = [
      _loadTrendingTags(),
      _loadTrendingVideos(),
    ];
    await Future.wait(futures);
    setState(() {
      // isSearching = false;
    });
    return;
  }

  @override
  void initState() {
    _loadExplore(); // Load trending tags and videos
    super.initState();
  }

  // TextEditingController _searchController = TextEditingController();

  _search(String text) async {
    if (text == "") {
      setState(() {
        isSearching = false;
      });
      return;
    }
    if (!isSearching) {
      setState(() {
        isSearching = true;
      });
    }
    api.search(context, text).then((value) {
      Iterable list = value['videos'];
      searchedVideos = list.map((model) => Video.fromJson(model)).toList();
      list = value['tags'];
      searchedTags = list.map((model) => Tag.fromJson(model)).toList();
      list = value['users'];
      searchedUsers = list.map((model) => User.fromJson(model)).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Search'),
          //Refresh
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _loadExplore();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
              ),
              onChanged: (text) {
                _search(text);
              },
            ),
            isSearching
                ? Expanded(
                    child: ListView(
                      children: [
                        ...searchedVideos.map((video) => ListTile(
                              title: Text(video.id.toString()),
                              subtitle: Text(video.descryption),
                              leading: Image.network(
                                  api.serverUrl + "/" + video.thumbnailPath),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return PreLoadedVideosScreen(
                                      videos: searchedVideos,
                                      startIndex:
                                          searchedVideos.indexOf(video));
                                }));
                              },
                            )),
                        ...searchedTags.map((tag) => ListTile(
                              title: Text(tag.tag),
                              leading: Icon(Icons.tag),
                              onTap: () {
                                print("Tag tapped");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TagScreen(
                                              tagId: tag.id,
                                              tagName: tag.tag,
                                            )));
                              },
                            )),
                        ...searchedUsers.map(
                          (user) => ListTile(
                              title: Text(user.username),
                              leading: user.picturePath != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          api.serverUrl +
                                              "/" +
                                              user.picturePath!,
                                          headers: {
                                          'Authorization': api.token
                                        }))
                                  : const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/avatar.png")),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                              username: user.username,
                                            )));
                              }),
                        ),
                      ],
                    ),
                  )
                : // Trending tags and videos
                Expanded(
                    child: ListView(
                      children: [
                        ...trendingTags.map((tag) => ListTile(
                              title: Text(tag.tag),
                              leading: Icon(Icons.tag),
                              onTap: () {
                                print("Tag tapped");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TagScreen(
                                              tagId: tag.id,
                                              tagName: tag.tag,
                                            )));
                              },
                            )),
                        ...trendingVideos.map((video) => ListTile(
                              title: Text(video.id.toString()),
                              subtitle: Text(video.descryption),
                              leading: Image.network(
                                  api.serverUrl + "/" + video.thumbnailPath,
                                  headers: {'Authorization': api.token}),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return PreLoadedVideosScreen(
                                      videos: trendingVideos,
                                      startIndex:
                                          trendingVideos.indexOf(video));
                                }));
                              },
                            )),
                      ],
                    ),
                  ),
          ],
        ));
  }
}
