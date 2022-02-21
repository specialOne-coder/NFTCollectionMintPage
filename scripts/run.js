const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyNFT');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    //mint
    let trx = await nftContract.mint();
    //wait for mining
    await trx.wait();
    //mint
    trx = await nftContract.mint();
    //wait for mining
    await trx.wait();
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();