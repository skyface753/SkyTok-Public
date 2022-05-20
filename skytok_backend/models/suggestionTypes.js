const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let suggestionTypes = new Schema(
  {
    suggestion_type: { // 0 = Tag, 1 = Following, 2 = Trends, 3 = Manual, 4 = Messages, 5 = Search
        type: Number,
        required: true
    },
    video_id: {
        type: Number,
        required: true
    },
    user_id: {
        type: Number,
        required: true
    }
  },
  { collection: "suggestionTypes" }
);

module.exports = mongoose.model("suggestionTypes", suggestionTypes);