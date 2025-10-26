const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying Community Insurance Pool with account:", deployer.address);

    // Define the initial funding amount for the pool
    const initialDepositEth = "0.5";
    const initialDepositWei = hre.ethers.parseEther(initialDepositEth);
    
    console.log(`Initial pool funding amount: ${initialDepositEth} ETH`);

    // 1. Get the Contract Factory for CommunityInsurancePool
    const CommunityInsurancePool = await hre.ethers.getContractFactory("CommunityInsurancePool");

    // 2. Deploy the contract
    // We include the {value} object to send Ether to the payable constructor.
    const pool = await CommunityInsurancePool.deploy({ value: initialDepositWei });

    // 3. Wait for the deployment to be confirmed on the network
    await pool.waitForDeployment();
    
    const contractAddress = await pool.getAddress();

    // 4. Log the deployed address and initial balance
    console.log("------------------------------------------");
    console.log("CommunityInsurancePool deployed to:", contractAddress);
    console.log(`Initial contract balance confirmed: ${initialDepositEth} ETH`);
    console.log("------------------------------------------");
}

// Execute the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
