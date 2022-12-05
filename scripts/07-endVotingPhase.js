const { ethers, getNamedAccounts } = require("hardhat");

async function endElections() {
  const { organizer } = await getNamedAccounts();

  const votingContract = await ethers.getContract("VotingSystem", organizer);

  console.log(
    "Current phase before ending election",
    (await votingContract.getElectionPhase()).toString()
  );
  console.log("Ending elections and enabling ending phase");

  await votingContract.setElectionEndPhase();

  console.log(
    "Phase after ending elections",
    (await votingContract.getElectionPhase()).toString()
  );
}

try {
  endElections();
} catch (e) {
  console.log(e);
}
