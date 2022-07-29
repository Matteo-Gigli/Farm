//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TokenFarm.sol";
import "./Farm.sol";

pragma solidity ^0.8.4;


contract DataFarm is Ownable{

    //TokenFarm token Amount
    uint tokenFarmBalance;

    //Total amount Eth in Farming time
    uint totalAmountDepositatedInFarm;

    //Struct for user
    struct User{
        uint amountDepositated;
        uint depositTime;
        uint withdrawTimeline;
        uint rewardsTotalExpected;
        string paymentChosed;
    }

    //mapping for struct
    mapping(address=>User) public userDetail;

    //map for user already in farming time
    mapping(address=>bool) private userInFarm;

    //import TokenFarm Contract
    TokenFarm private tokenFarm;

    //import Farm Contract
    Farm private farm;

    //modifier, only Farm Contract can call some functions
    modifier onlyFarm{
        msg.sender == address(farm);
        _;
    }


    constructor(){

    }



    //Pointer for TokenFarm Contract
    function initTokenFarm(address _tokenFarmAddress)public onlyOwner{
        tokenFarm = TokenFarm(_tokenFarmAddress);
    }



    //Pointer for Farm Contract
    function initFarm(address payable _farmAddress)public onlyOwner{
        farm = Farm(_farmAddress);
    }



    //get Total Supply of Tokens
    function getTotalSupplyTokenFarm()public view returns(uint){
        return tokenFarm.totalSupply();
    }



    //Setting Amount Depositated from user
    function setAmountUserDeposit(address _userAddress, uint _amountDeposit)public onlyFarm{
        userDetail[_userAddress].amountDepositated += _amountDeposit;
    }



    //Get Amount Depositated from user
    function getAmountUserDeposit(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].amountDepositated;
    }



    //Setting Block number for Deposit from user
    function setBlockForDeposit(address _userAddress)public onlyFarm{
        userDetail[_userAddress].depositTime = block.number;
    }



    //Get Block number for Deposit from user
    function getBlockForDeposit(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].depositTime;
    }



    //Setting Block number for Withdraw from user
    function setBlockForWithdraw(address _userAddress, uint _withdrawBlock)public onlyFarm{
        userDetail[_userAddress].withdrawTimeline = _withdrawBlock;
    }



    //Get Block number for Withdraw from user
    function getBlockForWithdraw(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].withdrawTimeline;
    }



    //Setting Payment Chosed for Rewards from user
    function setPaymentChosed(address _userAddress, string memory _paymentChosed)public onlyFarm{
        userDetail[_userAddress].paymentChosed = _paymentChosed;
    }



    //Get Payment Chosed for Rewards from user
    function getPaymentChosed(address _userAddress)public view returns(string memory){
        return userDetail[_userAddress].paymentChosed;
    }



    //Setting Total Rewards Expected from user
    function setRewardsTotalExpected(address _userAddress, uint _amount)public onlyFarm{
        userDetail[_userAddress].rewardsTotalExpected = _amount;
    }



    //Get Total Rewards Expected from user
    function getRewardsTotalExpected(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].rewardsTotalExpected;
    }



    //Setting User In Farm
    function setUserInFarm(address _userAddress, bool _inFarm)public onlyFarm{
        userInFarm[_userAddress] = _inFarm;
    }



    //Get User In Farm
    function getUserInFarm(address _userAddress)public view returns(bool){
        return userInFarm[_userAddress];
    }



    //Increase Eth in Farming
    function increaseFarmBalance(uint _amount)public onlyFarm{
        totalAmountDepositatedInFarm += _amount;
    }



    //Decrease Eth in Farming
    function decreaseFarmBalance(uint _amount)public onlyFarm{
        totalAmountDepositatedInFarm -= _amount;
    }



    //get total Amount Depositated In Farm;
    function getAmountInFarm()public view returns(uint){
        return totalAmountDepositatedInFarm;
    }



    //Delete Farm
    function deleteFarm(address _userAddress)public onlyFarm{
        delete userDetail[_userAddress];
    }

}



