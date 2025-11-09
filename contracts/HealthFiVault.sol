// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HealthFiVault is Ownable {
    // Mapping of accepted tokens by name
    mapping(string => IERC20) public acceptedTokens;

    struct Vault {
        string tokenType; // "BDAG", "USDT", or "USDC"
        uint256 depositAmount;
        uint256 yieldEarned;
        bool healthMilestoneMet;
        bool active;
    }

    mapping(address => Vault) public userVaults;

    event VaultCreated(address indexed user, string tokenType, uint256 amount);
    event HealthMilestoneVerified(address indexed user);
    event FundsWithdrawn(address indexed user, uint256 amount);
    event YieldSimulated(address indexed user, uint256 yieldAmount);

    constructor(address _BDAG, address _USDT, address _USDC) {
        acceptedTokens["BDAG"] = IERC20(_BDAG);
        acceptedTokens["USDT"] = IERC20(_USDT);
        acceptedTokens["USDC"] = IERC20(_USDC);
    }

    /// @notice Create a vault using BDAG, USDT, or USDC
    function createVault(string memory tokenType, uint256 amount) external {
        require(amount > 0, "Deposit must be greater than zero");
        require(!userVaults[msg.sender].active, "Vault already exists");
        require(address(acceptedTokens[tokenType]) != address(0), "Unsupported token");

        IERC20 token = acceptedTokens[tokenType];
        token.transferFrom(msg.sender, address(this), amount);

        userVaults[msg.sender] = Vault({
            tokenType: tokenType,
            depositAmount: amount,
            yieldEarned: 0,
            healthMilestoneMet: false,
            active: true
        });

        emit VaultCreated(msg.sender, tokenType, amount);
    }

    /// @notice Verify health milestone (e.g., checkup completed)
    function verifyHealthMilestone(address user) external onlyOwner {
        require(userVaults[user].active, "Vault not active");
        userVaults[user].healthMilestoneMet = true;

        emit HealthMilestoneVerified(user);
    }

    /// @notice Withdraw funds after milestone is met
    function withdrawFunds() external {
        Vault storage vault = userVaults[msg.sender];
        require(vault.active, "Vault not active");
        require(vault.healthMilestoneMet, "Health milestone not met");

        uint256 totalAmount = vault.depositAmount + vault.yieldEarned;
        vault.active = false;

        IERC20 token = acceptedTokens[vault.tokenType];
        token.transfer(msg.sender, totalAmount);

        emit FundsWithdrawn(msg.sender, totalAmount);
    }

    /// @notice Simulate yield generation (for demo/testing)
    function simulateYield(address user, uint256 yieldAmount) external onlyOwner {
        require(userVaults[user].active, "Vault not active");
        userVaults[user].yieldEarned += yieldAmount;

        emit YieldSimulated(user, yieldAmount);
    }
}
