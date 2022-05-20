const db = require('./db');
const videoShareModel = require('../models/videosShares');
const UserService = require('./userService');

const sendResponse = require('../sendResponse.js');

const notificationService = require('./notificationService');

let VideoSerice = {
    forUser: async function(req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let for_user = req.body.for_user;
        let for_user_id = "";
        if(for_user == null || for_user == undefined || for_user == "" || for_user == "null"){
            for_user_id = user_id;
        }else{
            for_user_id = await db.queryPG(`SELECT id FROM users WHERE username = '${for_user}'`);
            if(for_user_id.length == 0){
                sendResponse.error(res, "User does not exist");
                return;
            }
            for_user_id = for_user_id[0].id;
        }
        console.log("For User ID: " + for_user_id);
        let videoIDs = await db.queryPG(`SELECT videos.id FROM videos WHERE user_id = ${for_user_id}`);
        
        var videos = [];
        for(var i = 0; i < videoIDs.length; i++){
            videos.push(await getVideo(videoIDs[i].id, user_id, 3));
        }
        sendResponse.success(res, videos);
    },
    proposals: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        console.log("User ID: " + user_id);
        if(!user_id){
            sendResponse.error(res, "User not logged in");
            return;
        }
        var user_language = await db.queryPG(`SELECT "language_id" FROM users WHERE id = ${user_id}`);
        user_language = user_language[0].language_id;
        console.log("User Language: " + user_language);
        var returnCount = 10;
        var averages = await getAverages(user_id, returnCount);
        console.log("Averages: " + JSON.stringify(averages));
        let videoFromTags = await db.queryPG(`SELECT "videos_tags_XREF".video_id as video_id 
        FROM "users_tags_XREF" 
        INNER JOIN "videos_tags_XREF" ON "videos_tags_XREF".tag_id = "users_tags_XREF".tag_id 
        INNER JOIN "videos" ON "videos_tags_XREF".video_id = videos.id
        INNER JOIN "users" ON videos."user_id" = "users".id
        LEFT JOIN "videos_watched" ON "videos_watched".video_id = "videos_tags_XREF".video_id 
        WHERE "videos_watched".video_id IS NULL AND "users_tags_XREF".user_id = ${user_id} 
            AND ("users"."language_id" = ${user_language} OR "users"."language_id" = 1)
            AND "videos"."privacy_id" = 0
        GROUP BY "videos_tags_XREF".video_id
        ORDER BY SUM(worth) DESC LIMIT ${averages.averageTags}`);
        // console.log("From Tags");
        // console.log(videoFromTags);
        let videoFromFollowing = await db.queryPG(`SELECT videos.id FROM videos INNER JOIN users ON users.id = videos.user_id INNER JOIN "following" ON "following"."to_user_id" = users.id
        LEFT JOIN "videos_watched" ON "videos_watched"."video_id" = videos.id
        WHERE "following"."from_user_id" = ${user_id} AND "videos_watched"."video_id" IS NULL
        GROUP BY videos.id LIMIT ${averages.averageFollowing}`);
        // console.log("Following before:");
        // console.log(videoFromFollowing);
        // Check if video is already in array
        for(var i = 0; i < videoFromFollowing.length; i++){
            // var found = false;
            for(var j = 0; j < videoFromTags.length; j++){
                if(videoFromTags[j].video_id == videoFromFollowing[i].id){
                    videoFromFollowing.splice(i, 1);
                    break;
                }
            }
        }
        // console.log("Following:");
        // console.log(videoFromFollowing);
        var trendtinVids = await getTrendingVideos(user_id, averages.averageTrends);
        trendtinVids = trendtinVids["videoTrendIds"];
        // console.log("Trending:");
        // console.log(trendtinVids);
        for(var i = 0; i < trendtinVids.length; i++){
            for(var j = 0; j < videoFromFollowing.length; j++){
                if(videoFromFollowing[j].id == trendtinVids[i]){
                    videoFromFollowing.splice(j, 1);
                    break;
                }
            }
            for(var j = 0; j < videoFromTags.length; j++){
                if(videoFromTags[j].video_id == trendtinVids[i].id){
                    trendtinVids.splice(i, 1);
                    break;
                }
            }
        }
        var videos = [];
        for(var i = 0; i < videoFromTags.length; i++){
            videos.push(await getVideo(videoFromTags[i].video_id, user_id, 0));
        }
        for(var i = 0; i < videoFromFollowing.length; i++){
            videos.push(await getVideo(videoFromFollowing[i].id, user_id, 1));
        }
        for(var i = 0; i < trendtinVids.length; i++){
            videos.push(await getVideo(trendtinVids[i].id, user_id, 2));
        }

        sendResponse.success(res, videos);
    },
    watched: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        let video_id = req.body.video_id;
        let length = req.body.length;
        if(video_id == null || length == null){
            sendResponse.error(res, "Missing video_id or length");
            return;
        }
        if(!user_id){
            sendResponse.error(res, "User not logged in");
            return;
        }
        if(!await checkIfVideoExists(video_id)){
            sendResponse.error(res, "Video does not exist");
            return;
        }
        await db.queryPG(`UPDATE "videos" SET "views" = "views" + 1 WHERE id = ${video_id}`);
        var alreadyWatched = await db.queryPG(`SELECT * FROM "videos_watched" WHERE video_id = ${video_id} AND user_id = ${user_id}`);
        if(alreadyWatched.length > 0){
            sendResponse.success(res, "Video already watched");
            return;
        }
        await db.queryPG(`INSERT INTO "videos_watched" (video_id, user_id, length) VALUES (${video_id}, ${user_id}, ${length})`);
        sendResponse.success(res, "Video watched");
    },
    liked: async function(req, res) {
        let video_id = req.body.video_id;
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var suggestionType = req.body.suggestionType;
        if(!user_id || !video_id || !suggestionType){
            sendResponse.error(res, "Missing video_id or user_id or suggestionType");
            return;
        }
        if(!await checkIfVideoExists(video_id)){
            sendResponse.error(res, "Video does not exist");
            return;
        }
        let alreadyLiked = await db.queryPG(`SELECT * FROM "videos_liked" WHERE video_id = ${video_id} AND user_id = ${user_id}`);
        // console.log(alreadyLiked);
        if(alreadyLiked.length > 0){
            sendResponse.error(res, "Video already liked");
            return;
        }
        
        updateTagWorth(video_id, user_id, 10);

        await db.queryPG(`INSERT INTO "videos_liked" (video_id, user_id, timestamp) VALUES (${video_id}, ${user_id}, CURRENT_TIMESTAMP)`);
        sendResponse.success(res, "Video liked");
        var for_user_id = await db.queryPG(`SELECT user_id FROM "videos" WHERE id = ${video_id}`);
        notificationService.likeNotification(for_user_id[0].user_id, video_id, user_id);
        insertSuggestionType(user_id, video_id, suggestionType);
    },
    getLiked: async function(req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let for_user_name = req.body.for_user_name;
        if(!user_id){
            sendResponse.error(res, "User not logged in");
            return;
        }
        var for_user_id = "";
        if(for_user_name == null || for_user_name == undefined || for_user_name == "" || for_user_name == "null"){
            for_user_id = user_id;
        }else{
            for_user_id = await db.queryPG(`SELECT id FROM users WHERE username = '${for_user_name}'`);
            if(for_user_id.length == 0){
                sendResponse.error(res, "User does not exist");
                return;
            }
            for_user_id = for_user_id[0].id;
        }
        console.log("User ID: " + for_user_id);
        // user_id = 8;
        let likedVideos = await db.queryPG(`SELECT "videos_liked".video_id as video_id FROM "videos_liked" WHERE "videos_liked".user_id = ${for_user_id} ORDER BY "videos_liked".timestamp DESC`);
        var videos = [];
        for(var i = 0; i < likedVideos.length; i++){
            videos.push(await getVideo(likedVideos[i].video_id, user_id, 3));
        }
        sendResponse.success(res, videos);
    },
    unliked: async function(req, res) {
        let video_id = req.body.video_id;
        var user_id = await UserService.getUserIdFromTokenExport(req);
        if(!user_id || !video_id){
            sendResponse.error(res, "Missing video_id or user_id");
            return;
        }
        if(!await checkIfVideoExists(video_id)){
            sendResponse.error(res, "Video does not exist");
            return;
        }
        let alreadyLiked = await db.queryPG(`SELECT * FROM "videos_liked" WHERE video_id = ${video_id} AND user_id = ${user_id}`);
        if(alreadyLiked.length == 0){
            sendResponse.error(res, "Video not liked");
            return;
        }
        updateTagWorth(video_id, user_id, -10);
        await db.queryPG(`DELETE FROM "videos_liked" WHERE video_id = ${video_id} AND user_id = ${user_id}`);
        sendResponse.success(res, "Video unliked");
    },
    share: async function(req, res) {
        var video_id = req.body.video_id;
        var suggestion_type = req.body.suggestion_type;
        if(!video_id || !suggestion_type){
            sendResponse.error(res, "Missing video_id or suggestion_type");
            return;
        }
        if(!await checkIfVideoExists(video_id)){
            sendResponse.error(res, "Video does not exist");
            return;
        }
        var date = new Date();
        await db.queryPG(`UPDATE "videos" SET "shares" = "shares" + 1 WHERE id = ${video_id}`);
        videoShareModel.create({
            video_id: video_id,
            dateTime: date
        }, function (err, videoShare) {
            if (err) return res.status(500);
            sendResponse.success(res, "Video shared");
        }
        );
        sendResponse.success(res, "Video shared");
        insertSuggestionType(user_id, video_id, suggestion_type);

    },
    allTrending: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        sendResponse.success(res, await getTrendingVideos(user_id, 0));
    },
    tenTrending: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        sendResponse.success(res, await getTrendingVideos(user_id));
    },
    getVideoExport: async function (video_id, user_id, suggestionType){
        return await getVideo(video_id, user_id, suggestionType);
    },
    checkIfVideoExistsExport: async function (video_id){
        return await checkIfVideoExists(video_id);
    },
    insertSuggestionTypeExport: async function (user_id, video_id, suggestionType){
        insertSuggestionType(user_id, video_id, suggestionType);
    },
}

