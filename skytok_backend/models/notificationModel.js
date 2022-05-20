const mongoose = require("mongoose");

const Schema = mongoose.Schema;

/*
Types:
0: New Followers
1: New Likes
2: New Comments
*/

let notification = new Schema(
  {
    for_user_id: {
        type: Number,
        required: true
    },
    type: {
        type: Number,
        required: true
    },
    timestamp: {
        type: Date,
        required: true
    },
    newFollower: {
        type: Number,
        required: false
    },
    newLikeVideoID: {
        type: Number,
        required: false
    },
    newLikeUserID: {
        type: Number,
        required: false
    },
    newCommentVideoID: {
        type: Number,
        required: false
    },
    newCommentUserID: {
        type: Number,
        required: false
    }
  },
  { collection: "notification" }
);

module.exports = mongoose.model("notification", notification);