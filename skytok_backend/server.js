const http = require('http');
const express = require('express');
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const config = require('./config.js');
const db = require('./services/db.js');
const mongoose = require('mongoose');
const multer=require('multer');
const path= require('path');
const { getVideoDurationInSeconds } = require('get-video-duration')
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const port = 80;
require('dotenv').config()
var app = express();
// const console = require('./helpers/log');
const genThumbnail = require('simple-thumbnail')
const ffmpegPath = require('ffmpeg-static')
const nms = require('./nms.js');
nms.run();

app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(cookieParser());

app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

var cors = require('cors');

app.use(cors());

app.use(function (req, res, next) {
    // Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', '*');
    // Request methods you wish to allow
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    // Request headers you wish to allow
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type,Authorization');
    // Set to true if you need the website to include cookies in the requests sent
    // to the API (e.g. in case you use sessions)
    res.setHeader('Access-Control-Allow-Credentials', true);
    // Pass to next layer of middleware
    next();
});



var uri = "mongodb://" + config.mongodb.host + ":27017/skytok";

mongoose.connect(uri, { useUnifiedTopology: true, useNewUrlParser: true });

const connection = mongoose.connection;

connection.once("open", function() {
  console.log("MongoDB database connection established successfully");
});


// Login before isLoggedin Middleware
const UserService = require('./services/userService.js');
app.post('/login', UserService.login);


const infoService = require('./services/infoService.js');
// Middleware to check if user is logged in
app.use(async function (req, res, next) {
    console.log(req.protocol + '://' + req.get('host') + req.originalUrl);
    infoService.send(req, res);
  
    if(process.env.MODE == "TEST")
    {
        next();
    } else {
    if(await UserService.isLoggedIn(req, res)){
      console.log("User is logged in");
        next();
    }else{
      console.log("User is not logged in");
        res.status(401);
        res.send("Auth Expired").end();
    }
    }
});


const routes = require('./routes');
app.use('/', routes);


//Start Profile Picture Upload
app.use('/profilePictures', express.static(__dirname +'/profilePictures'));





app.post('/users/profile/picture', multer().single('uploadProfilePicture'), async(req, res, next) => {
  console.log("Uploading Profile Picture");
  
  var user_id = await UserService.getUserIdFromTokenExport(req);
  
  if(!req.file){res.status(400).send('Bad Request: No file was uploaded');return;}
  const s3 = Connect();
  var user_id = await UserService.getUserIdFromTokenExport(req);
  timestamp = (new Date().toISOString()).replaceAll("-", "").replaceAll(":", "").replaceAll(".", "").replaceAll("T", "_").replaceAll("Z", "");
  const path = "profilepics/" + user_id + "_" + timestamp + "." + req.file.originalname.split(".")[1]
  const params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: path,
    Body: req.file.buffer,
    ContentType: req.file.mimetype,
    ACL: 'public-read'
  };
  
  s3.upload(params, async function(err, data) {
    if (err) {
      console.log(err);
      res.status(500).send('Internal Server Error: ' + err);
    } 
      console.log('Upload Successfully');
      let uploadedProfilePicture = await db.queryPG(`UPDATE "users" SET "picturePath" = '${path}' WHERE "id" = '${user_id}' RETURNING "picturePath"`);
      res.status(200).send({"return": 'Upload Successfully', "uploadedProfilePicture": uploadedProfilePicture});
    
  }).on('httpUploadProgress', function(evnt) {
    console.log(evnt);
  });

});








// import mime from 'mime-types';
const mime = require('mime-types');





// Catch all exceptions 
process.on('uncaughtException', function (err) {
  console.error(err);
});


// testSQL();
async function testSQL() {
  var testPG = await db.queryPG("SELECT * FROM users", []);
  console.log(testPG);
}

const Upload = require('./services/upload');
const fs = require('fs');