async function getAverages(user_id, returnCount){
    calculateAverages(user_id);
    var averagesFromUser = await db.queryPG(`SELECT "averageTags", "averageFollowing", "averageTrends" FROM "users" WHERE id = ${user_id}`);
        var averages = {
            averageTags: Math.round(returnCount * averagesFromUser[0].averageTags),
            averageFollowing: Math.round(returnCount * averagesFromUser[0].averageFollowing),
            averageTrends: Math.round(returnCount * averagesFromUser[0].averageTrends)
        };
        return averages;
}
const suggestionTypesModel = require("../models/suggestionTypes");

async function insertSuggestionType(user_id, video_id, type){
    suggestionTypesModel.create({
        user_id: user_id,
        video_id: video_id,
        suggestion_type: type
    }, function (err, userInteractionType) {
        if (err) return console.error(err);
    }
    );
}

async function calculateAverages(user_id){
    var countSuggestionssByUser = await suggestionTypesModel.find({user_id: user_id}).count().exec();
    if(countSuggestionssByUser == 0){
        await db.queryPG(`UPDATE "users" SET "averageTags" = 0.33, "averageFollowing" = 0.33, "averageTrends" = 0.33 WHERE id = ${user_id}`);
        return;
    }
    var countSuggestionType0 = await suggestionTypesModel.find({user_id: user_id, suggestion_type: 0}).count().exec();
    var countSuggestionType1 = await suggestionTypesModel.find({user_id: user_id, suggestion_type: 1}).count().exec();
    var countSuggestionType2 = await suggestionTypesModel.find({user_id: user_id, suggestion_type: 2}).count().exec();
    var percentType0 = countSuggestionType0 / countSuggestionssByUser;
    var percentType1 = countSuggestionType1 / countSuggestionssByUser;
    var percentType2 = countSuggestionType2 / countSuggestionssByUser;
    console.log("Percent Types: " + percentType0 + " " + percentType1 + " " + percentType2);
    if(percentType0 < 0.1){
        percentType0 = 0.1;
    }
    if(percentType1 < 0.1){
        percentType1 = 0.1;
    }
    if(percentType2 < 0.1){
        percentType2 = 0.1;
    }
    if(percentType0 > 0.8){
        percentType0 = 0.8; 
    }
    if(percentType1 > 0.8){
        percentType1 = 0.8;
    }
    if(percentType2 > 0.8){
        percentType2 = 0.8;
    }
    await db.queryPG(`UPDATE "users" SET "averageTags" = ${percentType0}, "averageFollowing" = ${percentType1}, "averageTrends" = ${percentType2} WHERE id = ${user_id}`);
    return;
}

