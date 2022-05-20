import 'package:flutter/material.dart';
import 'package:skytok_flutter/screens/profile.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;

class FollowersScreen extends StatefulWidget {
  final List<Followers> followers;
  final List<Following> following;
  FollowersScreen(this.followers, this.following, {Key? key}) : super(key: key);
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<Followers> allFollowers = [];
  List<Following> allFollowing = [];
  List<Followers> filteredFollowers = [];
  List<Following> filteredFollowing = [];

  int currentView = 0; // 0 = followers, 1 = following

  @override
  void initState() {
    super.initState();
    allFollowers = widget.followers;
    allFollowing = widget.following;
    filteredFollowers = allFollowers;
    filteredFollowing = allFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
      ),
      body: Column(children: [
        // Search bar
        Container(
          height: 50,
          padding: EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search',
            ),
            onChanged: (searchText) {
              if (currentView == 0) {
                _searchFollowes(searchText);
              } else {
                _searchFollowing(searchText);
              }
            },
          ),
        ),
        Container(
          height: 50,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    currentView = 0;
                    filteredFollowers = allFollowers;
                  });
                },
                child: Center(
                    child: Text(
                  'Followers',
                  style: TextStyle(
                    color: currentView == 0 ? Colors.white : Colors.grey,
                  ),
                )),
              )),
              Expanded(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    currentView = 1;
                    filteredFollowing = allFollowing;
                  });
                },
                child: Center(
                    child: Text(
                  'Following',
                  style: TextStyle(
                    color: currentView == 1 ? Colors.white : Colors.grey,
                  ),
                )),
              )),
            ],
          ),
        ),
        // Followers/Following list
        Expanded(
          child: ListView.builder(
            itemCount: currentView == 0
                ? filteredFollowers.length
                : filteredFollowing.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: currentView == 0
                    ? filteredFollowers[index].picturePath != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                api.serverUrl +
                                    "/" +
                                    filteredFollowers[index].picturePath!,
                                headers: {'Authorization': api.token}))
                        : const CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/avatar.png"))
                    : filteredFollowing[index].picturePath != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                api.serverUrl +
                                    "/" +
                                    filteredFollowing[index].picturePath!,
                                headers: {'Authorization': api.token}))
                        : const CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/avatar.png")),
                title: Text(
                  currentView == 0
                      ? filteredFollowers[index].username
                      : filteredFollowing[index].username,
                ),
                onTap: () {
                  // throw UnimplementedError();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        username: currentView == 0
                            ? filteredFollowers[index].username
                            : filteredFollowing[index].username,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  _searchFollowes(String searchText) {
    setState(() {
      filteredFollowers = allFollowers.where((follower) {
        return follower.username
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    });
  }

  _searchFollowing(String searchText) {
    setState(() {
      filteredFollowing = allFollowing.where((following) {
        return following.username
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    });
  }
}
