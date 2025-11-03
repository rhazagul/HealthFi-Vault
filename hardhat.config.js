require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  networks: {
    bdag: {
      url: "https://rpc.bdag.network", // Replace with actual BDAG RPC
      accounts: ["0xYourPrivateKey"]   // Use env variables in production
    }
  }
};
