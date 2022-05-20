
const VideoService = require('../services/videoService.js');

initDBServer = {
    init: function () {
        VideoService.getAllVideos({}, {
            send: function (result) {
                if(result.length == 0) {
                    console.log("INITIALIZE VIDEOS");
                    VideoService.createVideo({
                        title: "Video 1",
                        description: "Video 1 description",
                        url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                        thumbnail: "https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg",
                        user_id: "5d6f0c6b3a8f8d0b0c0d2a6e"
                    }, {
                        send: function (result) {
                            console.log(result);
                        }
                    });
                }
            }
        });
    }
}