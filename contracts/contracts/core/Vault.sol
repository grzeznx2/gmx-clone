// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vault {

    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant FUNDING_RATE_PRECISION = 1000000;
    uint256 public constant PRICE_PRECISION = 10 ** 30;
    uint256 public constant MIN_LEVERAGE = 10000; // 1x
    uint256 public constant USDG_DECIMALS = 18;
    uint256 public constant MAX_FEE_BASIS_POINTS = 500; // 5%
    uint256 public constant MAX_LIQUIDATION_FEE_USD = 100 * PRICE_PRECISION; // 100 USD
    uint256 public constant MIN_FUNDING_RATE_INTERVAL = 1 hours;
    uint256 public constant MAX_FUNDING_RATE_FACTOR = 10000; // 1%

    uint256 public liquidationFeeUsd;
    uint256 public taxBasisPoints = 50; // 0.5%
    uint256 public stableTaxBasisPoints = 20; // 0.2%
    uint256 public mintBurnFeeBasisPoints = 30; // 0.3%
    uint256 public swapFeeBasisPoints = 30; // 0.3%
    uint256 public stableSwapFeeBasisPoints = 4; // 0.04%
    uint256 public marginFeeBasisPoints = 10; // 0.1%

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