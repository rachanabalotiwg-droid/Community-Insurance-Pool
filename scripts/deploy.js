const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);

  // 1. Get the Contract Factory
  const TippingSystem = await hre.ethers.getContractFactory("TippingSystem");

  // 2. Deploy the contract
  const tippingSystem = await TippingSystem.deploy();

  // 3. Wait for the deployment to complete
  await tippingSystem.waitForDeployment();
  
  const contractAddress = await tippingSystem.getAddress();

  // 4. Log the deployed address
  console.log("TippingSystem deployed to:", contractAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
