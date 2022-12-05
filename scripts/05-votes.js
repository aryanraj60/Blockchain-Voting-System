const { ethers } = require("hardhat");

async function votes() {
  const {
    deployer,
    voter1,
    voter2,
    voter3,
    voter4,
    voter5,
    voter6,
    candidate1,
    candidate2,
  } = await getNamedAccounts();

  const contractVoting = await ethers.getContract("VotingSystem", deployer);

  async function vote(_candidateAddress, _candidateId, voter) {
    const connectedContract = await ethers.getContract("VotingSystem", voter);
    await connectedContract.vote(_candidateAddress, _candidateId);
    console.log(`Voter: ${voter} voted to ${_candidateId} `);
  }

  //CANDIDATES
  const candidate1Address = candidate1;
  const candidate1Id = 1;

  const candidate2Address = candidate2;
  const candidate2Id = 2;

  //Votes
  await vote(candidate1Address, candidate1Id, voter1);
  await vote(candidate1Address, candidate1Id, voter2);
  await vote(candidate1Address, candidate1Id, voter3);
  await vote(candidate2Address, candidate2Id, voter4);
  await vote(candidate2Address, candidate2Id, voter5);
  await vote(candidate2Address, candidate2Id, voter6);

  console.log("Getting votes from blockchain");
  const candidate1FromCall = await contractVoting.getCandidate(
    candidate1Address
  );
  const candidate1Votes = candidate1FromCall.totalVotes;
  console.log("Candidate1 total Votes", candidate1Votes.toString());

  const candidate2FromCAll = await contractVoting.getCandidate(
    candidate2Address
  );
  const candidate2Votes = candidate2FromCAll.totalVotes;

  console.log("Candidate2 total Votes", candidate2Votes.toString());
}

try {
  votes();
} catch (e) {
  console.log("Error", e);
}
