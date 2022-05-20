import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/models/comment.dart';

import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:flash/flash.dart';

TextEditingController _commentController = TextEditingController();
Widget VideoComments(List<Comment> comments, currVideoID, context,
    int suggestionType, AsyncCallback loadCommentsCallback) {
  return StatefulBuilder(
    builder: (context, setStateComments) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        // color: Colors.green,
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
              width: MediaQuery.of(context).size.width,
              child:
                  Align(alignment: Alignment.center, child: Text("Comments")),
            ),
            Expanded(
              // height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      // color: Colors.cyanAccent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          //TODO Add with user picture
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(comments[index].username,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 5),
                                Text(comments[index].comment,
                                    style: const TextStyle(
                                      // color: Colors.black,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          //Like Button
                          Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  comments[index].liked
                                      ? {
                                          api.unlikeComment(
                                              context, comments[index].id),
                                          comments[index].likeCount--
                                        }
                                      : {
                                          api.likeComment(
                                              context, comments[index].id),
                                          comments[index].likeCount++
                                        };
                                  setStateComments(() {
                                    comments[index].liked =
                                        !comments[index].liked;
                                  });
                                },
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 5),
                                    Icon(
                                      Icons.thumb_up,
                                      color: comments[index].liked
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    Text(comments[index].likeCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    );
                  }),
            ),
            Divider(),
            Container(
                height: 50,
                child: Row(children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _commentController,
                      // controller: commentController,
                      decoration: InputDecoration(
                          hintText: 'Commenter',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  )),
                  Divider(
                    height: 20,
                  ),
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                      ),
                      child: InkWell(
                        onTap: () {
                          _postNewComment(
                              context,
                              currVideoID,
                              _commentController.text,
                              suggestionType,
                              loadCommentsCallback);
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ))
                ]))
          ],
        ),
      );
    },
  );
}

_postNewComment(BuildContext context, int currVideoID, String commentText,
    int suggestionType, loadCommentsCallback) async {
  if (commentText.isEmpty) {
    context.showToast('Please enter a comment');
    return;
  }
  var response = await api.createComment(
      context, currVideoID, commentText, suggestionType);
  if (response["error"] == false) {
    context.showSuccessBar(content: Text("Comment posted"));
    _commentController.clear();
    Navigator.pop(context);
    loadCommentsCallback();
  } else {
    context.showErrorBar(content: Text(response["message"]));
  }
}
