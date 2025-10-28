const hre = require("hardhat");

async function main() {
  console.log("Deploying Community Insurance Pool contract...");

  const Project = await hre.ethers.getContractFactory("Project");
  const project = await Project.deploy();

  await project.deployed();

  console.log("Community Insurance Pool deployed to:", project.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

    process.exit(1);
  });


