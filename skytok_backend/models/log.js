const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let log = new Schema(
  {
    level: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    trace: {
        type: String,
        required: false
    },
    dateTime: {
        type: Date,
        default: Date.now
    }
  },
  { collection: "log" }
);

module.exports = mongoose.model("log", log);