// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title HealthFiVault
 * @author —
 * @notice Vault system where users deposit accepted ERC20 tokens into vaults which can earn yield via pluggable strategies.
 *         Health milestones are marked by authorized verifiers (off-chain oracle/backends or on-chain verifiers).
 * @dev Uses SafeERC20, ReentrancyGuard, Pausable, and Ownable from OpenZeppelin.
 */

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Minimal interface a yield strategy adapter must implement for HealthFiVault to interact with it.
interface IYieldStrategy {
    /// @notice Deposit `amount` of `token` (token address passed for clarity). Caller must have transferred/approved tokens to the strategy or vault prior to call depending on adapter.
    /// @return actualDeposited amount the strategy considered deposited (may be less due to fees)
    function deposit(address token, uint256 amount) external returns (uint256 actualDeposited);

    /// @notice Withdraw `amount` of `token` from strategy back to caller (usually the vault contract).
    /// @return actualWithdrawn amount actually withdrawn
    function withdraw(address token, uint256 amount) external returns (uint256 actualWithdrawn);

    /// @notice Harvest accumulated yield of `token` and return it to caller (vault contract).
    /// @return yieldAmount amount of yield returned/harvested
    function harvest(address token) external returns (uint256 yieldAmount);
}

contract HealthFiVault is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    /// @notice Vault data structure
    struct Vault {
        uint256 id;             // unique id (monotonic)
        bytes32 tokenSymbol;    // bytes32 symbol key for acceptedTokens mapping
        uint256 depositAmount;  // principal amount recorded for this vault (in token smallest units)
        uint256 yieldEarned;    // accumulated yield accounted to this vault (harvested)
        address strategy;       // strategy address used for the deposit (if any)
        bool verified;          // whether health milestone verified
        bool active;            // whether vault still active (not withdrawn)
        uint256 createdAt;      // timestamp
    }

    /// @notice Mapping of token symbol => token contract
    mapping(bytes32 => IERC20) public acceptedTokens;

    /// @notice Mapping of token symbol => default yield strategy for that token (can be zero)
    mapping(bytes32 => IYieldStrategy) public tokenStrategy;

    /// @notice Per-user array of vaults (supporting multiple vaults per user)
    mapping(address => Vault[]) private userVaults;

    /// @notice Addresses allowed to verify milestones (oracle/backend/authority)
    mapping(address => bool) public verifiers;

    /// @notice Monotonic vault counter used for unique vault ids
    uint256 public vaultCounter;

    /* -------------------------------------------------------------------------- */
    /*                                 EVENTS                                     */
    /* -------------------------------------------------------------------------- */

    event TokenRegistered(bytes32 indexed symbol, address indexed token);
    event TokenUnregistered(bytes32 indexed symbol);
    event StrategySet(bytes32 indexed symbol, address indexed strategy);

    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    event VaultCreated(address indexed user, uint256 indexed vaultId, bytes32 tokenSymbol, uint256 amount, address strategy);
    event HealthVerified(address indexed verifier, address indexed user, uint256 indexed vaultId);
    event YieldHarvested(address indexed user, uint256 indexed vaultId, uint256 yieldAmount);
    event FundsWithdrawn(address indexed user, uint256 indexed vaultId, uint256 principalReturned, uint256 yieldReturned);

    event EmergencyWithdraw(address indexed owner, bytes32 indexed symbol, address to, uint256 amount);

    /* -------------------------------------------------------------------------- */
    /*                                  MODIFIERS                                 */
    /* -------------------------------------------------------------------------- */

    modifier onlyVerifier() {
        require(verifiers[msg.sender], "HealthFiVault: not a verifier");
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTOR                                 */
    /* -------------------------------------------------------------------------- */

    /// @notice Optionally initialize with token list and strategies.
    /// @param symbols bytes32 array of symbols (e.g., keccak256("USDT") or bytes32("USDT"))
    /// @param tokenAddresses corresponding token contract addresses
    /// @param strategies corresponding strategy addresses (0 for none)
    constructor(bytes32[] memory symbols, address[] memory tokenAddresses, address[] memory strategies) {
        require(symbols.length == tokenAddresses.length, "HealthFiVault: mismatch arrays");
        // strategies length may be <= symbols length
        for (uint256 i = 0; i < symbols.length; ++i) {
            acceptedTokens[symbols[i]] = IERC20(tokenAddresses[i]);
            emit TokenRegistered(symbols[i], tokenAddresses[i]);
            if (i < strategies.length && strategies[i] != address(0)) {
                tokenStrategy[symbols[i]] = IYieldStrategy(strategies[i]);
                emit StrategySet(symbols[i], strategies[i]);
            }
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Register or update an accepted token.
    function registerToken(bytes32 symbol, address token) external onlyOwner {
        require(token != address(0), "HealthFiVault: token-zero");
        acceptedTokens[symbol] = IERC20(token);
        emit TokenRegistered(symbol, token);
    }

    /// @notice Unregister a token (use with caution; existing vaults remain but future ops may fail).
    function unregisterToken(bytes32 symbol) external onlyOwner {
        delete acceptedTokens[symbol];
        emit TokenUnregistered(symbol);
    }

    /// @notice Set or update the default yield strategy adapter for a token.
    function setTokenStrategy(bytes32 symbol, address strategy) external onlyOwner {
        tokenStrategy[symbol] = IYieldStrategy(strategy);
        emit StrategySet(symbol, strategy);
    }

    /// @notice Add or remove a verifier address.
    function setVerifier(address verifier, bool allowed) external onlyOwner {
        verifiers[verifier] = allowed;
        if (allowed) emit VerifierAdded(verifier);
        else emit VerifierRemoved(verifier);
    }

    /* -------------------------------------------------------------------------- */
    /*                                 CORE LOGIC                                  */
    /* -------------------------------------------------------------------------- */

    /// @notice Create a new vault and deposit `amount` of `symbol`. Caller must have approved the vault contract beforehand.
    /// @param symbol bytes32 symbol of the registered token
    /// @param amount deposit amount (in token smallest units)
    /// @param useStrategyIfExists if true and a strategy exists for symbol, attempt to deposit principal into strategy
    function createVault(bytes32 symbol, uint256 amount, bool useStrategyIfExists) external whenNotPaused nonReentrant {
        require(amount > 0, "HealthFiVault: amount>0");
        IERC20 token = acceptedTokens[symbol];
        require(address(token) != address(0), "HealthFiVault: unsupported token");

        // pull tokens from user to this contract
        token.safeTransferFrom(msg.sender, address(this), amount);

        vaultCounter += 1;
        uint256 newId = vaultCounter;

        address strategyAddr = address(tokenStrategy[symbol]);
        uint256 principalKeptOnContract = amount; // assume initially all kept in contract

        // If user requested strategy and a strategy exists, attempt to deposit to strategy.
        if (useStrategyIfExists && strategyAddr != address(0)) {
            // Approve exact amount to strategy then call deposit; adapter will transfer from this contract or expect tokens in contract per its design.
            token.safeIncreaseAllowance(strategyAddr, amount);
            // Strategy adapter should accept the call and return actual deposited amount.
            uint256 depositedToStrategy = tokenStrategy[symbol].deposit(address(token), amount);
            // clear allowance (defense-in-depth)
            token.safeApprove(strategyAddr, 0);

            // if strategy accepted some or all, reduce the amount kept in contract
            if (depositedToStrategy > 0 && depositedToStrategy <= amount) {
                principalKeptOnContract = amount - depositedToStrategy;
            } else if (depositedToStrategy > amount) {
                // defensive fallback (shouldn't normally happen)
                principalKeptOnContract = 0;
            } else {
                // depositedToStrategy == 0 => all kept in contract
                principalKeptOnContract = amount;
            }
        }

        // Create vault record. We store depositAmount as amount (total principal for user).
        // strategy field indicates the strategy used for this deposit (may be zero).
        Vault memory v = Vault({
            id: newId,
            tokenSymbol: symbol,
            depositAmount: amount,   // total principal user deposited
            yieldEarned: 0,
            strategy: strategyAddr,
            verified: false,
            active: true,
            createdAt: block.timestamp
        });

        userVaults[msg.sender].push(v);

        emit VaultCreated(msg.sender, newId, symbol, amount, strategyAddr);
    }

    /// @notice Verifier marks a user's vault as verified (health milestone met).
    /// @param user address of vault owner
    /// @param vaultIndex index in user's vault array (0-based)
    function verifyHealth(address user, uint256 vaultIndex) external onlyVerifier whenNotPaused {
        require(vaultIndex < userVaults[user].length, "HealthFiVault: invalid index");
        Vault storage v = userVaults[user][vaultIndex];
        require(v.active, "HealthFiVault: vault not active");
        v.verified = true;
        emit HealthVerified(msg.sender, user, v.id);
    }

    /// @notice Harvest yield for a specific vault (calls underlying strategy.harvest and credits vault.yieldEarned).
    /// @dev Anyone can call; the strategy must transfer yield tokens to this contract on harvest.
    function harvestYield(address user, uint256 vaultIndex) public whenNotPaused nonReentrant returns (uint256) {
        require(vaultIndex < userVaults[user].length, "HealthFiVault: invalid index");
        Vault storage v = userVaults[user][vaultIndex];
        require(v.active, "HealthFiVault: vault not active");

        uint256 harvested = 0;
        if (v.strategy != address(0)) {
            // Strategy should transfer harvested yield to this contract and return amount
            harvested = IYieldStrategy(v.strategy).harvest(address(acceptedTokens[v.tokenSymbol]));
            if (harvested > 0) {
                v.yieldEarned += harvested;
                emit YieldHarvested(user, v.id, harvested);
            }
        }
        return harvested;
    }

    /// @notice Withdraws principal + yield for caller's vault at `vaultIndex`. Vault must be verified.
    /// @dev Harvests first (if necessary) then withdraws principal from strategy if needed and transfers token to user.
    function withdraw(uint256 vaultIndex) external whenNotPaused nonReentrant {
        require(vaultIndex < userVaults[msg.sender].length, "HealthFiVault: invalid index");
        Vault storage v = userVaults[msg.sender][vaultIndex];
        require(v.active, "HealthFiVault: not active");
        require(v.verified, "HealthFiVault: not verified");

        IERC20 token = acceptedTokens[v.tokenSymbol];
        require(address(token) != address(0), "HealthFiVault: token removed");

        // Harvest yield (if any)
        if (v.strategy != address(0)) {
            uint256 h = IYieldStrategy(v.strategy).harvest(address(token));
            if (h > 0) {
                v.yieldEarned += h;
                emit YieldHarvested(msg.sender, v.id, h);
            }
        }

        uint256 principalToReturn = v.depositAmount;
        uint256 yieldToReturn = v.yieldEarned;

        // Try to retrieve principal from strategy first if strategy holds funds
        if (v.strategy != address(0) && principalToReturn > 0) {
            uint256 withdrawn = IYieldStrategy(v.strategy).withdraw(address(token), principalToReturn);
            // withdrawn may be less than expected if strategy cannot return full amount
            if (withdrawn < principalToReturn) {
                // we set principalToReturn to the actual withdrawn amount and continue;
                // any shortfall remains in strategy (or may be irrecoverable) — adopt safe behavior
                principalToReturn = withdrawn;
            }
            // after withdraw, tokens should be in this contract
        }

        // Mark vault inactive BEFORE token transfer to prevent reentrancy
        v.active = false;

        // Compute total payout (note: if strategy returned less than deposit, user receives less principal)
        uint256 totalPayout = principalToReturn + yieldToReturn;

        // Transfer tokens to user
        token.safeTransfer(msg.sender, totalPayout);

        emit FundsWithdrawn(msg.sender, v.id, principalToReturn, yieldToReturn);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   VIEWS                                      */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns number of vaults owned by `user`.
    function getVaultCount(address user) external view returns (uint256) {
        return userVaults[user].length;
    }

    /// @notice Returns vault data for `user` at `index`.
    function getVault(address user, uint256 index) external view returns (Vault memory) {
        require(index < userVaults[user].length, "HealthFiVault: invalid index");
        return userVaults[user][index];
    }

    /* -------------------------------------------------------------------------- */
    /*                             EMERGENCY / OWNER                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Emergency withdraw tokens for a registered symbol to `to`. Only owner (multisig recommended).
    /// @param symbol token symbol key (bytes32)
    /// @param to recipient
    /// @param amount amount to send
    function emergencyWithdraw(bytes32 symbol, address to, uint256 amount) external onlyOwner nonReentrant {
        IERC20 token = acceptedTokens[symbol];
        require(address(token) != address(0), "HealthFiVault: token not registered");
        token.safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, symbol, to, amount);
    }

    /// @notice Pause contract (owner).
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause contract (owner).
    function unpause() external onlyOwner {
        _unpause();
    }
}