app.post(
  '/videos/upload',
  multer().single('uploadVideoFile'),
  async (req, res) => {
      if(!req.file){res.status(400).send('Bad Request: No file was uploaded');return;}
      var descryption = req.body.descryption;
      if(descryption == null) {
          res.send("Missing parameters").status(400);
          return;
      } 
  var user_id = await UserService.getUserIdFromTokenExport(req);
  if(user_id == null || user_id == undefined || user_id == "") {
    res.send("User not logged in").status(401);
    return;
  }
  var privacy_id = req.body.privacy_id;
  if(privacy_id == null) {
    res.send("Missing parameters").status(400);
    return;
  }
  // Check if isPrivate is between 0 and 2
  if(privacy_id < 0 || privacy_id > 2) {
    res.send("Invalid parameters").status(400);
    return;
  }
  timestamp = (new Date().toISOString()).replaceAll("-", "").replaceAll(":", "").replaceAll(".", "").replaceAll("T", "_").replaceAll("Z", "");
  const fileExtension = req.file.originalname.split('.').pop();
  console.log("File Extension: " + fileExtension);
  //Check if fileExtension is mp4
  if(fileExtension != "mp4"){
    res.status(400).send('Bad Request: File extension is not supported');
    return;
  }
  const filename = `${user_id}-${timestamp}.${fileExtension}`;
  const filepath = 'videos/' + filename;
  
  const mimeType = mime.contentType(fileExtension);
  console.log("Mime Type: " + mimeType);
  const s3 = Connection();
  // const params = {
    const params = { Bucket: process.env.S3_BUCKET_NAME, Key: filepath, Body: req.file.buffer, ACL: 'public-read', ContentType: req.file.mimetype, mime: mime };
  await s3.upload(params, async function(err, data) {
    if (err) {
      console.log(err);
      res.status(500).send('Internal Server Error: ' + err);
    }
    console.log('Upload Successfully');
  }).promise();
  // const url = await Upload.Upload(process.env.S3_BUCKET_NAME, req.file, filepath, '', mimeType);
  // const s3 = Connection();
  let tempFile = fs.createWriteStream(filename);
  //Download the file
  s3.getObject({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: filepath
  }).on('httpData', function (chunk) {
    tempFile.write(chunk);
  }).on('httpDone', async function () {
    tempFile.end();
    //Get the duration of the video
    var length = await getVideoDurationInSeconds(tempFile.path);
    length = Math.round(length);
    console.log("Length of Video: " + length);
    var thumbnailPath = "thumbnails/" + filename.split(".")[0] + ".png";
    await genThumbnail(tempFile.path, thumbnailPath, '250x?', {
      path: ffmpegPath,
    });
    //Upload the thumbnail to S3
    var thumbnailFileStream = fs.createReadStream(thumbnailPath);
    thumbnailFileStream.on('error', function (err) {
      console.log('File Error', err);
    });
    thumbnailFileStream.on('open', function () {
      s3.putObject({
        Bucket: process.env.S3_BUCKET_NAME,
        Key: thumbnailPath,
        Body: thumbnailFileStream,
        ContentType: 'image/png'
      }, function (err, data) {
        if (err) {
          console.log('Error uploading data: ', err);
        } else {
          console.log('Successfully uploaded the thumbnail to S3');
          fs.unlink(thumbnailPath, function (err) {
            if (err) {
              console.log('Error deleting the thumbnail file');
            } else {
              console.log('Thumbnail file was deleted');
            }
          });
        }
      });
    });

    //Delete the tempfile
    fs.unlink(tempFile.path, function (err) {
      if (err) throw err;
      console.log('Temp File Deleted');
    });


      var hashtags = null;
        if(descryption.includes("#")) {
            // Get all Hashtags from the description
            hashtags = descryption.match(/#\w+/g);
            // Remove the # from the hashtags
            hashtags = hashtags.map(function(hashtag) {
                return hashtag.slice(1);
            });
            console.log(hashtags);
            console.log("Hashtags length: " + hashtags.length);
        }
        let createdVideo = await db.queryPG(`INSERT INTO "videos" ("path", "length", "user_id", "descryption", "shares", "enableComments", "thumbnailPath", "privacy_id") VALUES ('${filepath}', '${length}', '${user_id}', '${descryption}', 0, true, '${thumbnailPath}', ${privacy_id}) RETURNING *`);
        if(hashtags != null) {
        for(var i = 0; i < hashtags.length; i++){
                            var tag = hashtags[i];
                            tag = tag.toLowerCase();
                            console.log("Tag: " + tag);
                            var tagExists = await db.queryPG(`SELECT * FROM tags WHERE tag = '${tag}'`);
                            console.log("Tag exists: " + tagExists.length);
                            if(tagExists.length == 0){
                                console.log("Tag does not exist");
                                
                                var tagId = await db.queryPG(`INSERT INTO tags (tag) VALUES ('${tag}') RETURNING id`);
                                console.log("TagId: " + tagId);
                                console.log("Tag id: " + tagId[0].id);
                                await db.queryPG(`INSERT INTO "videos_tags_XREF" (video_id, tag_id) VALUES (${createdVideo[0].id}, ${tagId[0].id})`);
                            }else{
                                console.log("Tag exists");
                                var tagId = tagExists[0].id;
                                console.log("Tag id: " + tagId);
                                await db.queryPG(`INSERT INTO "videos_tags_XREF" (video_id, tag_id) VALUES (${createdVideo[0].id}, ${tagId})`);
                            }
                        }
        }
        res.status(200).send(createdVideo);
      }).send();
  });

  const Connection = require('./services/connection');
const Connect = require('./services/connection');



const s3 = Connection();
app.get('/videos/:id', async(req, res, next) =>{
  // console.log("Headers: " + JSON.stringify(req.headers));
  // console.log("Auth Token: " + req.header.);
  var user_id = await UserService.getUserIdFromTokenExport(req) || 8;
  // console.log("User ID: " + user_id);
  if(user_id == null || user_id == undefined || user_id == "" || user_id == false) {
    console.log("User ID is null");
    res.status(401).send("Unauthorized");
    return;
  }
  // console.log("Acceptet User ID: " + user_id);
  var id = req.params.id;
  // videosid.mp4
  id = id.split(".")[0];
  console.log("Video ID: " + id);
  var video = await db.queryPG(`SELECT * FROM videos WHERE id = ${id}`);
  if(video.length == 0){
    console.log("Video does not exist");
    res.status(404).send("Video not found");
  }
    if(video[0].privacy_id == 1){
          console.log("Video is private 1");
          if(user_id == video[0].user_id){
            console.log("User is the owner of the video");
          }else{
            console.log("User is not the owner of the video - Check followers")
            var followers = await db.queryPG(`SELECT "from_user_id" FROM "following" WHERE to_user_id = ${video[0].user_id}`);
            var foundInFollowers = false;
            for(var i = 0; i < followers.length; i++){
              if(followers[i].from_user_id == user_id){
                foundInFollowers = true;
                console.log("User is following");
                break;
              }
            }
            if(!foundInFollowers){
              console.log("User is not following");
              res.status(401).send('Unauthorized');
              return;
            }
          }
        }
        if(video[0].privacy_id == 2){
          if(user_id != video[0].user_id){
            console.log("User is not the owner of the video");
            res.status(403).send('Video is full private for User: ' + video[0].user_id);
            return;
          }
        }
  var path = video[0].path;
  const Bucket = process.env.S3_BUCKET_NAME;
  const signedUrlExpireSeconds = 60 * 5
  const url = s3.getSignedUrl('getObject', {
    Bucket,
    Key: path,
    Expires: signedUrlExpireSeconds
  });
  res.redirect(url);
}
);


  app.get(
    '/thumbnails/:path',
    async (req, res) => {
        var user_id = await UserService.getUserIdFromTokenExport(req);
        var path = req.params.path;
        path = "thumbnails/" + path;
        console.log("Path: " + path);
        const s3 = Connection();
        const params = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: `${path}`
        };
        //Get start time
        var startTime = new Date().getTime();
        //Check if the video exists in s3
        try{
          await s3.headObject(params).promise();
        }catch(err){
          res.status(404).send("Thumbnail does not exist");
          var endTime = new Date().getTime();
          return;
        }
        var endTime = new Date().getTime();
      res.set('Cache-Control', 'max-age=31536000');
      res.set('Content-Type', 'image/png');
        s3.getObject(params).on('httpData', (chunk) => {
            res.write(chunk);
        }).on('httpDone', () => {
          console.log('Done');
            res.end();
        }).on('error', (err) => {
          console.log("Error")
            console.log(err);
            res.status(400).send('Bad Request: No file was uploaded');
            return;
        }).send();
    }
  );

  app.get(
    '/profilepics/:path',
    async (req, res) => {
        // var user_id = await UserService.getUserIdFromTokenExport(req);
        var path = req.params.path;
        path = "profilepics/" + path;
        console.log("Path: " + path);
        const s3 = Connection();
        const params = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: `${path}`
        };
        //Get start time
        var startTime = new Date().getTime();
        //Check if the video exists in s3
        try{
          await s3.headObject(params).promise();
          console.log("Thumbnail exists");
        }catch(err){
          console.log("Thumbnail does not exist");
          res.status(404).send("Thumbnail does not exist");
          var endTime = new Date().getTime();
          console.log("Time to check if Thumbnail exists in ms: " + (endTime - startTime));
          return;
        }
        var endTime = new Date().getTime();
        console.log("Time to check if Thumbnail exists: " + (endTime - startTime));
        console.log("After Check")
      res.set('Cache-Control', 'max-age=31536000');
      res.set('Content-Type', 'image/png');
        s3.getObject(params).on('httpData', (chunk) => {
            res.write(chunk);
        }).on('httpDone', () => {
          console.log('Done');
            res.end();
        }).on('error', (err) => {
          console.log("Error")
            console.log(err);
            res.status(400).send('Bad Request: No file was uploaded');
            return;
        }).send();
    }
  );

