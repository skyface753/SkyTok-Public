const db = require('./db');
const UserService = require('./userService');
const sendResponse = require('../sendResponse');
const https = require('http');
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));


let liveService = {
    liveExistsExport: async function(stream_name) {
        var result = await db.queryPG(`SELECT * FROM users_live WHERE "stream_name" = '${stream_name}'`);
        if(result == null){
            return false;
        }
        if(result.length > 0){
            return true;
        }
        return false;
    },
    isLiveExport: async function (user_id){
        let userLive = await db.queryPG(`SELECT * FROM users_live WHERE user_id = ${user_id}`);
        if(userLive == null){
            return false;
        }
        if(userLive.length > 0){
            return true;
        }else{
            return false;
        }
    },
    start: async function (req, res){
        let user_id = await UserService.getUserIdFromTokenExport(req);
        if(user_id == null){
            sendResponse.error(res, "Invalid token");
            return;
        }
        console.log(user_id);
        var isLive = await liveService.isLiveExport(user_id);
        if(isLive){
            var stream_name = await db.queryPG(`SELECT "stream_name" FROM users_live WHERE user_id = ${user_id}`);
            sendResponse.success(res, {
                streamName: stream_name[0].stream_name,
                isLive: true
            });
            return;
        }
        // Random gernate a string
        let streamName = makeStreamName(10);
        let result = await db.queryPG(`INSERT INTO users_live (user_id, stream_name) VALUES (${user_id}, '${streamName}')`);
        sendResponse.success(res, {
            isLive: true,
            streamName: streamName
        });
    },
    stopFromNms: async function (stream_name){
        try{

            let result = await db.queryPG(`DELETE FROM users_live WHERE stream_name = '${stream_name}'`);
            return true;
        }catch(e){
            return false;
        }
    },
    stop: async function (req, res){
        let user_id = await UserService.getUserIdFromTokenExport(req);
        if(user_id == null){
            sendResponse.error(res, "Invalid token");
            return;
        }
        let result = await db.queryPG(`DELETE FROM users_live WHERE user_id = ${user_id}`);
        sendResponse.success(res, {
            isLive: false
        });
    },
    join: async function (req, res){
        let stream_user_id = req.body.stream_user_id;
        let user_id = await UserService.getUserIdFromTokenExport(req);
        if(user_id == null){
            sendResponse.error(res, "Invalid token");
            return;
        }
        let streamName = await db.queryPG(`SELECT "stream_name" FROM users_live WHERE user_id = ${stream_user_id}`);
        if(streamName == null || streamName.length == 0){
            sendResponse.error(res, "Stream does not exist");
            return;
        }

        sendResponse.success(res, {
            isLive: true,
            streamName: streamName[0].stream_name
        });
    },
    getViewersForLiveExport: async function (req, res){
        let stream_name = req.body.stream_name;
        if(stream_name == null){
            console.log("Stream name is null");
            return null;
        }
    
        await fetch('http://localhost:8000/api/streams')
        .then(response => response.json())
        .then(data => {
            try{
                
                var stream = data.live[stream_name];
                if(stream == null){
                    sendResponse.error(res, "Stream does not exist");
                    return;
                }
                console.log("Stream exists");
                var subscribers = stream.subscribers;
                var viewersCount = subscribers.length;
                sendResponse.success(res, viewersCount);
            }catch(e){
                console.log("Error: " + e);
                sendResponse.error(res, "Error");
            }
        })
        .catch(err => console.error(err));
    }
}

function makeStreamName(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
      result += characters.charAt(Math.floor(Math.random() * 
 charactersLength));
   }
   return result;
}


module.exports = liveService;