const db = require("./db");
const UserService = require("./UserService");
const sendResponse = require("../sendResponse");
const notificationModel = require("../models/notificationModel")

let notificationService = {
    getNotifications: async function(req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        // user_id = 8;
        if(user_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        //Order by timestamp DESC
        
        let notifications = await notificationModel.find({for_user_id: user_id}).sort({timestamp: -1});
        let notifications_array = [];
        for(var i = 0; i < notifications.length; i++){
            if(notifications[i].type == 0){ //Follow
                let new_follower = await db.queryPG(`SELECT "username", "picturePath" FROM "users" WHERE id = ${notifications[i].newFollower}`);
                notifications_array.push({
                    for_user_id: notifications[i].for_user_id,
                    type: notifications[i].type,
                    timestamp: notifications[i].timestamp,
                    newFollowerID: notifications[i].newFollower,
                    newFollower: new_follower[0].username,
                    picturePath: new_follower[0].picturePath
                });
            }else if(notifications[i].type == 1){ //Likes
                let newLikeUserID = await db.queryPG(`SELECT "username", "picturePath" FROM "users" WHERE id = ${notifications[i].newLikeUserID}`);
                let newLikeVideo = await db.queryPG(`SELECT "thumbnailPath" FROM "videos" WHERE id = ${notifications[i].newLikeVideoID}`);
                notifications_array.push({
                    for_user_id: notifications[i].for_user_id,
                    type: notifications[i].type,
                    timestamp: notifications[i].timestamp,
                    newLikeVideoID: notifications[i].newLikeVideoID,
                    newLikeUserID: notifications[i].newLikeUserID,
                    newLikeUser: newLikeUserID[0].username,
                    picturePath: newLikeUserID[0].picturePath,
                    thumbnailPath: newLikeVideo[0].thumbnailPath
                });
            }else if(notifications[i].type == 2){
                var newCommentUser = await db.queryPG(`SELECT "username", "picturePath" FROM "users" WHERE id = ${notifications[i].newCommentUserID}`);
                var newCommentVideo = await db.queryPG(`SELECT "thumbnailPath" FROM "videos" WHERE id = ${notifications[i].newCommentVideoID}`);
                notifications_array.push({
                    for_user_id: notifications[i].for_user_id,
                    type: notifications[i].type,
                    timestamp: notifications[i].timestamp,
                    newCommentVideoID: notifications[i].newCommentVideoID,
                    newCommentUserID: notifications[i].newCommentUserID,
                    newCommentUser: newCommentUser[0].username,
                    picturePath: newCommentUser[0].picturePath,
                    thumbnailPath: newCommentVideo[0].thumbnailPath
                });
            }
        }
        sendResponse.success(res, notifications_array);
    },
    followNotification: async function(for_user_id, from_user_id) {
        let notification = new notificationModel({
            for_user_id: for_user_id,
            type: 0,
            timestamp: new Date(),
            newFollower: from_user_id
        });
        notification.save();
        return;
    },
    likeNotification: async function(for_user_id, video_id, from_user_id) {
        let notification = new notificationModel({
            for_user_id: for_user_id,
            type: 1,
            timestamp: new Date(),
            newLikeVideoID: video_id,
            newLikeUserID: from_user_id
        });
        notification.save();
        return;
    },
    commentNotification: async function(for_user_id, video_id, from_user_id) {
        let notification = new notificationModel({
            for_user_id: for_user_id,
            type: 2,
            timestamp: new Date(),
            newCommentVideoID: video_id,
            newCommentUserID: from_user_id
        });
        notification.save();
        return;
    }

}

module.exports = notificationService;
