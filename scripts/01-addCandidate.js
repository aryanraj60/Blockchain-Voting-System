const { ethers, getNamedAccounts } = require("hardhat");

async function addCanidates() {
  const { organizer, candidate1, candidate2 } = await getNamedAccounts();

  //getting contract
  const votingContract = await ethers.getContract("VotingSystem", organizer);

  //Adding Canidates
  const candidate1Address = candidate1;
  const candidate1Name = "Aryan";
  const candidate1Party = "Bjp";
  const candidate1Image = "image url";

  const candidate2Address = candidate2;
  const candidate2Name = "Abhi";
  const canidate2Party = "Bjp";
  const candidate2Image = "image url";

  async function addCandidate(_address, _name, _partyName, _image) {
    await votingContract.addCandidate(_address, _name, _partyName, _image);
  }

  await addCandidate(
    candidate1Address,
    candidate1Name,
    candidate1Party,
    candidate1Image
  );
  await addCandidate(
    candidate2Address,
    candidate2Name,
    canidate2Party,
    candidate2Image
  );

  console.log("Two Canidates added with address.....");
  console.log("Canididate1 ", candidate1);
  console.log("Candidate2 ", candidate2);
}

try {
  addCanidates();
} catch (e) {
  console.log("Error", e);
}
