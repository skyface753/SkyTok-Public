const express = require('express');
const router = express.Router();

const UserService = require('./services/userService');
router.post('/logout', UserService.logout);
router.post('/users/status', UserService.status);
router.post('/users/register', UserService.register);
router.post('/users/info', UserService.info);

const VideoSerice = require('./services/videoService');
router.post('/videos/forUser', VideoSerice.forUser);
router.post('/videos/proposals', VideoSerice.proposals);
router.post('/videos/liked', VideoSerice.liked);
router.post('/videos/liked/get', VideoSerice.getLiked);
router.post('/videos/unliked', VideoSerice.unliked);
router.post('/videos/watched', VideoSerice.watched);
router.post('/videos/share', VideoSerice.share);
router.post('/videos/allTrending', VideoSerice.allTrending);
router.post('/videos/tenTrinding', VideoSerice.tenTrending);

const CommentService = require('./services/commentService');
router.post('/comments/create', CommentService.create);
router.post('/comments/getbyVideoId', CommentService.getbyVideoId);
router.post('/comments/liked', CommentService.liked);
router.post('/comments/unliked', CommentService.unliked);

const TagService = require('./services/tagsService');
router.post('/tags/trending', TagService.trending);
router.post('/tags/get/video', TagService.getVideos);

const MessagesService = require('./services/messagesService');
router.post('/messages/send', MessagesService.send);
router.post('/messages/chats/get', MessagesService.getChats);
router.post('/messages/get', MessagesService.getMessages);

//Search Service
const SearchService = require('./services/searchService');
router.post('/search', SearchService.search);

const FollowerService = require('./services/followerService');
router.post('/followers/get/Followers', FollowerService.getMyFollowers);
router.post('/followers/get/Following', FollowerService.getMyFollowing);
router.post('/followers/new', FollowerService.newFollowing);
router.post('/followers/delete', FollowerService.deleteFollowing);
router.post('/followers/sugestions', FollowerService.followerSuggestions);

const notificationService = require('./services/notificationService');
router.post('/notifications/get', notificationService.getNotifications);

const analyticsService = require('./services/analyticsService');
router.post('/analytics/get', analyticsService.get);
router.post('/analytics/get/all', analyticsService.getAll);
router.post('/analytics/send/duration', analyticsService.sendDuration);

const lievService = require('./services/liveService');
router.post('/live/start', lievService.start);
router.post('/live/stop', lievService.stop);
router.post('/live/join', lievService.join);
router.post('/live/views', lievService.getViewersForLiveExport);

module.exports = router;