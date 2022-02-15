const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { BANANA_TOKEN_CONTRACT_ADDRESS } = require("../constants");

async function main() {

    const bananaTokenContractAddress = BANANA_TOKEN_CONTRACT_ADDRESS;

    const exchangeContract = await ethers.getContractFactory('Exchange');

    const deployedExchangeContract = await exchangeContract.deploy(
        bananaTokenContractAddress
    );

    console.log("Exchange Contract Address ", deployedExchangeContract.address);

}

main()
    .then(() => process.exit(0))
    .catch((e) => {
        console.error(error);
        process.exit(1);
    }
    );