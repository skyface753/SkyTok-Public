const mongoose = require("mongoose");

const Schema = mongoose.Schema;

let appTime = new Schema(
  {
   user_id: {
       type: Number,
         required: true
   },
   start_time: {
         type: Date,   
            required: true
   },
    end_time: {
            type: Date,
            required: true
    },
    duration: {
            type: Number,
            required: true
    },
    pause_duration: {
            type: Number,
            required: true
    }
  },
  { collection: "appTime" }
);

module.exports = mongoose.model("appTime", appTime);