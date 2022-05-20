// const users = require('../models/users.js');
// const userTagsService = require('./userTagsService.js');
const createClient = require('redis').createClient;
const db = require('./db.js');
const jwt = require("jsonwebtoken");
const bcrypt = require('bcrypt');
// jwt 30 Tage
const jwtExpirySeconds = 60 * 60 * 24 * 30;
const jwtKey = "SkyTokSecretKey!fqiwhdhuwqhdf2uhf2zgu";
const saltRounds = 11;
var os = require("os");
var hostname = os.hostname();
const console = require('../helpers/log');
const config = require('../config.js');


const sendResponse = require('../sendResponse.js');


const client = createClient({
    url: 'redis://@' + config.redis.host + ':6379'
});

client.on('error', (err) => console.log('Redis Client Error', err));


async function initRedis(){    
    await client.connect();
    // await client.set('key', 'TestBlablabla');
    // const value = await client
    if(process.env.MODE == "TEST"){
        console.log("WARNING: Redis is running in TEST mode! - TOKEN for user 1 is setted!");
        await client.set('1', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImlhdCI6MTY0NjI0Njk1OSwiZXhwIjoxNjQ4ODM4OTU5fQ.4_81XxmUJlum6HuD3qCAa6b46mcvjo7EhE2Dh12dRog');
    }
}

initRedis();

let UserService = {
    register: async function(req, res){
        let username = req.body.username;
        let password = req.body.password;
        let mail = req.body.mail;
        let firstname = req.body.firstname;
        let lastname = req.body.lastname;
        let threeTags = req.body.threeTags;
        let language = req.body.language;
        if(!username || !password || !mail || !firstname || !lastname || !threeTags || !language){
            console.log(`Username ${username} or password ${password} or mail ${mail} or firstname ${firstname} or lastname ${lastname} or threeTags ${threeTags} or language ${language} is missing!`);
            sendResponse.error(res, "Missing parameters!");
            return;
        }
        let userExists = await db.queryPG(`SELECT * FROM "users" WHERE username = '${username}' OR mail = '${mail}'`);
        if(userExists.length > 0){
            sendResponse.error(res, "User already exists!");
            return;
        }
        let hashedPassword = await bcrypt.hash(password, saltRounds);
        let user = await db.queryPG(`INSERT INTO "users" (username, password, mail, firstname, lastname, language_id) VALUES ('${username}', '${hashedPassword}', '${mail}', '${firstname}', '${lastname}', '${language}') RETURNING *`);
        threeTags = JSON.parse(threeTags);
        for(let i = 0; i < threeTags.length; i++){
            let tag = threeTags[i];
            await db.queryPG(`INSERT INTO "users_tags_XREF" (user_id, tag_id, worth, date, time) VALUES (${user[0].id}, ${tag}, 10, CURRENT_DATE, CURRENT_TIME)`);
        }
        sendResponse.success(res, user[0]);
    },


    login: async function(req, res){
        var usernameOrEmail = req.body.usernameOrEmail;
        var password = req.body.password;
        if(!usernameOrEmail || !password){
            sendResponse.error(res, "Username or password is missing!");
            return;
        }
        var user = await db.queryPG(`SELECT * FROM "users" WHERE username = '${usernameOrEmail}' OR mail = '${usernameOrEmail}'`);
        if(user == null){
            sendResponse.error(res, "User not found!");
            return;
        }
        var user = user[0];
        if(user.isActive == false){
            sendResponse.error(res, "User is not active!");
            return;
        }
        var passwordHash = user.password;
        bcrypt.compare(password, passwordHash, function(err, result) {
            if(result){
                var jwtToken = signToken(user.id);
                sendResponse.success(res, {
                    token: jwtToken,
                    username: user.username,
                    mail: user.mail,
                    userId: user.id,
                })
            }else{
                // console.log("HASH: " + bcrypt.hashSync(password, saltRounds));
                sendResponse.error(res, "Wrong password!");
            }
        });
    },
    isLoggedIn: async function(req, res){
        if(await verifyToken(req)){
            console.log("User is logged in");
            return true;
        }else{
            console.log("User is not logged in");
            return false;
        }
    },
    getUserIdFromTokenExport: async function(req){
        var user_id = await getUserIdFromToken(req);
        if(user_id){
            return user_id;
        }else{
            return null;
        }
    },
    logout: async function(req, res){
        var user_id = getUserIdFromToken(req);
        if(user_id){
            client.del(user_id);
            sendResponse.success(res, "User logged out!");
        }else{
            sendResponse.error(res, "User is not logged in!");
        }
    },
    status: async function(req, res){
        if(await verifyToken(req)){
            var user_id = await getUserIdFromToken(req);
            var username = await db.queryPG(`SELECT username FROM "users" WHERE id = ${user_id}`);
            sendResponse.success(res, {
                username: username[0].username,
                user_id: user_id,
            });
        }else{
            sendResponse.error(res, "User is not logged in!");
        }
    },
    info: async function(req, res){
        var user_id = await getUserIdFromToken(req);
        var for_user_name = req.body.for_user_name;
        // var for_user_id = "";
        var user;
        var userFollowing = false;
        if(!for_user_name || for_user_name == ""){
            var for_user_id = user_id;
            var user = await db.queryPG(`SELECT id, username, "biography", "picturePath" FROM "users" WHERE id = ${for_user_id}`);
            userFollowing = null;
        }else{
            var user = await db.queryPG(`SELECT id, username, "biography", "picturePath" FROM "users" WHERE username = '${for_user_name}'`);
            // console.log("From: " + user_id + " To: " + user[0].id);
            var userFollowing = await db.queryPG(`SELECT * FROM "following" WHERE "from_user_id" = ${user_id} AND "to_user_id" = ${user[0].id}`);
            if(userFollowing.length == 0){
                userFollowing = false;
            }else{
                userFollowing = true;
            }
        }
        user[0].userFollowing = userFollowing;
        var currUserId = user[0].id;
        let followers = await db.queryPG(`SELECT "from_user_id", users.username, "picturePath" FROM following INNER JOIN users ON users.id = "from_user_id" WHERE "to_user_id" = ${currUserId}`);
        let followersObj ={
            count: followers.length,
            followers: followers
        }
        let following = await db.queryPG(`SELECT "to_user_id", users.username, "picturePath" FROM following INNER JOIN users ON users.id = "to_user_id" WHERE from_user_id = ${currUserId}`);
        let followingObj = {
            count: following.length,
            following: following
        }
        let likeCount = await db.queryPG(`SELECT COUNT("videos_liked"."video_id") FROM "videos_liked" INNER JOIN videos ON videos.id = "videos_liked"."video_id" WHERE "videos"."user_id" = ${currUserId}`);
        let isLive = await checkIfUserIsLive(currUserId);
        let returnObj = {
            user: user[0],
            followers: followersObj,
            following: followingObj,
            likeCountUser: likeCount[0].count,
            isLive: isLive,
            // userFollowing: userFollowing,
        }
        sendResponse.success(res, returnObj); 
    }
}

function getUserIdFromToken (req){
    var token = getToken(req);
    if(!token){
        return false;
    }
    var payload;
    try{
        payload = jwt.verify(token, jwtKey);
    }catch (e){
        return false;
    }
    var userId = payload.user_id;
    return userId;
}


function getToken(req){
    var token = req.headers.authorization;
    if(!token){
        if(req.cookies.token){
            token = req.cookies.token;
        }else{
            return false;
        }
    }
    // console.log("Token: " + token);
    return token;
}

function signToken(user_id){
    
    const token = jwt.sign({ user_id }, jwtKey, {
        algorithm: "HS256",
        expiresIn: jwtExpirySeconds
    });
    client.set(user_id, token);
    return token;
}

async function verifyToken(req){
    var token = getToken(req);
    if(!token){
        return false;
    }
    var payload;
    try{
        payload = jwt.verify(token, jwtKey);
    }catch (e){
        return false;
    }
    var userId = payload.user_id;
    var tokenFromRedis = await client.get(userId);
    console.log("Token from redis: " + tokenFromRedis);
    console.log("Token from request: " + token);
    if(token != tokenFromRedis){
        return false;
    }else{
        return true;
    }
 }

async function checkIfUserIsLive (user_id){
    let userLive = await db.queryPG(`SELECT * FROM users_live WHERE user_id = ${user_id}`);
    if(userLive == null){
        return false;
    }
    if(userLive.length > 0){
        return true;
    }else{
        return false;
    }
 }

module.exports = UserService;