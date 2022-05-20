const db = require('./db');
const sendResponse = require('../sendResponse');
const UserService = require('./userService');
const VideoService = require('./videoService');

let SearchService = {
    search: async function(req, res) {
        //Get the search term from the request
        var searchTerm = req.body.searchTerm;
        searchTerm = searchTerm.toLowerCase();
        //Get the user id from the request
        var user_id = await UserService.getUserIdFromTokenExport(req);
        //Get all videos that match the search term
        var videosTemp = await db.queryPG(`SELECT "id" FROM "videos" WHERE LOWER("descryption") LIKE '%${searchTerm}%' LIMIT 5`);
        var videos = [];
        for(var i = 0; i < videosTemp.length; i++){
            videos.push(await VideoService.getVideoExport(videosTemp[i].id, user_id, 5));
        }
        //Get all tags that match the search term
        var tags = await db.queryPG(`SELECT * FROM "tags" WHERE "tag" LIKE '%${searchTerm}%' LIMIT 5`);
        //Get all users that match the search term
        var users = await db.queryPG(`SELECT id, username, "picturePath" FROM "users" WHERE "username" LIKE '%${searchTerm}%' LIMIT 5`);
        //Send the search results
        sendResponse.success(res, {
            videos: videos,
            tags: tags,
            users: users
        });
    },
}

module.exports = SearchService;