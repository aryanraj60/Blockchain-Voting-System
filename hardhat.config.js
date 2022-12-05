require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      chainId: 31337,
      url: "http://127.0.0.1:8545/",
    },
  },
  namedAccounts: {
    organizer: {
      default: 0,
    },
    candidate1: {
      default: 1,
    },
    candidate2: {
      default: 2,
    },
    voter1: {
      default: 3,
    },
    voter2: {
      default: 4,
    },
    voter3: {
      default: 5,
    },
    voter4: {
      default: 6,
    },
    voter5: {
      default: 7,
    },
    voter6: {
      default: 8,
    },
  },
};
