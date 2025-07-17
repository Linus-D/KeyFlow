// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PostManager is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private postIdCounter;

    constructor() Ownable(msg.sender) {}

    // Constants
    uint256 public constant MAX_CONTENT_LENGTH = 500;
    uint256 public constant MAX_COMMENT_LENGTH = 280;
    uint256 public constant POST_COOLDOWN = 1 minutes;

    // Structs
    struct Post {
        uint256 postId;
        address author;
        string content;
        string ipfsHash;
        string[] topics;
        uint256 timestamp;
        uint256 likeCount;
    }

    struct Comment {
        address commenter;
        string commentText;
        uint256 timestamp;
    }

    struct Share {
        address sharer;
        uint256 timestamp;
    }

    // Mappings
    mapping(uint256 => Post) public posts;
    mapping(uint256 => Comment[]) private postComments;
    mapping(uint256 => Share[]) private postShares;
    mapping(address => uint256[]) private userPosts;
    mapping(uint256 => mapping(address => bool)) public hasLiked;
    mapping(address => uint256) private lastPostTime;

    // Events
    event PostCreated(uint256 indexed postId, address indexed author, string content, string ipfsHash, string[] topics);
    event PostLiked(uint256 indexed postId, address indexed liker);
    event CommentAdded(uint256 indexed postId, address indexed commenter, string commentText);
    event PostShared(uint256 indexed postId, address indexed sharer);

    // Modifiers
    modifier notSpamming() {
        require(block.timestamp >= lastPostTime[msg.sender] + POST_COOLDOWN, "Cooldown: Please wait before posting again");
        _;
    }

    modifier validContent(string memory content) {
        require(bytes(content).length > 0 && bytes(content).length <= MAX_CONTENT_LENGTH, "Invalid content length");
        _;
    }

    modifier validComment(string memory commentText) {
        require(bytes(commentText).length > 0 && bytes(commentText).length <= MAX_COMMENT_LENGTH, "Invalid comment length");
        _;
    }

    modifier postMustExist(uint256 postId) {
        require(posts[postId].author != address(0), "Post does not exist");
        _;
    }

    // Core Functions

    function createPost(string memory content, string memory ipfsHash, string[] memory topics)
        external
        notSpamming
        validContent(content)
    {
        require(topics.length > 0, "At least one topic required");

        uint256 postId = postIdCounter.current();
        postIdCounter.increment();

        posts[postId] = Post({
            postId: postId,
            author: msg.sender,
            content: content,
            ipfsHash: ipfsHash,
            topics: topics,
            timestamp: block.timestamp,
            likeCount: 0
        });

        userPosts[msg.sender].push(postId);
        lastPostTime[msg.sender] = block.timestamp;

        emit PostCreated(postId, msg.sender, content, ipfsHash, topics);
    }

    function likePost(uint256 postId) external postMustExist(postId) {
        require(!hasLiked[postId][msg.sender], "Already liked");

        posts[postId].likeCount += 1;
        hasLiked[postId][msg.sender] = true;

        emit PostLiked(postId, msg.sender);
    }

    function addComment(uint256 postId, string memory commentText)
        external
        postMustExist(postId)
        validComment(commentText)
    {
        postComments[postId].push(Comment({
            commenter: msg.sender,
            commentText: commentText,
            timestamp: block.timestamp
        }));

        emit CommentAdded(postId, msg.sender, commentText);
    }

    function sharePost(uint256 postId) external postMustExist(postId) {
        postShares[postId].push(Share({
            sharer: msg.sender,
            timestamp: block.timestamp
        }));

        emit PostShared(postId, msg.sender);
    }

    // Getter Functions

    function getComments(uint256 postId) external view postMustExist(postId) returns (Comment[] memory) {
        return postComments[postId];
    }

    function getShares(uint256 postId) external view postMustExist(postId) returns (Share[] memory) {
        return postShares[postId];
    }

    function getUserPosts(address user) external view returns (uint256[] memory) {
        return userPosts[user];
    }

    function getTotalPosts() external view returns (uint256) {
        return postIdCounter.current();
    }

    function getPost(uint256 postId) external view postMustExist(postId) returns (Post memory) {
        return posts[postId];
    }
}
