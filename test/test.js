const { expect } = require("chai");
const { expectRevert } = require('@openzeppelin/test-helpers');



describe("Setting some test for the functionality of the contracts", function(){


    let Farm, farm, TokenFarm, tokenFarm, DataFarm, dataFarm, owner, account1,
        account2, account3, account4, account5;


    before(async()=>{

        [owner, account1, account2, account3, account4, account5] = await ethers.getSigners();

        Farm = await ethers.getContractFactory("Farm");
        TokenFarm = await ethers.getContractFactory("TokenFarm");
        DataFarm = await ethers.getContractFactory("DataFarm");

        farm = await Farm.deploy(5, 10, 40, 5, {value: "10000000000000000000"});
        tokenFarm = await TokenFarm.deploy("MyToken", "MTK", "1000000000000000000000000");
        dataFarm = await DataFarm.deploy();


        await farm.deployed();
        await tokenFarm.deployed();
        await dataFarm.deployed();


        await farm.initDataFarm(dataFarm.address);
        await farm.initTokenFarm(tokenFarm.address);
        await dataFarm.initTokenFarm(tokenFarm.address);
        await dataFarm.initFarm(farm.address);
    })



    it("Should have a farm balance of 10 ether", async()=>{
        let farmBalance = await ethers.provider.getBalance(farm.address);
        expect(farmBalance).to.be.equal("10000000000000000000")
    })


    it("Should revert the farm, if the withdraw time is different from farmingTime1 setted", async() =>{
        await(expectRevert(farm.connect(account1).farming(6, "Token", {value: "10000000000000000000"}),
            "Date not Accepted!"));

        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal(0);
        console.log("");
        console.log("No Deposit cause Date");
    })



    it("Should revert the farm, if the withdraw time is different from farmingTime2 setted", async() =>{
        await(expectRevert(farm.connect(account1).farming(6, "Token", {value: "10000000000000000000"}),
            "Date not Accepted!"));

        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal(0);
        console.log("");
        console.log("No Deposit cause Date");

    })



    it("Should revert the farm, if the value is 0", async() =>{
        await(expectRevert(farm.connect(account1).farming(5, "Token", {value: "0"}),
            "Can't farm 0 ether!"));

        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal(0);
        console.log("");
        console.log("No Deposit if you try to deposit 0");
    })



    it("Should revert the farm, if the admin try to partecipate at the farm", async() =>{
        await(expectRevert(farm.connect(owner).farming(5, "Token", {value: "10000000000000000000"}),
            "Admin can't partecipate to the Farm"));

        let userDetail = await dataFarm.userDetail(owner.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal(0);
        console.log("");
        console.log("Admin can't Farm");
    })




    it("Should revert the farm, if the name of the payment choosed is different from:" +
        "Token, TOKEN, token, ETH, eth, Eth", async() =>{

        await(expectRevert(farm.connect(account1).farming(5, "ToKeN", {value: "10000000000000000000"}),
            'RightPaymentSetted("ETH", "TOKEN", "ToKeN")'
        ));

        await(expectRevert(farm.connect(account1).farming(5, "EtH", {value: "10000000000000000000"}),
            'RightPaymentSetted("ETH", "TOKEN", "EtH")'
        ));

        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal(0);
        console.log("");
        console.log("Payment Choosed not recognize!");
    })



    it("Should be able to put your ether in farm and get eth as reward", async()=>{

        await(farm.connect(account1).farming(5, "Eth", {value: "10000000000000000000"}));

        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        let timelineWithdrawBlock = userDetail.withdrawTimeline;
        let depositBlock = userDetail.depositTime;
        let totalRewardsAtTimeline = userDetail.rewardsTotalExpected;
        let paymentChosed = userDetail.paymentChosed;

        let actualBlock = await ethers.provider.getBlockNumber();
        let withdrawBlock = actualBlock + 960000;

        let farmBalance = await ethers.provider.getBalance(farm.address);


        expect(farmBalance).to.be.equal("20000000000000000000");
        expect(userDeposit).to.be.equal("10000000000000000000");
        expect(timelineWithdrawBlock.toNumber()).to.be.equal(withdrawBlock);
        expect(depositBlock).to.be.equal(actualBlock);
        expect(totalRewardsAtTimeline).to.be.equal("500000000000000000");
        expect(paymentChosed).to.be.equal("Eth");
        console.log("");
        console.log("Farming with Eth Rewards Started for Account 1!");
        console.log("Starting Block Number of farming ETH rewards: " + actualBlock);

    })



    it("Should mint some block (98304 Blocks)", async()=>{
        let actualBlock = await ethers.provider.getBlockNumber();
        console.log("");
        console.log(actualBlock);
        await ethers.provider.send('hardhat_mine', ["0x18000"]);
        let actualBlock2 = await ethers.provider.getBlockNumber();
        console.log(actualBlock2);
    })


    it("Should be able to unfarming and receive ETH as Rewards", async()=>{

        let calcRewards = await farm.calculateRewardsAmountByTime(account1.address);
        console.log("")
        console.log("Rewards Calculation Ether: ", calcRewards);

        let percentForFarm = calcRewards.div(100).mul(10);
        console.log("");
        console.log("Rewards For Farm in Ether: ", percentForFarm);

        let amountDeposit = await dataFarm.getAmountUserDeposit(account1.address);
        console.log("");
        console.log("Deposit amount: ", amountDeposit);

        let accBalance = await ethers.provider.getBalance(account1.address);
        console.log("");
        console.log("Balance Account Eth Before Unfarming: ", accBalance);

        let farmBalance = await ethers.provider.getBalance(farm.address);
        console.log("");
        console.log("Farm Balance Eth Before Unfarming: ", farmBalance);

        let amountInFarmBeforeUnfarming = await dataFarm.getAmountInFarm();
        console.log("");
        console.log("Amount Eth in Farm before Unfarming: ", amountInFarmBeforeUnfarming);

        let tx = await farm.connect(account1).unfarming();
        let response = await tx.wait();
        let gasCost = response.gasUsed.mul(response.effectiveGasPrice);
        console.log("");
        console.log("Gas Transaction Cost: ", gasCost);


        let farmBalance2 = await ethers.provider.getBalance(farm.address);
        console.log("");
        console.log("Farm Balance Eth After Unfarming: ", farmBalance2);

        let amountInFarmAfterUnfarming = await dataFarm.getAmountInFarm();
        console.log("");
        console.log("Amount Eth in Farm before Unfarming: ", amountInFarmAfterUnfarming);

        let amountDepositAfterUnfarming = await dataFarm.getAmountUserDeposit(account1.address);
        console.log("");
        console.log("Deposit amount After Unfarming Eth Rewards: ", amountDepositAfterUnfarming);

        let calculateAll = accBalance.add(amountDeposit).add(calcRewards).add(gasCost);
        console.log("")
        console.log("Range Max for our eth balance(range for gas fee)...", calculateAll);

        let accBalance2 = await ethers.provider.getBalance(account1.address);
        console.log("");
        console.log("Balance Account Eth after unfarming: ", accBalance2);

        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        let depositBlock = userDetail.depositTime;
        let totalRewardsAtTimeline = userDetail.rewardsTotalExpected;
        expect(userDeposit).to.be.equal("0");
        expect(depositBlock).to.be.equal(0);
        expect(totalRewardsAtTimeline).to.be.equal("0");
        expect(amountInFarmBeforeUnfarming).to.be.equal("10000000000000000000");
        expect(amountInFarmAfterUnfarming).to.be.equal("0");

        //There are gas cost all around of the test, so we are giving a "range" at our address balance
        expect(accBalance2).to.be.closeTo(accBalance, calculateAll);
        expect(amountDepositAfterUnfarming).to.be.equal(0);
    })



    it("Should revert the unfarming, if there is anything in farm ", async() =>{
        await(expectRevert(farm.connect(account1).unfarming(), "Nothing In Farm!"));
        let userDetail = await dataFarm.userDetail(account1.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal(0);
        console.log("");
        console.log("Nothing in Farm");
    })








    //Token Rewards

    it("Should be able to put your ether in farm and get Token as reward", async()=>{

        await(farm.connect(account2).farming(5, "Token", {value: "20000000000000000000"}));

        let userDetail = await dataFarm.userDetail(account2.address);
        let userDeposit = userDetail.amountDepositated;
        let timelineWithdrawBlock = userDetail.withdrawTimeline;
        let depositBlock = userDetail.depositTime;
        let totalRewardsAtTimeline = userDetail.rewardsTotalExpected;
        let paymentChosed = userDetail.paymentChosed;

        let actualBlock = await ethers.provider.getBlockNumber();
        let withdrawBlock = actualBlock + 960000;

        expect(userDeposit).to.be.equal("20000000000000000000");
        expect(timelineWithdrawBlock.toNumber()).to.be.equal(withdrawBlock);
        expect(depositBlock).to.be.equal(actualBlock);
        expect(totalRewardsAtTimeline).to.be.equal("800000000000000000000");
        expect(paymentChosed).to.be.equal("Token");
        console.log("");
        console.log("Farming with Token Rewards Started for Account 2!");
        console.log("Starting Block Number of farming Token rewards: " + actualBlock);
        //console.log("Total rewards at the end in token ", totalRewardsAtTimeline);

    })



    it("Should mint some block (98304 Blocks)", async()=>{
        let actualBlock = await ethers.provider.getBlockNumber();
        console.log("");
        console.log(actualBlock);
        await ethers.provider.send('hardhat_mine', ["0x18000"]);
        let actualBlock2 = await ethers.provider.getBlockNumber();
        console.log(actualBlock2);
    })


    it("Should revert the farm, you have already some in farm", async() =>{
        await(expectRevert(farm.connect(account2).farming(5, "Token", {value: "20000000000000000000"}),
            "Already have some in farm"));

        await(expectRevert(farm.connect(account2).farming(5, "eth", {value: "20000000000000000000"}),
            "Already have some in farm"));

        let userDetail = await dataFarm.userDetail(account2.address);
        let userDeposit = userDetail.amountDepositated;
        expect(userDeposit).to.be.equal("20000000000000000000");
        console.log("");
        console.log("Already some in Farm");
    })





    it("Should be able to unfarming and receive Token as Rewards", async()=>{

        let calcRewards = await farm.calculateRewardsAmountByTime(account2.address);
        console.log("")
        console.log("Rewards Calculation Token: ", calcRewards);

        let amountDeposit = await dataFarm.getAmountUserDeposit(account2.address);
        console.log("");
        console.log("Deposit amount: ", amountDeposit);

        let percentForFarm = amountDeposit.div(100).mul(2);
        console.log("");
        console.log("Rewards For Farm in Ether: ", percentForFarm);

        let accBalanceEth = await ethers.provider.getBalance(account2.address);
        console.log("");
        console.log("Balance Account Eth Before Unfarming: ", accBalanceEth);

        let accBalanceToken = await tokenFarm.balanceOf(account2.address);
        console.log("");
        console.log("Balance Account Token Before Unfarming: ", accBalanceToken);

        let tokenFarmBalance = await tokenFarm.balanceOf(tokenFarm.address);
        console.log("");
        console.log("Balance TokenFarm Before Unfarming: ", tokenFarmBalance);

        let farmBalance = await ethers.provider.getBalance(farm.address);
        console.log("");
        console.log("Farm Balance Eth before Unfarming: ", farmBalance);

        let amountInFarmBeforeUnfarming = await dataFarm.getAmountInFarm();
        console.log("");
        console.log("Amount Eth in Farm before Unfarming: ", amountInFarmBeforeUnfarming);


        let tx = await farm.connect(account2).unfarming();
        await tx.wait();


        let farmBalance2 = await ethers.provider.getBalance(farm.address);
        console.log("");
        console.log("Farm Balance Eth After Unfarming: ", farmBalance2);

        let accBalanceTokenAfterUnfarming = await tokenFarm.balanceOf(account2.address);
        console.log("");
        console.log("Balance Account Token After Unfarming: ", accBalanceTokenAfterUnfarming);
        
        let accBalanceEthAfterUnfarming = await ethers.provider.getBalance(account2.address);
        console.log("");
        console.log("Balance Account Eth After Unfarming: ", accBalanceEthAfterUnfarming);

        let tokenFarmTokenBalanceAfterUnfarming = await tokenFarm.balanceOf(tokenFarm.address);
        console.log("");
        console.log("Balance Token TokenFarm After Unfarming: ", tokenFarmTokenBalanceAfterUnfarming);

        let amountInFarmAfterUnfarming = await dataFarm.getAmountInFarm();
        console.log("");
        console.log("Amount Eth in Farm after Unfarming: ", amountInFarmAfterUnfarming);

        let amountDepositAfterUnfarming = await dataFarm.getAmountUserDeposit(account2.address);
        console.log("");
        console.log("Deposit amount After Unfarming Eth Rewards: ", amountDepositAfterUnfarming);

        let userDetail = await dataFarm.userDetail(account2.address);
        let userDeposit = userDetail.amountDepositated;
        let depositBlock = userDetail.depositTime;
        let totalRewardsAtTimeline = userDetail.rewardsTotalExpected;

        expect(amountDepositAfterUnfarming).to.be.equal("0");
        expect(userDeposit).to.be.equal("0");
        expect(depositBlock).to.be.equal(0);
        expect(totalRewardsAtTimeline).to.be.equal("0");
        expect(amountInFarmBeforeUnfarming).to.be.equal("20000000000000000000");
        expect(amountInFarmAfterUnfarming).to.be.equal("0");

    })



    it("Should pass tokens to another address", async()=>{
        let farmBalance2 = await ethers.provider.getBalance(farm.address);
        console.log("");
        console.log("Farm Balance After Unfarming: ", farmBalance2);
    })

})