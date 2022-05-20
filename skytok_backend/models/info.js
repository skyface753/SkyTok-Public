const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let deviceInfo = new Schema(
  {
    url: {
        type: String,
        required: true
    },
    Platform: {
        type: String,
        required: true
    }
  },
  { collection: "deviceInfo", strict: false }
);

module.exports = mongoose.model("deviceInfo", deviceInfo);