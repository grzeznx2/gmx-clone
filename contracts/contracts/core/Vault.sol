// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vault {

    mapping(uint256 => string) public errors;

    address public errorController;
    address public gov;

    address[] public allWhitelistedTokens;
    mapping (address => bool) public whitelistedTokens;
    mapping (address => bool ) public managers;
    bool public inManagerMode = false;

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

    function setManager(address _manager, bool _isManager) external {
        _onlyGov();
        managers[_manager] = _isManager;
    }

    function setInManagerMode(bool _inManagerMode) external {
        inManagerMode = _inManagerMode;
    }

    function _onlyGov() private view {
        _validate(msg.sender == gov, 1001);
    }

    function _validate(bool _condition, uint256 _errorCode) private view {
        require(_condition, errors[_errorCode]);
    }

    function _validateManager() private view {
        if(inManagerMode){
            _validate(managers[msg.sender], 1002);
        }
    }
}