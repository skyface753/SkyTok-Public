const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let videosShares = new Schema(
  {
    video_id:
    {
        type: Number,
        required: true
    },
    dateTime:
    {
        type: Date,
        required: true
    },
  },
  { collection: "videosShares" }
);

module.exports = mongoose.model("videosShares", videosShares);