app.post('/messages/upload/record', multer().single('uploadRecord'), async (req, res) => {
  var user_id = await UserService.getUserIdFromTokenExport(req);
  var receiver_id = req.body.receiver_id;
  if(user_id == null || user_id == false){
    res.status(401).send("Unauthorized");
    return;
  }
  if(receiver_id == null){
    res.status(400).send("Bad Request: No receiver_id");
    return;
  }
  var file = req.file;
  if(!file){
    res.status(400).send("No file was uploaded");
    return;
  }
  var fileExtension = file.originalname.split(".")[1];
  if(fileExtension != "m4a"){
    res.status(400).send("File is not an m4a");
    return;
  }
  var timestamp = (new Date().toISOString()).replaceAll("-", "").replaceAll(":", "").replaceAll(".", "").replaceAll("T", "_").replaceAll("Z", "");
  var newFileName = user_id + "_" + timestamp + "." + fileExtension;
  var path = "messages/recordings/" + newFileName;
  s3.upload({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: path,
    Body: file.buffer,
    ContentType: file.mimetype,
  },async (err, data) => {
    if (err) {
      console.log(err);
      res.status(400).send('Bad Request: No file was uploaded');
      return;
    }
    await db.queryPG(`INSERT INTO "messages" (from_user_id, to_user_id, message, timestamp, record_path) VALUES (${user_id}, ${receiver_id}, '', CURRENT_TIMESTAMP, '${path}') RETURNING id`);
    console.log(`File uploaded successfully. ${data.Location}`);
    res.status(200).send("Uploaded");
  });
});

