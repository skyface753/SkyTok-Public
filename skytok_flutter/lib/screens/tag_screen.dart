import 'package:flutter/material.dart';
import 'package:skytok_flutter/components/videos_grid.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:skytok_flutter/services/number_formatter.dart';

class TagScreen extends StatefulWidget {
  final String tagName;
  final int? tagId;
  const TagScreen({this.tagId, required this.tagName, Key? key})
      : super(key: key);

  @override
  _TagScreenState createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  List<Video> videos = [];
  bool isLoading = true;
  int viewCount = 0;

  @override
  void initState() {
    super.initState();
    _getVideosForTag();
  }

  _getVideosForTag() async {
    var value = await api.getVideosForTag(context, widget.tagName);
    Iterable list = value['videoTags'];
    videos = list.map((model) => Video.fromJson(model)).toList();
    viewCount = int.tryParse(value['viewCount']) ?? 0;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#' + widget.tagName),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.blueAccent,
                    child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey,
                              child: Icon(Icons.tag, size: 50),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#' + widget.tagName,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  NumberFormatter.format(viewCount) + ' views',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        )),
                  ),
                ),
                buildVideosGrid(context, videos, "From Tagscreen"),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 0.0),
                )
              ],
            ),
    );
  }

  // _buildVideo(Video video) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.pushNamed(context, '/video', arguments: video);
  //     },
  //     child: Card(
  //       child: Column(
  //         children: <Widget>[
  //           AspectRatio(
  //             aspectRatio: 16 / 9,
  //             child: Image.network(
  //               api.serverUrl + "/" + video.thumbnailPath,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               video.username,
  //               style: TextStyle(fontSize: 14.0),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
