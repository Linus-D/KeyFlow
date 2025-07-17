// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SocialInteraction {
    // Constants
    uint256 public constant MAX_COMMENT_LENGTH = 280;
    uint256 public constant COMMENT_COOLDOWN = 1 minutes;

    // Enum for interaction types
    enum ActionType { Like, Share, Comment }

    // Struct for storing interaction details
    struct Interaction {
        uint256 postId;
        address user;
        ActionType action;
        string commentText;
        uint256 timestamp;
    }

    // Mapping from postId to all interactions
    mapping(uint256 => Interaction[]) private interactions;

    // Interaction counters
    mapping(uint256 => uint256) public likeCounts;
    mapping(uint256 => uint256) public shareCounts;
    mapping(uint256 => uint256) public commentCounts;

    // Mapping to prevent duplicate likes per user per post
    mapping(uint256 => mapping(address => bool)) public hasLiked;

    // Mapping to limit comment frequency per user per post
    mapping(address => uint256) public lastCommentTime;

    // Events
    event PostLiked(address indexed user, uint256 indexed postId);
    event PostShared(address indexed user, uint256 indexed postId);
    event PostCommented(address indexed user, uint256 indexed postId, string comment);

    // Modifier to validate comment
    modifier validComment(string memory _comment) {
        bytes memory commentBytes = bytes(_comment);
        require(commentBytes.length > 0, "Comment cannot be empty");
        require(commentBytes.length <= MAX_COMMENT_LENGTH, "Comment too long");
        _;
    }

    // Modifier to limit comment frequency (anti-spam)
    modifier notSpammingComment() {
        require(
            block.timestamp >= lastCommentTime[msg.sender] + COMMENT_COOLDOWN,
            "Please wait before commenting again"
        );
        _;
    }

    // Like a post
    function likePost(uint256 _postId) external {
        require(!hasLiked[_postId][msg.sender], "You already liked this post");

        interactions[_postId].push(
            Interaction({
                postId: _postId,
                user: msg.sender,
                action: ActionType.Like,
                commentText: "",
                timestamp: block.timestamp
            })
        );

        hasLiked[_postId][msg.sender] = true;
        likeCounts[_postId] += 1;

        emit PostLiked(msg.sender, _postId);
    }

    // Share a post
    function sharePost(uint256 _postId) external {
        interactions[_postId].push(
            Interaction({
                postId: _postId,
                user: msg.sender,
                action: ActionType.Share,
                commentText: "",
                timestamp: block.timestamp
            })
        );

        shareCounts[_postId] += 1;

        emit PostShared(msg.sender, _postId);
    }

    // Comment on a post
    function commentOnPost(uint256 _postId, string memory _comment)
        external
        validComment(_comment)
        notSpammingComment
    {
        interactions[_postId].push(
            Interaction({
                postId: _postId,
                user: msg.sender,
                action: ActionType.Comment,
                commentText: _comment,
                timestamp: block.timestamp
            })
        );

        commentCounts[_postId] += 1;
        lastCommentTime[msg.sender] = block.timestamp;

        emit PostCommented(msg.sender, _postId, _comment);
    }

    // Get all interactions for a post
    function getInteractions(uint256 _postId) external view returns (Interaction[] memory) {
        return interactions[_postId];
    }

    // Get counts (alternative to public vars if needed by frontend)
    function getInteractionCounts(uint256 _postId) external view returns (uint256 likes, uint256 shares, uint256 comments) {
        return (likeCounts[_postId], shareCounts[_postId], commentCounts[_postId]);
    }
}
