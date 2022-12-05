const { ethers, getNamedAccounts } = require("hardhat");

async function enableVotingPhase() {
  const { organizer } = await getNamedAccounts();

  const votingContract = await ethers.getContract("VotingSystem", organizer);

  console.log("Enabling Voting Phase!");

  const beforePhase = await votingContract.getElectionPhase();
  console.log("Current election phase", beforePhase.toString());
  const tx = await votingContract.startVotingPhase();

  const afterPhase = await votingContract.getElectionPhase();
  console.log("Voting phase activated!");
  console.log(
    "Election Phase after starting voting phase",
    afterPhase.toString()
  );
}

try {
  enableVotingPhase();
} catch (e) {
  console.log(e);
}
