const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let trendTagWorth = new Schema(
  {
    tag_id: {
        type: Number,
        required: true
    },
    tag_worth: {
        type: Number, 
        required: true
    },
    dateTime: {
        type: Date,
        default: Date.now
    }
  },
  { collection: "trendTagWorth" }
);

module.exports = mongoose.model("trendTagWorth", trendTagWorth);