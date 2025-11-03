// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HealthFiVault is Ownable {
    IERC20 public stableToken;
    IERC20 public BDAG;

    struct Vault {
        uint256 depositAmount;
        uint256 yieldEarned;
        bool healthMilestoneMet;
        bool active;
    }

    mapping(address => Vault) public userVaults;

    event VaultCreated(address indexed user, uint256 amount);
    event HealthMilestoneVerified(address indexed user);
    event FundsWithdrawn(address indexed user, uint256 amount);

    constructor(address _stableToken, address _BDAG) {
        stableToken = IERC20(_stableToken);
        BDAG = IERC20(_BDAG);
    }

    function createVault(uint256 amount) external {
        require(amount > 0, "Deposit must be greater than zero");
        stableToken.transferFrom(msg.sender, address(this), amount);

        userVaults[msg.sender] = Vault({
            depositAmount: amount,
            yieldEarned: 0,
            healthMilestoneMet: false,
            active: true
        });

        emit VaultCreated(msg.sender, amount);
    }

    function verifyHealthMilestone(address user) external onlyOwner {
        require(userVaults[user].active, "Vault not active");
        userVaults[user].healthMilestoneMet = true;

        emit HealthMilestoneVerified(user);
    }

    function withdrawFunds() external {
        Vault storage vault = userVaults[msg.sender];
        require(vault.healthMilestoneMet, "Health milestone not met");
        require(vault.active, "Vault not active");

        uint256 totalAmount = vault.depositAmount + vault.yieldEarned;
        stableToken.transfer(msg.sender, totalAmount);
        vault.active = false;

        emit FundsWithdrawn(msg.sender, totalAmount);
    }

    // Simulated yield function (replace with real strategy)
    function simulateYield(address user, uint256 yieldAmount) external onlyOwner {
        userVaults[user].yieldEarned += yieldAmount;
    }
}
