🏥 HealthFiVault
HealthFiVault is a multi-token smart contract that allows users to deposit BDAG, USDT, or USDC to create personalized health-linked vaults. Vaults track deposits, simulate yield, and unlock withdrawals upon verified health milestones. The contract also supports fiat payments via backend integration.
________________________________________
🚀 Features
•	✅ Accepts BDAG, USDT, and USDC deposits
•	✅ Tracks user-specific vaults with deposit amount, yield, and health status
•	✅ Allows owner-triggered fiat deposits via depositViaFiat
•	✅ Simulates yield for testing/demo purposes
•	✅ Unlocks withdrawals only after health milestone verification
•	✅ Emits detailed events for transparency and off-chain tracking
________________________________________
🔐 Vault Lifecycle
1.	Deposit
o	Users deposit BDAG/USDT/USDC via createVault
o	Backend can deposit on behalf of users via depositViaFiat after credit card payment
2.	Yield Simulation
o	Owner can simulate yield using simulateYield
3.	Health Milestone Verification
o	Owner verifies milestone via verifyHealthMilestone
4.	Withdrawal
o	Users withdraw funds after milestone is met via withdrawFunds
________________________________________
🧩 Contract Structure
Vault Struct
struct Vault {
    string tokenType;
    uint256 depositAmount;
    uint256 yieldEarned;
    bool healthMilestoneMet;
    bool active;
}
Key Functions
•	createVault(string tokenType, uint256 amount)
•	depositViaFiat(address user, string tokenType, uint256 amount)
•	verifyHealthMilestone(address user)
•	simulateYield(address user, uint256 yieldAmount)
•	withdrawFunds()
________________________________________
🛠️ Deployment
constructor(
    address _BDAG,
    address _USDT,
    address _USDC
)
Pass the token contract addresses during deployment.
________________________________________
📦 Events
•	VaultCreated(address user, string tokenType, uint256 amount)
•	VaultCreatedViaFiat(address user, string tokenType, uint256 amount)
•	HealthMilestoneVerified(address user)
•	FundsWithdrawn(address user, uint256 amount)
•	YieldSimulated(address user, uint256 yieldAmount)
________________________________________
________________________________________
📄 License
MIT
