const db = require('./db');
const VideoService = require('./videoService');
const UserService = require('./userService');

const sendResponse = require('../sendResponse.js');
const notificationService = require('./notificationService');
let CommentService = {
    create: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var video_id = req.body.video_id;
        var comment = req.body.comment;
        var suggestion_type = req.body.suggestion_type;
        if(video_id == null || comment == null || user_id == null || suggestion_type == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(!await checkIfCommentsEnabled(video_id)){
            sendResponse.error(res, "Comments are disabled");
            return;
        }
        let comment_id = await db.queryPG(`INSERT INTO "comments" (video_id, user_id, comment) VALUES (${video_id}, ${user_id}, '${comment}') RETURNING id`);
        sendResponse.success(res, comment_id);
        var for_user_id = await db.queryPG(`SELECT user_id FROM videos WHERE id = ${video_id}`);
        notificationService.commentNotification(for_user_id[0].user_id, video_id, user_id);
        VideoService.insertSuggestionTypeExport(user_id, video_id, suggestion_type);
    },
    getbyVideoId: async function(req, res) {
        var video_id = req.body.video_id;
        var user_id = await UserService.getUserIdFromTokenExport(req);
        if(video_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(!await checkIfVideoExists(video_id)){
            sendResponse.error(res, "Video does not exist");
            return;
        }
        let comments = await db.queryPG(`SELECT "comments".id, "comments"."video_id", "comments"."user_id", "comments"."timestamp", 
                "comments"."comment", "users"."username", COUNT("comments_liked"."comment_id") as "likeCount"
            FROM "comments" INNER JOIN "users" ON "comments"."user_id" = "users".id 
            LEFT JOIN "comments_liked" ON "comments_liked"."comment_id" = "comments".id 
            WHERE video_id = ${video_id}
            GROUP BY "comments".id, "users".username
            ORDER BY "likeCount" DESC`);
        for(var i = 0; i < comments.length; i++){
            comments[i].liked = await checkIfCommentLiked(comments[i].id, user_id);
        }
        sendResponse.success(res, comments);
    },
    liked: async function(req, res) {
        var comment_id = req.body.comment_id;
        var user_id = await UserService.getUserIdFromTokenExport(req);
        if(comment_id == null || user_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(!await checkIfCommentExists(comment_id)){
            sendResponse.error(res, "Comment does not exist");
            return;
        }
        if(!await checkIfCommentLiked(comment_id, user_id)){
            await db.queryPG(`INSERT INTO "comments_liked" (comment_id, user_id) VALUES (${comment_id}, ${user_id})`);
            sendResponse.success(res, "Liked");
        } else {
            sendResponse.error(res, "Already liked");
        }
    },
    unliked: async function(req, res) {
        var comment_id = req.body.comment_id;
        var user_id = await UserService.getUserIdFromTokenExport(req);
        if(comment_id == null || user_id == null){
            sendResponse.error(res, "Invalid parameters");
            return;
        }
        if(!await checkIfCommentExists(comment_id)){
            sendResponse.error(res, "Comment does not exist");
            return;
        }
        if(await checkIfCommentLiked(comment_id, user_id)){
            await db.queryPG(`DELETE FROM "comments_liked" WHERE comment_id = ${comment_id} AND user_id = ${user_id}`);
            sendResponse.success(res, "Unliked");
        } else {
            sendResponse.error(res, "Not liked");
        }
    }
}

async function checkIfCommentsEnabled (video_id){
    let enableComments = await db.queryPG(`SELECT "enableComments" FROM "videos" WHERE id = ${video_id}`);
    if(enableComments.length == 0){
        return false;
    }
    if(enableComments[0].enableComments == false){
        return false;
    }
    return true;
}

async function checkIfVideoExists (video_id){
    var videoExists = await db.queryPG(`SELECT id FROM videos WHERE id = ${video_id}`);
    if(videoExists.length == 0){
        return false;
    }
    return true;
}

async function checkIfCommentExists (comment_id){
    var commentExists = await db.queryPG(`SELECT id FROM comments WHERE id = ${comment_id}`);
    if(commentExists.length == 0){
        return false;
    }
    return true;
}

async function checkIfCommentLiked (comment_id, user_id){
    var commentLiked = await db.queryPG(`SELECT comment_id FROM comments_liked WHERE comment_id = ${comment_id} AND user_id = ${user_id}`);
    if(commentLiked.length == 0){
        return false;
    }
    return true;
}

module.exports = CommentService;

/*
SELECT "comments".id, "comments"."video_id", "comments"."user_id", "comments"."timestamp", 
	"comments"."comment", COUNT("comments_liked"."comment_id")
FROM "comments" INNER JOIN "users" ON "comments"."user_id" = "users".id 
LEFT JOIN "comments_liked" ON "comments_liked"."comment_id" = "comments".id 
WHERE video_id = 33246
GROUP BY "comments".id
ORDER BY "comments"."timestamp" DESC

SELECT "comments".id, "comments"."video_id", "comments"."user_id", "comments"."timestamp", 
	"comments"."comment", "users"."username", COUNT("comments_liked"."comment_id")
FROM "comments" INNER JOIN "users" ON "comments"."user_id" = "users".id 
LEFT JOIN "comments_liked" ON "comments_liked"."comment_id" = "comments".id 
WHERE video_id = 33246
GROUP BY "comments".id, "users".username
ORDER BY "comments"."timestamp" DESC*/