async function getVideo(video_id, user_id, suggestionType){
    console.log("Video ID: " + video_id);
    // var video = await db.queryPG(`SELECT videos.id, videos.path, videos.length, user_id, videos.descryption, users.username, videos.shares FROM videos INNER JOIN users ON users.id = videos.user_id WHERE videos.id = ${video_id}`);
    var video = await db.queryPG(`SELECT "videos"."privacy_id", users."picturePath", videos.id, videos.path, videos.length, videos.user_id, videos.descryption, users.username, videos.shares, videos."thumbnailPath", COUNT(comments.id) as "commentCount" 
    FROM videos 
    INNER JOIN users ON users.id = videos.user_id 
    LEFT JOIN comments ON comments.video_id = videos.id
    WHERE videos.id = ${video_id}
    GROUP BY videos.id, users.id`)
    var watchedCount = await db.queryPG(`SELECT COUNT(*) FROM "videos_watched" WHERE video_id = ${video_id}`);
    var likeCount = await db.queryPG(`SELECT * FROM public.video_likes_view
    WHERE id = ${video_id}`);
    var userLikedTheVideo = await db.queryPG(`SELECT * FROM "videos_liked" WHERE video_id = ${video_id} AND user_id = ${user_id}`);
    var userFollowing = await db.queryPG(`SELECT * FROM "following" WHERE "from_user_id" = ${user_id} AND "to_user_id" = ${video[0].user_id}`);
    if(userFollowing.length == 0){
        userFollowing = false;
    }else{
        userFollowing = true;
    }
    if(userLikedTheVideo.length > 0){
        userLikedTheVideo = true;
    } else {
        userLikedTheVideo = false;
    }
    if(suggestionType == null){
        suggestionType = 3;
    }
    return{
        id: parseInt(video[0].id),
        // path: video[0].path,
        length: video[0].length,
        user_id: parseInt(video[0].user_id),
        descryption: video[0].descryption,
        username: video[0].username,
        shares: video[0].shares,
        commentCount: parseInt(video[0].commentCount),
        thumbnailPath: video[0].thumbnailPath,
        likeCount: parseInt(likeCount[0].count),
        userLikedTheVideo: userLikedTheVideo,
        userPicturePath: video[0].picturePath,
        watchedCount: parseInt(watchedCount[0].count),
        userFollowing: userFollowing,
        type: suggestionType,
        privacy_id: parseInt(video[0].privacy_id)
    };
}

