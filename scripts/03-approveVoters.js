const { ethers, getNamedAccounts } = require("hardhat");

async function approveVoters() {
  const { organizer, voter1, voter2, voter3, voter4, voter5, voter6 } =
    await getNamedAccounts();

  const votingContract = await ethers.getContract("VotingSystem", organizer);

  async function approveVoter(voter) {
    await votingContract.approveVoter(voter);
    console.log("Voter Approved", voter);
  }

  await approveVoter(voter1);
  await approveVoter(voter2);
  await approveVoter(voter3);
  await approveVoter(voter4);
  await approveVoter(voter5);
  await approveVoter(voter6);
}

try {
  approveVoters();
} catch (e) {
  console.log("Erro", e);
}
