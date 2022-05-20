const db = require('./db.js')
const UserService = require('./userService.js')

const sendResponse = require('../sendResponse.js')

const notificationService = require('./notificationService.js')

let followerService = {
    getMyFollowers: async function (req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let followers = await db.queryPG(`SELECT "from_user_id" FROM following WHERE "to_user_id" = ${user_id}`);
        let users = await db.queryPG(`SELECT id, username, "picturePath" FROM users WHERE id IN (${followers.map(follower => follower.from_user_id).join(',')})`);
        sendResponse.success(res, users);
    },
    getMyFollowing: async function (req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let following = await db.queryPG(`SELECT "to_user_id" FROM following WHERE from_user_id = ${user_id}`);
        var users = await db.queryPG(`SELECT id, username, "picturePath" FROM "users" WHERE id IN (${following.map(x => x.to_user_id).join(',')})`);
        // let following_users = [];
        // for (var i = 0; i < following.length; i++) {
        //     following_users.push(await db.queryPG(`SELECT id, username, "picturePath" FROM users WHERE id = ${following[i].to_user_id}`));
        // }
        sendResponse.success(res, users);
    },
    newFollowing: async function (req, res) {
        let from_user_id = await UserService.getUserIdFromTokenExport(req);
        let to_user_id = req.body.to_user_id;
        if(from_user_id == to_user_id) {
            sendResponse.error(res, "You can't follow yourself");
            return;
        }
        let result = await db.queryPG(`INSERT INTO following (from_user_id, to_user_id) VALUES (${from_user_id}, ${to_user_id})`);
        sendResponse.success(res, result);
        notificationService.followNotification(to_user_id, from_user_id);
    },
    deleteFollowing: async function (req, res) {
        let from_user_id = await UserService.getUserIdFromTokenExport(req);
        let to_user_id = req.body.to_user_id;
        let result = await db.queryPG(`DELETE FROM following WHERE from_user_id = ${from_user_id} AND to_user_id = ${to_user_id}`);
        sendResponse.success(res, result);
    },
    followerSuggestions: async function (req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let friends = await db.queryPG(`SELECT "from_user_id" FROM following WHERE from_user_id IN (SELECT "to_user_id" FROM following WHERE from_user_id = ${user_id}) AND to_user_id = ${user_id}`);
        let friendFromFriend = [];
        for (var i = 0; i < friends.length; i++) {
            let currentFriend = friends[i].from_user_id;
            var currFriendFromFriend = await db.queryPG(`SELECT "to_user_id" FROM following WHERE "from_user_id" = ${currentFriend} AND "to_user_id" != ${user_id}`);
            for (var j = 0; j < currFriendFromFriend.length; j++) {
                var alreadyFollowing = await db.queryPG(`SELECT * FROM following WHERE from_user_id = ${user_id} AND to_user_id = ${currFriendFromFriend[j].to_user_id}`);
                if (alreadyFollowing.length == 0) {
                    var isAlreadyIn = false;
                    // Check if the user is already in the array
                    for (var k = 0; k < friendFromFriend.length; k++) {
                        if (friendFromFriend[k].to_user_id == currFriendFromFriend[j].to_user_id) {
                            friendFromFriend[k].counter++;
                            isAlreadyIn = true;
                            break;
                        }
                    }
                    if(!isAlreadyIn) {
                        friendFromFriend.push({to_user_id: currFriendFromFriend[j].to_user_id, counter: 1});
                    }
                }
            }

        }
        //Sort friends from friend by counter
        friendFromFriend.sort((a, b) => {
            return b.counter - a.counter;
        });
        var users = [];
        for (var i = 0; i < friendFromFriend.length; i++) {
            users.push((await db.queryPG(`SELECT id, username, "picturePath" FROM users WHERE id = ${friendFromFriend[i].to_user_id}`))[0]);
        }
        // res.send(users);
        sendResponse.success(res, users);

    }

}

module.exports = followerService;

