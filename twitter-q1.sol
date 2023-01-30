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

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;
    uint256 public nextTweetId;
    // ----- END OF DO-NOT-EDIT ----- //

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
        User memory thisUser = users[_user];
        bytes memory thisUserBytesStr = bytes(thisUser.name);
        require(thisUserBytesStr.length != 0, "This wallet does not belong to any account.");
        _;
    }

}