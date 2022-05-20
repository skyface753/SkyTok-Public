const NodeMediaServer = require('node-media-server');
// const liveService = require('./services/liveService');

const config = {
  rtmp: {
    port: 1935,
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60
  },
  http: {
    port: 8000,
    mediaroot: './media',
    allow_origin: process.env.ALLOW_ORIGIN || '*'
  },
  trans: {
    ffmpeg: '/usr/bin/ffmpeg',
    tasks: [
      {
        app: 'live',
        hls: true,
        hlsFlags: '[hls_time=2:hls_list_size=3:hls_flags=delete_segments]',
        dash: true,
        dashFlags: '[f=dash:window_size=3:extra_window_size=5]'
      }
    ]
  }
};

var nms = new NodeMediaServer(config)
nms.run();




// nms = new NodeMediaServer(config);

// nms.on('prePublish', async (id, StreamPath, args) => {
//     let stream_key = getStreamKeyFromStreamPath(StreamPath);
//     console.log('[NodeEvent on prePublish]', `id=${id} StreamPath=${StreamPath} args=${JSON.stringify(args)}`);

//     // User.findOne({stream_key: stream_key}, (err, user) => {
//     //     if (!err) {
//     //         if (!user) {
//     //             let session = nms.getSession(id);
//     //             session.reject();
//     //         } else {
//     //             helpers.generateStreamThumbnail(stream_key);
//     //         }
//     //     }
//     // });
// });

// const getStreamKeyFromStreamPath = (path) => {
//     let parts = path.split('/');
//     return parts[parts.length - 1];
// };

// module.exports = nms;
