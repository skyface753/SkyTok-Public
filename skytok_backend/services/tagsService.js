const db = require('./db');
const UserService = require('./userService');
const VideoService = require('./videoService');
const sendResponse = require('../sendResponse');

let TagService = {
    trending: async function(req, res) {
        var trendingTags = await db.queryPG(`SELECT tags.tag, tags.id, SUM("users_tags_XREF".worth) FROM "users_tags_XREF" 
        INNER JOIN tags ON tags.id = "users_tags_XREF".tag_id
        WHERE date >= CURRENT_DATE - INTERVAL '7 DAYS'
        GROUP BY tags.id, tags.tag
        ORDER BY SUM("users_tags_XREF".worth) DESC LIMIT 5`);
        sendResponse.success(res, trendingTags);
    },
    getVideos: async function(req, res) {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var tag_name = req.body.tag_name;
        if(!tag_name) {
            console.log("tag_name is not defined");
            sendResponse.error(res, "Tag Name is required");
            return;
        }
        tag_name = tag_name.toLowerCase();
        console.log("tag_name: " + tag_name);
        var tag_id = await db.queryPG(`SELECT id FROM tags WHERE tag = '${tag_name}'`);
        tag_id = tag_id[0].id;
        console.log("tag_id: " + tag_id);
        var videos = await db.queryPG(`SELECT "id", COUNT("videos_watched"."video_id") FROM "videos"
		INNER JOIN "videos_tags_XREF" ON "videos_tags_XREF"."video_id" = "videos"."id"
		LEFT JOIN "videos_watched" ON "videos_watched"."video_id" = "videos".id
        WHERE "videos_tags_XREF"."tag_id" = ${tag_id}
        GROUP by "id"
		ORDER BY count DESC`);
        var tagInfos = await db.queryPG(`SELECT COUNT("videos_watched"."video_id") FROM "videos"
		INNER JOIN "videos_tags_XREF" ON "videos_tags_XREF"."video_id" = "videos"."id"
		LEFT JOIN "videos_watched" ON "videos_watched"."video_id" = "videos".id
        WHERE "videos_tags_XREF"."tag_id" = ${tag_id}`);
        var videosToSend = [];
        for(var i = 0; i < videos.length; i++){
            videosToSend.push(await VideoService.getVideoExport(videos[i].id, user_id, 3));
        }
        sendResponse.success(res, {videoTags: videosToSend, viewCount: tagInfos[0].count});
    },
}


module.exports = TagService;