const { expect } = require("chai");

describe("HealthFiVault", function () {
  it("Should deploy and create a vault", async function () {
    const [owner, user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("MockToken");
    const stable = await Token.deploy();
    const bdag = await Token.deploy();

    const Vault = await ethers.getContractFactory("HealthFiVault");
    const vault = await Vault.deploy(stable.address, bdag.address);

    await stable.transfer(user.address, 1000);
    await stable.connect(user).approve(vault.address, 500);
    await vault.connect(user).createVault(500);

    const userVault = await vault.userVaults(user.address);
    expect(userVault.depositAmount).to.equal(500);
  });
});