async function getTrendingVideos(user_id, limitation){
    if(limitation == null){
        limitation = 10;
    }
    var cutoff = new Date();
    cutoff.setDate(cutoff.getDate()-2);
    // cutoff to Timestamp with timezone
    cutoff = cutoff.toISOString();
    // Order by _key count
    //TODO: Change for working
    var videosLikes = await db.queryPG(`SELECT video_id, COUNT(video_id) as "likeCount" FROM "videos_liked" WHERE timestamp >= current_timestamp - interval '3 day' GROUP BY video_id ORDER BY "likeCount" DESC`);

    var cutOffIds = [];
    for(var i = 0; i < videosLikes.length; i++){
        var currentObj = {
            id: videosLikes[i].video_id,
            count: videosLikes[i].likeCount
        }
        cutOffIds.push(currentObj);
    }
    var videosShares = await videoShareModel.aggregate([
        {
            $match: {
                dateTime: {
                    $gte: cutoff
                }
            }
        },
        {
            $group: {
                _id: "$video_id",
                count: { $sum: 1 }
            }
        },
        {
            $sort: {
                count: -1
            }
        }
    ]).exec();
    for(var i = 0; i < videosShares.length; i++){
        var currentObj = {
            id: videosShares[i]._id,
            count: videosShares[i].count
        }
        cutOffIds.push(currentObj);
    }
    cutOffIds.sort( compareCutOffIds );
    // Dont shift if 0, just shift if null or number
    if(limitation != 0){
        while(cutOffIds.length > limitation){
            cutOffIds.shift();
        }
    }
    // var videos = [];
    // for(var i = 0; i < cutOffIds.length; i++){
    //     videos.push(await getVideo(cutOffIds[i].id, user_id));
    // }
    // console.log(videos);
    return {
        // videos: videos,
        videoTrendIds: cutOffIds
    };
}

function compareCutOffIds( a, b ) {
    if ( a.count < b.count ){
      return 1;
    }
    if ( a.count > b.count ){
      return -1;
    }
    return 0;
  }

async function checkIfVideoExists(video_id){
    var videoExists = await db.queryPG(`SELECT * FROM videos WHERE id = ${video_id}`);
    if(videoExists.length == 0){
        return false;
    }
    return true;
}
    
async function updateTagWorth(video_id, user_id, worth){
    var tagIDs = await db.queryPG(`SELECT * FROM "videos_tags_XREF" WHERE video_id = ${video_id}`);
    if(tagIDs == null){
        return;
    }
    var tagCount = tagIDs.length;
    for(var i=0; i < tagIDs.length; i++){
        var tagID = tagIDs[i].tag_id;
        await db.queryPG(`INSERT INTO "users_tags_XREF" (user_id, tag_id, worth, date, time) VALUES (${user_id}, ${tagID}, ${worth}, current_date, current_time)`);
    }
}


module.exports = VideoSerice;

