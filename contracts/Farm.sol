//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DataFarm.sol";
import "./TokenFarm.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity ^0.8.4;


contract Farm is Ownable, ReentrancyGuard{

    //import DataFarm Contract
    DataFarm private dataFarm;

    //import TokenFarm Contract
    TokenFarm private tokenFarm;

    //Month accept as farming date 1
    uint public farmingDate1;

    //Month accept as farming date 2
    uint public farmingDate2;

    //Percent for Token Rewards
    uint public tokenPercentRewards;

    //Percent for Eth Rewards
    uint public ethPercentRewards;

    //blocks in one day
    uint blockPerDay = 6400;


    //Passing FarmingDate1 in months(ex 5 for 5 months),
    //Passing FarmingDate2 in months(ex 10 for 10 months),
    //Passing tokenPercentRewards in a range of 0(not included) and 40(we will need it for Token rewards),
    //Passing ethPercentRewards in a range of 0(not included) and 5(we will need it for eth rewards)

    constructor(
        uint _farmingDate1,
        uint _farmingDate2,
        uint _tokenPercentRewards,
        uint _ethPercentRewards
        )
        payable{
            require(msg.value >= 1 ether, "Must to deposit some ether to start the Farm!");
            require(
                _ethPercentRewards > 0 &&
                _ethPercentRewards <= 10,
                "Interest Too High or Too Low. Set Interest between 0(not included) and 10%"
                );

            require(
                _tokenPercentRewards > 0 &&
                _tokenPercentRewards <= 40,
                "Interest Too High or Too Low. Set Interest between 0(not included) and 40%"
                );


            require(
                _tokenPercentRewards > _ethPercentRewards,
                "Tokens Rewards are always higher than Eth Rewards!"
                );


            farmingDate1 = _farmingDate1;
            farmingDate2 = _farmingDate2;
            tokenPercentRewards = _tokenPercentRewards;
            ethPercentRewards = _ethPercentRewards;
        }



    //Pointer for DataFarm Contract

    function initDataFarm(address _dataFarmAddress)public onlyOwner{
        dataFarm = DataFarm(_dataFarmAddress);
    }



    //Pointer for TokenFarm Contract

    function initTokenFarm(address _tokenFarmAddress)public onlyOwner{
        tokenFarm = TokenFarm(_tokenFarmAddress);
        tokenFarm.increaseAllowance(address(this), tokenFarm.balanceOf(_tokenFarmAddress));
    }



    //Internal function to calculate the end of farming

    function calculateTimeline(uint _dateChosen)internal{
        require(
            _dateChosen == farmingDate1 || _dateChosen == farmingDate2,
            "Date not Accepted!"
            );

        if(_dateChosen == farmingDate1){
            _dateChosen = blockPerDay * 30 * farmingDate1;
            uint finalDate = block.number + _dateChosen;
            dataFarm.setBlockForWithdraw(msg.sender, finalDate);
        }else if(_dateChosen == farmingDate2){
            _dateChosen = blockPerDay * 30 * farmingDate1;
            uint finalDate = block.number + _dateChosen;
            dataFarm.setBlockForWithdraw(msg.sender, finalDate);
        }
    }



    //Calculate Rewards(Token or Eth) in real time

    function calculateRewardsAmountByTime(address _userAddress)public view returns(uint rewards){
        string memory _paymentChosed = dataFarm.getPaymentChosed(_userAddress);
        uint withdrawTimeline = dataFarm.getBlockForWithdraw(_userAddress);
        uint depositTime = dataFarm.getBlockForDeposit(_userAddress);
        uint amountDeposit = dataFarm.getAmountUserDeposit(_userAddress);
        uint interval = withdrawTimeline - depositTime;
        uint reward1Block = amountDeposit / interval;
        uint calculateBlocksReward = block.number - depositTime;

        require(block.number > depositTime && block.number <= withdrawTimeline);

        uint totalRewardsNow;

        if(
            keccak256(bytes(_paymentChosed)) == keccak256(bytes("ETH")) ||
            keccak256(bytes(_paymentChosed)) == keccak256(bytes("Eth")) ||
            keccak256(bytes(_paymentChosed)) == keccak256(bytes("eth"))
            ){
                totalRewardsNow += reward1Block * calculateBlocksReward;
                rewards = totalRewardsNow;
                return rewards;
        }else if(
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("TOKEN")) ||
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("Token")) ||
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("token"))
            ){
                totalRewardsNow += reward1Block * calculateBlocksReward;
                rewards = totalRewardsNow;
                return rewards;
        }
    }



    //Calculate Total Rewards(Token or Eth). line 163 not an error of calculation

    function calculateRewardsAmount(
        address _userAddress,
        string memory _paymentChosed
        )internal{
            if(
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("ETH")) ||
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("Eth")) ||
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("eth"))
                ){
                    uint amountDeposit = dataFarm.getAmountUserDeposit(_userAddress);
                    uint referralPercent = ethPercentRewards;
                    uint totalRewards = (amountDeposit / 100) * referralPercent;
                    dataFarm.setRewardsTotalExpected(_userAddress, totalRewards);
                }
            else if(
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("TOKEN")) ||
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("Token")) ||
                keccak256(bytes(_paymentChosed)) == keccak256(bytes("token"))
                ){
                    uint amountDeposit = dataFarm.getAmountUserDeposit(_userAddress);
                    uint referralPercent = tokenPercentRewards;
                    uint totalRewards = amountDeposit * referralPercent;
                    dataFarm.setRewardsTotalExpected(_userAddress, totalRewards);
                }
            else{
                revert RightPaymentSetted(
                    "ETH",
                    "TOKEN",
                    _paymentChosed
                    );
                }
        }



    //Custom error

    error RightPaymentSetted(
        string paymentAccepted1,
        string paymentAccepted2,
        string paymentNotAccepted
    );



    //Farming Function.
    //Choose a farming date available and set it
    //Choose an accepted payment(Token, token, TOKEN, Eth, ETH, eth) and set it

    function farming(
        uint _withdrawTimeline,
        string memory _paymentChosed
        )external payable{
            require(msg.value > 0, "Can't farm 0 ether!");
            require(msg.sender != owner(), "Admin can't partecipate to the Farm");
            require(dataFarm.getUserInFarm(msg.sender) == false, "Already have some in farm");
            dataFarm.setUserInFarm(msg.sender, true);
            dataFarm.setAmountUserDeposit(msg.sender, msg.value);
            dataFarm.setBlockForDeposit(msg.sender);
            dataFarm.setPaymentChosed(msg.sender, _paymentChosed);
            calculateTimeline(_withdrawTimeline);
            calculateRewardsAmount(msg.sender, _paymentChosed);
            dataFarm.increaseFarmBalance(msg.value);
    }



    //Unfarming Function.
    //Some ether(5%) from rewards (if you choose eth as rewards) will be send to the farm contract as fee.
    //Some ether(2%) from deposit (if you choose Token as rewards) will be send to the farm contract as fee.

    function unfarming()public nonReentrant{
        require(dataFarm.getUserInFarm(msg.sender) == true, "Nothing In Farm!");
        if(
            keccak256(bytes(dataFarm.getPaymentChosed(msg.sender))) == keccak256(bytes("ETH")) ||
            keccak256(bytes(dataFarm.getPaymentChosed(msg.sender))) == keccak256(bytes("Eth")) ||
            keccak256(bytes(dataFarm.getPaymentChosed(msg.sender))) == keccak256(bytes("eth"))
        ){
            uint ethRewards = calculateRewardsAmountByTime(msg.sender);
            uint farmRewardsPercent = (ethRewards/100)*5;
            uint amountForUser = ethRewards - farmRewardsPercent;
            payable(msg.sender).transfer(amountForUser);
            payable(address(this)).transfer(farmRewardsPercent);
            delete(ethRewards);
            uint amountDeposit = dataFarm.getAmountUserDeposit(msg.sender);
            payable(msg.sender).transfer(amountDeposit);
            dataFarm.setUserInFarm(msg.sender, false);
            dataFarm.decreaseFarmBalance(amountDeposit);
            dataFarm.deleteFarm(msg.sender);

        }else if(
            keccak256(bytes(dataFarm.getPaymentChosed(msg.sender))) == keccak256(bytes("TOKEN")) ||
            keccak256(bytes(dataFarm.getPaymentChosed(msg.sender))) == keccak256(bytes("Token")) ||
            keccak256(bytes(dataFarm.getPaymentChosed(msg.sender))) == keccak256(bytes("token"))
        ){

            uint amountDeposit = dataFarm.getAmountUserDeposit(msg.sender);
            uint farmRewardsPercent = (amountDeposit/100)*2;
            uint amountForUser = amountDeposit - farmRewardsPercent;
            uint tokenRewards = calculateRewardsAmountByTime(msg.sender);
            payable(address(this)).transfer(farmRewardsPercent);
            tokenFarm.transferFrom(address(tokenFarm), msg.sender, tokenRewards);
            tokenRewards = 0;
            payable(msg.sender).transfer(amountForUser);
            dataFarm.setUserInFarm(msg.sender, false);
            dataFarm.decreaseFarmBalance(amountDeposit);
            dataFarm.deleteFarm(msg.sender);
        }
    }


    receive()external payable{}


    function farmBalance()public view returns(uint){
        return address(this).balance;
    }




}
