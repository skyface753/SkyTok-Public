const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let videosLikes = new Schema(
  {
    video_id:
    {
        type: Number,
        required: true
    },
    user_id:
    {
        type: Number,
        required: true
    },
    dateTime:
    {
        type: Date,
        required: true
        // default: Date.now
    },
  },
  { collection: "videosLikes" }
);

module.exports = mongoose.model("videosLikes", videosLikes);