module.exports = async ({ getNamedAccounts, deployments }) => {
  const { organizer } = await getNamedAccounts();
  const { log, deploy } = deployments;

  log("Deploying voting contract");

  const votingContract = await deploy("VotingSystem", {
    from: organizer,
    args: [],
    log: true,
  });

  log("Voting Contract deployed to ", votingContract.address);
};
