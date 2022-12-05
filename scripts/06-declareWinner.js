const { ethers, getNamedAccounts } = require("hardhat");

async function declareWinner() {
  const { organizer } = await getNamedAccounts();

  const votingContract = await ethers.getContract("VotingSystem", organizer);

  //Declaring Winners

  const tx = await votingContract.declareWinner();

  console.log("Fetching winners addresses");
  const winnersAddresses = await votingContract.getWinnersAddresses();
  console.log("Winners Addresses", winnersAddresses);

  console.log("Fetching winner");
  const winner = await votingContract.getWinner();

  console.log("Winner", winner);
}

try {
  declareWinner();
} catch (e) {
  console.log(e);
}