// messages/recordings/8_20220329_191239473.m4a

app.get('/messages/recordings/:path', async (req, res) => {
  var user_id = await UserService.getUserIdFromTokenExport(req);
  
  if(user_id == null || user_id == false){
    res.status(401).send("Unauthorized");
    return;
  }
  var path = req.params.path;
  var fullPath = "messages/recordings/" + path;
  console.log("Path: " + fullPath);
  var currMessage = await db.queryPG(`SELECT * FROM "messages" WHERE record_path = '${fullPath}'`);
  if(currMessage.length == 0){
    res.status(404).send("File does not exist");
    return;
  }
  if(user_id != currMessage[0].from_user_id && user_id != currMessage[0].to_user_id){
    console.log(user_id + " " + currMessage[0].from_user_id + " " + currMessage[0].to_user_id);
    res.status(401).send("Unauthorized to view this file");
    return;
  }
  res.set('Cache-Control', 'max-age=31536000');
  res.set('Content-Type', 'audio/mpeg');
  s3.getObject({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: fullPath
  }).on('httpData', (chunk) => {
    res.write(chunk);
  }).on('httpDone', () => {
    console.log('Done');
    res.end();
  }).on('error', (err) => {
    console.log("Error")
    console.log(err);
    res.status(400).send('Bad Request: No file was uploaded');
    return;
  }).send();
});



