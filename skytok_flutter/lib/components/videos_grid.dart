import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/screens/preloaded_videos_screen.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:skytok_flutter/services/number_formatter.dart';

Widget buildVideosGrid(
    BuildContext context, List<Video> _userVideos, String test) {
  if (_userVideos.isEmpty) {
    return SliverToBoxAdapter(
      child: Container(
        child: Center(
          child: Text(
            "No videos found",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
  return SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: MediaQuery.of(context).size.width /
          (MediaQuery.of(context).size.height) /
          0.9,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        return InkWell(
            onTap: () {
              // inspect(_userVideos);
              print("Teststring: " + test);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PreLoadedVideosScreen(
                  videos: _userVideos,
                  startIndex: index,
                );
              }));
            },
            // height: 200.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                    api.serverUrl + "/" + _userVideos[index].thumbnailPath,
                    fit: BoxFit.cover,
                    headers: {'Authorization': api.token}),
                Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 100,
                      // height: 150,
                      child: Row(children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 3),
                        Text(
                          NumberFormatter.format(
                              _userVideos[index].watchedCount),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ));
      },
      childCount: _userVideos.length,
    ),
  );
}
