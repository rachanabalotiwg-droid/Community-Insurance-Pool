const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);
  console.log("Account balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());

  // 1. Define the initial deposit amount (e.g., 0.5 ETH)
  // This will be the initial seed money in the insurance pool.
  const initialDeposit = hre.ethers.parseEther("0.5");

  // 2. Get the Contract Factory for CommunityInsurancePool
  const CommunityInsurancePool = await hre.ethers.getContractFactory("CommunityInsurancePool");

  // 3. Deploy the contract, passing the initial deposit using the 'value' key
  const pool = await CommunityInsurancePool.deploy({ value: initialDeposit });

  // 4. Wait for the deployment to be confirmed on the network
  await pool.waitForDeployment();
  
  const contractAddress = await pool.getAddress();

  // 5. Log the deployed address and the initial balance
  console.log("CommunityInsurancePool deployed to:", contractAddress);
  console.log(`Deployed with an initial pool fund of ${hre.ethers.formatEther(initialDeposit)} ETH.`);
}

// Execute the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

