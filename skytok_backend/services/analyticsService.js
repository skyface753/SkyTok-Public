const db = require('./db.js');
const UserService = require('./userService.js');
const appTimeModel = require('../models/appTimeModel.js');

const sendResponse = require("../sendResponse");

let analyticsService = {
    getAll: async function (req, res) {
        let user_id = UserService.getUserIdFromTokenExport(req);
        let userCount = await db.queryPG(`SELECT COUNT(*) FROM users WHERE 1=1`);
        let countMale = await db.queryPG(`SELECT COUNT(*) FROM users WHERE gender = 0`);
        let countFemale = await db.queryPG(`SELECT COUNT(*) FROM users WHERE gender = 1`);
        let countDivers = await db.queryPG(`SELECT COUNT(*) FROM users WHERE gender = 2`);
        userCount = userCount[0].count
        countMale = countMale[0].count
        countFemale = countFemale[0].count
        countDivers = countDivers[0].count
        let percentMale = countMale / userCount;
        let percentFemale = countFemale / userCount;
        let percentDivers = countDivers / userCount;
        sendResponse.success(res, {
            userCount: userCount,
            countMale: countMale,
            countFemale: countFemale,
            countDivers: countDivers,
            percentMale: percentMale,
            percentFemale: percentFemale,
            percentDivers: percentDivers
        });
    },
    get: async function (req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let followersCount = await db.queryPG(`SELECT COUNT(*) FROM following WHERE "to_user_id" = ${user_id}`);
        let followersMaleCount = await db.queryPG(`SELECT COUNT(*) FROM following INNER JOIN "users" ON "users".id = "following"."from_user_id" WHERE "to_user_id" = ${user_id} AND "users"."gender" = 0`);
        let followersFemaleCount = await db.queryPG(`SELECT COUNT(*) FROM following INNER JOIN "users" ON "users".id = "following"."from_user_id" WHERE "to_user_id" = ${user_id} AND "users"."gender" = 1`);
        let followersDiversCount = await db.queryPG(`SELECT COUNT(*) FROM following INNER JOIN "users" ON "users".id = "following"."from_user_id" WHERE "to_user_id" = ${user_id} AND "users"."gender" = 2`);
        followersCount = followersCount[0].count
        followersMaleCount = followersMaleCount[0].count;
        followersFemaleCount = followersFemaleCount[0].count;
        followersDiversCount = followersDiversCount[0].count;
        let percentMale = followersMaleCount / followersCount;
        let percentFemale = followersFemaleCount / followersCount;
        let percentDivers = followersDiversCount / followersCount;
        let followerObj = {
            followersCount: followersCount,
            percentMale: percentMale,
            percentFemale: percentFemale,
            percentDivers: percentDivers
        }
        let appTime = await appTimeModel.find({ user_id: user_id }).exec();
        sendResponse.success(res, {followerObj: followerObj, appTime: appTime});

    },
    sendDuration: async function (req, res) {
        let user_id = await UserService.getUserIdFromTokenExport(req);
        let duration = req.body.duration;
        let start_time = req.body.start_time;
        let end_time = req.body.end_time;
        let pause_duration = req.body.pause_duration;
        appTimeModel.create({
            user_id: user_id,
            start_time: start_time,
            end_time: end_time,
            duration: duration,
            pause_duration: pause_duration
        }, function (err, result) {
            if (err) {
                console.log(err);
                res.send(err);
            } else {
                res.send(result);
            }
        });
    }

}

module.exports = analyticsService;