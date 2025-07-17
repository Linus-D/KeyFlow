// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title UserManager - Manages user registration and interests in a decentralized social media platform.
/// @author Your Name
/// @notice This contract allows users to register and store their interests for AI-based content recommendations.
/// @dev Uses mappings, events, and gas-efficient error handling.

contract UserManager {
    /// @notice Struct to store user details
    struct User {
        string username;
        string[] interests;
        bool isRegistered;
    }

    /// @dev Mapping of user addresses to their profile information
    mapping(address => User) private users;

    /// @notice Event emitted when a user successfully registers
    event UserRegistered(address indexed user, string username, string[] interests);

    /// @notice Event emitted when a user updates their interests
    event InterestsUpdated(address indexed user, string[] newInterests);

    /// @dev Custom error for better gas optimization
    error UserAlreadyRegistered();
    error UserNotRegistered();
    error InvalidUsername();
    error NoInterestsProvided();

    /// @dev Modifier to ensure the user is registered
    modifier onlyRegisteredUser() {
        if (!users[msg.sender].isRegistered) revert UserNotRegistered();
        _;
    }

    /// @notice Allows a new user to register with a username and interests
    /// @param _username The desired username of the user
    /// @param _interests An array of interests the user wants to store
    function registerUser(string memory _username, string[] memory _interests) external {
        if (users[msg.sender].isRegistered) revert UserAlreadyRegistered();
        if (bytes(_username).length == 0) revert InvalidUsername();
        if (_interests.length == 0) revert NoInterestsProvided();

        users[msg.sender] = User(_username, _interests, true);

        emit UserRegistered(msg.sender, _username, _interests);
    }

    /// @notice Allows an already registered user to update their interests
    /// @param _newInterests The new set of interests the user wants to store
    function updateInterests(string[] memory _newInterests) external onlyRegisteredUser {
        if (_newInterests.length == 0) revert NoInterestsProvided();

        users[msg.sender].interests = _newInterests;

        emit InterestsUpdated(msg.sender, _newInterests);
    }

    /// @notice Fetches user details (public view function)
    /// @param _user Address of the user to fetch details for
    /// @return username The username of the user
    /// @return interests The list of interests stored by the user
    function getUserDetails(address _user) external view returns (string memory username, string[] memory interests) {
        if (!users[_user].isRegistered) revert UserNotRegistered();
        User storage user = users[_user];
        return (user.username, user.interests);
    }

    /// @notice Checks if a user is registered
    /// @param _user Address of the user to check
    /// @return isRegistered True if the user is registered, otherwise false
    function isUserRegistered(address _user) external view returns (bool) {
        return users[_user].isRegistered;
    }
}
