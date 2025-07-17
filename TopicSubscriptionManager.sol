// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TopicSubscriptionManager is Ownable {
    // Mapping of user addresses to topic subscriptions
    mapping(address => mapping(string => bool)) private subscriptions;

    // Optional limits for topic validation
    uint256 public constant MIN_TOPIC_LENGTH = 1;
    uint256 public constant MAX_TOPIC_LENGTH = 100;

    // Events
    event Subscribed(address indexed user, string topic);
    event Unsubscribed(address indexed user, string topic);

    // Constructor passing the owner address to Ownable
    constructor() Ownable(msg.sender) {}

    // Modifier to validate topic input
    modifier validTopic(string memory _topic) {
        bytes memory topicBytes = bytes(_topic);
        require(topicBytes.length >= MIN_TOPIC_LENGTH, "Topic cannot be empty");
        require(topicBytes.length <= MAX_TOPIC_LENGTH, "Topic name too long");
        _;
    }

    // Subscribe to a topic
    function subscribe(string memory _topic) external validTopic(_topic) {
        require(!subscriptions[msg.sender][_topic], "Already subscribed to this topic");
        subscriptions[msg.sender][_topic] = true;
        emit Subscribed(msg.sender, _topic);
    }

    // Unsubscribe from a topic
    function unsubscribe(string memory _topic) external validTopic(_topic) {
        require(subscriptions[msg.sender][_topic], "You are not subscribed to this topic");
        subscriptions[msg.sender][_topic] = false;
        emit Unsubscribed(msg.sender, _topic);
    }

    // Check if a user is subscribed to a specific topic
    function isSubscribed(address _user, string memory _topic) external view validTopic(_topic) returns (bool) {
        return subscriptions[_user][_topic];
    }

    // Admin function (optional) to view a user's subscription status
    function getSubscriptionStatus(address _user, string memory _topic) external view onlyOwner returns (bool) {
        return subscriptions[_user][_topic];
    }
}
