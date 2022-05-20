let liveChatUsers = [];

exports.addLiveChatUser = ({ id, name, streamName }) => {
  if (!name || !streamName) return { error: "Username and StreamName are required." };
  const liveChatUser = { id, name, streamName };

  liveChatUsers.push(liveChatUser);

  return { liveChatUsers };
};
exports.removeLiveChatUser = (id) => {
  const index = liveChatUsers.findIndex((liveChatUser) => liveChatUser.id === id);
  return liveChatUsers[index];
};