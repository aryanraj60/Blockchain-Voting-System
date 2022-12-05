const { ethers } = require("hardhat");

async function addVoters() {
  const { organizer, voter1, voter2, voter3, voter4, voter5, voter6 } =
    await getNamedAccounts();

  //getting contract
  //   const votingContract = await ethers.getContract("VotingSystem", organizer);

  //voters registration

  async function addVoter(_name, _image, voter) {
    const connectedContract = await ethers.getContract("VotingSystem", voter);
    await connectedContract.voterRegister(_name, _image);
    console.log("Voter Registered with add!", voter);
  }

  //Registering voters
  const voter1Name = "Kapil";
  const voter1Image = "image";

  const voter2Name = "Sushant";
  const voter2Image = "Image";

  const voter3Name = "Somya";
  const voter3Image = "Image";

  const voter4Name = "Priya";
  const voter4Image = "Image";

  const voter5Name = "Vishal";
  const voter5Image = "Image";

  const voter6Name = "Prashant";
  const voter6Image = "Image";

  await addVoter(voter1Name, voter1Image, voter1);
  await addVoter(voter2Name, voter2Image, voter2);
  await addVoter(voter3Name, voter3Image, voter3);
  await addVoter(voter4Name, voter4Image, voter4);
  await addVoter(voter5Name, voter5Image, voter5);
  await addVoter(voter6Name, voter6Image, voter6);
}

try {
  addVoters();
} catch (e) {
  console.log("Error", e);
}
