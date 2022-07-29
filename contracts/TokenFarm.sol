//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


pragma solidity ^0.8.4;


contract TokenFarm is ERC20, Ownable{

    mapping(address=>uint)private _balances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint _totalSupply
        )ERC20(_name, _symbol){
            _mint(address(this), _totalSupply);
            _balances[address(this)] += _totalSupply;
        }




    function _transfer(address from, address to, uint amount)internal virtual override{
        _balances[from] -= amount;
        _balances[to] += amount;
        super._transfer(from, to, amount);
    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        address owner = address(this);
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }



    function balanceOf(address account) public view virtual override returns (uint256){
        return _balances[account];
    }
}
