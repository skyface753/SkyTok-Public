const db = require('./db');
const UserService = require('./userService');

const sendResponse = require('../sendResponse.js');
const VideoSerice = require('./videoService');

let MessagesService = {
    send: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var receiver_id = req.body.receiver_id;
        var message = req.body.message;
        var video_id = req.body.video_id;
        if(receiver_id == null || message == null || user_id == null ){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(receiver_id == user_id){
            sendResponse.error(res, "You cannot send messages to yourself");
            return;
        }
        if(!await checkIfUserExists(receiver_id)){
            sendResponse.error(res, "User does not exist");
            return;
        }
        let message_id = "";
        if(video_id != null && video_id != ""){
            if(!await VideoSerice.checkIfVideoExistsExport(video_id)){
                sendResponse.error(res, "Video does not exist");
                return;
            }
            message_id = await db.queryPG(`INSERT INTO "messages" (from_user_id, to_user_id, message, timestamp, video_id) VALUES (${user_id}, ${receiver_id}, '${message}', CURRENT_TIMESTAMP, '${video_id}') RETURNING id`);
        }else{
            message_id = await db.queryPG(`INSERT INTO "messages" (from_user_id, to_user_id, message, timestamp) VALUES (${user_id}, ${receiver_id}, '${message}', CURRENT_TIMESTAMP) RETURNING id`);
        }
        sendResponse.success(res, message_id);
    },
    getChats: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        if(user_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        console.log("Messages for user_id: " + user_id);
        let tempChats = await db.queryPG(`SELECT  GREATEST("from_user_id", "to_user_id"), LEAST("from_user_id", "to_user_id"), MAX("timestamp") as "latest"
        FROM "messages" 
        WHERE "messages"."to_user_id" = ${user_id} OR "messages"."from_user_id" = ${user_id}
        GROUP BY GREATEST("from_user_id", "to_user_id"), LEAST("from_user_id", "to_user_id")
        ORDER BY "latest" DESC`);
        let chats = [];
        for(var i = 0; i < tempChats.length; i++){
            if(tempChats[i].greatest == tempChats[i].least){
                continue;
            }
            let chat = {};
            chat.user_id = tempChats[i].greatest;
            if(chat.user_id == user_id){
                chat.user_id = tempChats[i].least;
            }
            var lastMessage = await db.queryPG(`SELECT "video_id", "message", "timestamp", "record_path" FROM "messages" WHERE "from_user_id" = ${chat.user_id} AND "to_user_id" = ${user_id} OR "from_user_id" = ${user_id} AND "to_user_id" = ${chat.user_id} ORDER BY "timestamp" DESC LIMIT 1`);
            var unreadedCount = await db.queryPG(`SELECT COUNT("unReaded") as "unreaded" FROM "messages" WHERE "from_user_id" = ${chat.user_id} AND "to_user_id" = ${user_id} AND "unReaded" = true`);
            chat.latest = tempChats[i].latest;
            
            chat.message = lastMessage[0].message;
            if(lastMessage[0].video_id != null){
                chat.message = "Video";
            }
            if(lastMessage[0].record_path != null){
                chat.message = "Audio";
            }
            chat.unReaded = unreadedCount[0].unreaded;
            var currChatUser = await db.queryPG(`SELECT "username", "picturePath" FROM "users" WHERE id = ${chat.user_id}`);
            chat.username = currChatUser[0].username;
            chat.picturePath = currChatUser[0].picturePath;
            // chat.username = await getUsernameFromUserId(chat.user_id);
            chats.push(chat);
        }
        sendResponse.success(res, chats);  
    },
    getMessages: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var other_user_id = req.body.other_user_id;
        if(other_user_id == null || user_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(other_user_id == user_id){
            sendResponse.error(res, "You cannot send messages to yourself");
            return;
        }
        if(!await checkIfUserExists(other_user_id)){
            sendResponse.error(res, "User does not exist");
            return;
        }
        let messages = await db.queryPG(`SELECT "id", "from_user_id", "to_user_id", "message", "timestamp", "video_id", "record_path"
        FROM "messages"
        WHERE (("from_user_id" = ${user_id} AND "to_user_id" = ${other_user_id}) OR ("from_user_id" = ${other_user_id} AND "to_user_id" = ${user_id}))
        ORDER BY "timestamp" DESC`);
        for(var i = 0; i < messages.length; i++){
            if(messages[i].video_id){
                var video = await VideoSerice.getVideoExport(messages[i].video_id, user_id, 4);
                messages[i].video = video;
            }
        }
        sendResponse.success(res, messages);
    },
    readMessagesFromChat: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var other_user_id = req.body.other_user_id;
        if(other_user_id == null || user_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(other_user_id == user_id){
            sendResponse.error(res, "You cannot send messages to yourself");
            return;
        }
        if(!await checkIfUserExists(other_user_id)){
            sendResponse.error(res, "User does not exist");
            return;
        }
        await db.queryPG(`UPDATE "messages" SET "unReaded" = 0 WHERE "to_user_id" = ${user_id} AND "from_user_id" = ${other_user_id}`);
        sendResponse.success(res, "Messages readed");
    },

}

async function getUsernameFromUserId(user_id){
    let username = await db.queryPG(`SELECT "username" FROM "users" WHERE id = ${user_id}`);
    return username[0].username;
}

async function checkIfUserExists(user_id){
    let user = await db.queryPG(`SELECT id FROM "users" WHERE id = ${user_id}`);
    return user.length > 0;
}

module.exports = MessagesService;