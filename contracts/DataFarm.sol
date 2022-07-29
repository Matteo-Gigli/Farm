//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TokenFarm.sol";
import "./Farm.sol";

pragma solidity ^0.8.4;


contract DataFarm is Ownable{

    uint tokenFarmBalance;

    uint totalAmountDepositatedInFarm;

    struct User{
        uint amountDepositated;
        uint depositTime;
        uint withdrawTimeline;
        uint rewardsTotalExpected;
        string paymentChosed;
    }

    mapping(address=>User) public userDetail;

    mapping(address=>bool) private userInFarm;

    TokenFarm private tokenFarm;

    Farm private farm;

    modifier onlyFarm{
        msg.sender == address(farm);
        _;
    }


    constructor(){

    }


    function initTokenFarm(address _tokenFarmAddress)public onlyOwner{
        tokenFarm = TokenFarm(_tokenFarmAddress);
    }



    function initFarm(address payable _farmAddress)public onlyOwner{
        farm = Farm(_farmAddress);
    }



    function getTotalSupplyTokenFarm()public view returns(uint){
        return tokenFarm.totalSupply();
    }



    function setAmountUserDeposit(address _userAddress, uint _amountDeposit)public onlyFarm{
        userDetail[_userAddress].amountDepositated += _amountDeposit;
    }



    function getAmountUserDeposit(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].amountDepositated;
    }



    function setBlockForDeposit(address _userAddress)public onlyFarm{
        userDetail[_userAddress].depositTime = block.number;
    }



    function getBlockForDeposit(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].depositTime;
    }



    function setBlockForWithdraw(address _userAddress, uint _withdrawBlock)public onlyFarm{
        userDetail[_userAddress].withdrawTimeline = _withdrawBlock;
    }




    function getBlockForWithdraw(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].withdrawTimeline;
    }



    function setPaymentChosed(address _userAddress, string memory _paymentChosed)public onlyFarm{
        userDetail[_userAddress].paymentChosed = _paymentChosed;
    }



    function getPaymentChosed(address _userAddress)public view returns(string memory){
        return userDetail[_userAddress].paymentChosed;
    }



    function setRewardsTotalExpected(address _userAddress, uint _amount)public onlyFarm{
        userDetail[_userAddress].rewardsTotalExpected = _amount;
    }



    function getRewardsTotalExpected(address _userAddress)public view returns(uint){
        return userDetail[_userAddress].rewardsTotalExpected;
    }


    function setUserInFarm(address _userAddress, bool _inFarm)public onlyFarm{
        userInFarm[_userAddress] = _inFarm;
    }


    function getUserInFarm(address _userAddress)public view returns(bool){
        return userInFarm[_userAddress];
    }



    function increaseFarmBalance(uint _amount)public onlyFarm{
        totalAmountDepositatedInFarm += _amount;
    }



    function decreaseFarmBalance(uint _amount)public onlyFarm{
        totalAmountDepositatedInFarm -= _amount;
    }



    function getAmountInFarm()public view returns(uint){
        return totalAmountDepositatedInFarm;
    }



    function deleteFarm(address _userAddress)public onlyFarm{
        delete userDetail[_userAddress];
    }

}



