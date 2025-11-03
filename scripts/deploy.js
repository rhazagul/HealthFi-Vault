const hre = require("hardhat");

async function main() {
  const HealthFiVault = await hre.ethers.getContractFactory("HealthFiVault");
  const vault = await HealthFiVault.deploy(
    "0xStableTokenAddress", // Replace with actual stable token
    "0xBDAGTokenAddress"    // Replace with actual BDAG token
  );

  await vault.deployed();
  console.log("HealthFiVault deployed to:", vault.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
