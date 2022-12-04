// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vault {
    mapping(uint256 => string) public errors;
    address public errorController;

    constructor(){}

    function setError(uint256 errorCode, string calldata error) external {
        require(msg.sender == errorController, "Vault: invalid errorController");
        errors[errorCode] = error;
    }
}