var httpServer = http.createServer(app);


// Websocket for LiveStream Chats
const WebSocket = require('ws')
// var  webSockets = {}

const wss = new WebSocket.Server({ port: 6060 }) //run websocket server with port 6060
wss.on('connection',ws=>{
  ws.room=[];
  ws.send("connected");

  ws.on('message', message=>{
    try{
      var messag=JSON.parse(message);
      if(messag.join){ws.room.push(messag.join); console.log(ws.room); ws.send("joined");}
      if(messag.room){broadcast(message);}
    }catch(e)
      {console.log(e)}
  })
  
  ws.on('error',e=>console.log(e))
  ws.on('close',(e)=>console.log('websocket closed'+e))
  
})


  
async function broadcast(message){
  message = JSON.parse(message);
  console.log(message);
  var req = {
    headers: {
      authorization: message.token
    } 
  };
  message.userid = await UserService.getUserIdFromTokenExport(req);
  if(message.userid == null || message.userid == false){
    console.log("Unauthorized");
    return;
  }
  var currUser = await db.queryPG(`SELECT "username", "picturePath" FROM "users" WHERE id = ${message.userid}`);
  message.username = currUser[0].username;
  message.picturePath = currUser[0].picturePath;
  delete message.token;
  wss.clients.forEach(client=>{
    if(client.room.indexOf(message.room)>-1){
      client.send(JSON.stringify(message));
    }
  })
}




// const io = require("socket.io")(httpServer, {
//   cors: {
//     origin: "*",
//     methods: ["GET", "POST"],
//     allowedHeaders: ["my-custom-header"],
//     credentials: true,
//   },
// });
// const { addLiveChatUser, removeLiveChatUser } = require("./LiveChatUser.js");


// io.on("connection", (socket) => {
//   console.log("User connected");
//   socket.on("join", ({ name, streamName }, callBack) => {
//     const { liveChatUser, error } = addLiveChatUser({ id: socket.id, name, streamName });
//     if (error){
//       console.log("Error: " + name + " " + streamName);
//       return callBack(error);
//     }

//     socket.join(liveChatUser.streamName);
//     socket.emit("message", {
//       user: "Admin",
//       text: `Welocome to ${liveChatUser.streamName}`,
//     });

//     socket.broadcast
//       .to(liveChatUser.streamName)
//       .emit("message", { user: "Admin", text: `${liveChatUser.name} has joined!` });
//     callBack(null);

//     socket.on("sendMessage", ({ message }) => {
//       io.to(liveChatUser.streamName).emit("message", {
//         user: liveChatUser.name,
//         text: message,
//       });
//     });
//   });
//   socket.on("disconnect", () => {
//     const liveChatUser = removeLiveChatUser(socket.id);
//     console.log(liveChatUser);
//     io.to(liveChatUser.streamName).emit("message", {
//       user: "Admin",
//       text: `${liveChatUser.name} just left the room`,
//     });
//     console.log("A disconnection has been made");
//   });
// });

// var io = require('socket.io')(httpServer);
// io.on('connection', s => {
//   console.error('socket.io connection');
//   for (var t = 0; t < 3; t++)
//     setTimeout(() => s.emit('message', 'message from server'), 1000*t);
// });

httpServer.listen(port);
console.log("Server gestartet");
console.log("Port: " + port);

module.exports = app;

