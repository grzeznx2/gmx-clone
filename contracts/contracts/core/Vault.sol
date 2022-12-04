// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vault {

    // error messages to be replaced later
    uint256 public error1;
    mapping(uint256 => string) public errors;

    address public errorController;
    address public gov;

    address[] public allWhitelistedTokens;
    mapping (address => bool) whitelistedTokens;

    constructor(){
        gov = msg.sender;
    }

    function setErrorController(address _errorController) external {
        _onlyGov();
        errorController = _errorController;
    }

    function setError(uint256 _errorCode, string calldata _error) external {
        require(msg.sender == errorController, "Vault: invalid errorController");
        errors[_errorCode] = _error;
    }

    function allWhitelistedTokensLength() external view returns(uint256){
        return allWhitelistedTokens.length;
    }

    function _onlyGov() private view {
        _validate(msg.sender == gov, error1);
    }

    function _validate(bool _condition, uint256 _errorCode) private view {
        require(_condition, errors[_errorCode]);
    }
}