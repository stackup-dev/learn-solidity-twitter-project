// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {
    // ----- START OF DO-NOT-EDIT ----- //
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;
    // ----- END OF DO-NOT-EDIT ----- //

    // ----- START OF QUEST 1 ----- //
    function registerAccount(string calldata _name) external {
        bytes memory bname = bytes(_name);
        require(bname.length != 0, "Name cannot be an empty string");
        User storage newUser = users[msg.sender];
        newUser.wallet = msg.sender;
        newUser.name = _name;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
        Tweet memory newTweet = Tweet(nextTweetId, msg.sender, _content, block.timestamp);
        tweets[nextTweetId] = newTweet;
        User storage thisUser = users[msg.sender];
        thisUser.userTweets.push(nextTweetId);
        nextTweetId++;
    }

    function readTweets(address _user) view external returns(Tweet[] memory) {
        uint[] storage userTweetIds = users[_user].userTweets;
        Tweet[] memory userTweets = new Tweet[](userTweetIds.length);
        for(uint i = 0; i < userTweetIds.length; i++) {
            userTweets[i] = tweets[userTweetIds[i]];
        }
        return userTweets;
    }

    modifier accountExists(address _user) {
        User storage thisUser = users[_user];
        bytes memory thisUserBytesStr = bytes(thisUser.name);
        require(thisUserBytesStr.length != 0, "This wallet does not belong to any account.");
        _;
    }
    // ----- END OF QUEST 1 ----- //

    // ----- START OF QUEST 2 ----- //
    function followUser(address _user) external accountExists(_user) accountExists(msg.sender) {
        User storage functionCaller = users[msg.sender];
        functionCaller.following.push(_user);

        User storage user = users[_user];
        user.followers.push(msg.sender);
    }

    function getFollowing() external view accountExists(msg.sender) returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view accountExists(msg.sender) returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory allTweets = new Tweet[](nextTweetId);
        for(uint i = 0; i<nextTweetId; i++){
            allTweets[i] = tweets[i];
        }
        return allTweets;
    }

    function sendMessage(address _recipient, string calldata _content) external accountExists(msg.sender) accountExists(_recipient) {
        Message memory newMessage = Message(nextMessageId, _content, msg.sender, _recipient);
        
        User storage sender = users[msg.sender];
        sender.conversations[_recipient].push(newMessage);

        User storage recipient = users[_recipient];
        recipient.conversations[msg.sender].push(newMessage);

        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        User storage thisUser = users[msg.sender];
        return thisUser.conversations[_user];
    }
    // ----- END OF QUEST 2 ----- //
}