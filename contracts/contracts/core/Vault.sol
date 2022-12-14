// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vault {

    struct Position {
        uint256 size;
        uint256 collateral;
        uint256 averagePrice;
        uint256 entryFundingRate;
        uint256 reserveAmount;
        int256 realisedPnl;
        uint256 lastIncreasedTime;
    }

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

    uint256 public fundingInterval = 8 hours;
    uint256 public fundingRateFactor;
    uint256 public stableFundingRateFactor;
    uint256 public totalTokenWeights;

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

    function setFees(
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints,
        uint256 _marginFeeBasisPoints,
        uint256 _liquidationFeeUsd
    )   external {
        _onlyGov();
        _validate(_taxBasisPoints <= MAX_FEE_BASIS_POINTS, 1003);
        _validate(_stableTaxBasisPoints <= MAX_FEE_BASIS_POINTS, 1004);
        _validate(_mintBurnFeeBasisPoints <= MAX_FEE_BASIS_POINTS, 1005);
        _validate(_swapFeeBasisPoints <= MAX_FEE_BASIS_POINTS, 1006);
        _validate(_stableSwapFeeBasisPoints <= MAX_FEE_BASIS_POINTS, 1007);
        _validate(_marginFeeBasisPoints <= MAX_FEE_BASIS_POINTS, 1008);
        _validate(_liquidationFeeUsd <= MAX_LIQUIDATION_FEE_USD, 1009);
        taxBasisPoints = _taxBasisPoints;
        stableTaxBasisPoints = _stableTaxBasisPoints;
        mintBurnFeeBasisPoints = _mintBurnFeeBasisPoints;
        swapFeeBasisPoints = _swapFeeBasisPoints;
        stableSwapFeeBasisPoints = _stableSwapFeeBasisPoints;
        marginFeeBasisPoints = _marginFeeBasisPoints;
    }

    function setFundingRate(uint256 _fundingInterval, uint256 _fundingRateFactor, uint256 _stableFundingRateFactor) external {
        _onlyGov();
        _validate(_fundingInterval >= MIN_FUNDING_RATE_INTERVAL, 1010);
        _validate(_fundingRateFactor <= MAX_FUNDING_RATE_FACTOR, 1010);
        _validate(_stableFundingRateFactor <= MAX_FUNDING_RATE_FACTOR, 1010);
        fundingInterval = _fundingInterval;
        fundingRateFactor = _fundingRateFactor;
        stableFundingRateFactor = _stableFundingRateFactor;
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