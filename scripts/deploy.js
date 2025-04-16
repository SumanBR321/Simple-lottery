const hre = require("hardhat");

async function main() {
  const Lottery = await hre.ethers.getContractFactory("Lottery");
  const lottery = await Lottery.deploy(); // deploys AND returns the instance

  console.log(`Lottery deployed to: ${lottery.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
