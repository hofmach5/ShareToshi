// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sharetoshi is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Sharetoshi", "SHR") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    address private netWorkAdress  = 0xDedc86D2436FEF2Ca4bc3c84f2eF2FdDD3F2a8c1;

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function getInitialSupply(address recipient) external{
        uint256 amount = 10000 * 10 ** decimals();
        
        if (balanceOf(recipient)<amount){
            mint(recipient, amount);
        }
    }

    function performSHRTransaction(address recipient, uint256 amount) external {
        //net-Transaction to the provider
        transfer(recipient, amount);

        //burn
        uint burnAmount = amount /uint(1000);
        burn(burnAmount);

        //Network fee
        uint networkAmount = amount /uint(1000);
        transfer(netWorkAdress, networkAmount);
    }

    function calculateGrossDeposit(uint256 amount) public pure returns (uint256){
        //burn
        uint burnAmount = amount /uint(1000);

        //Network fee
        uint networkAmount = amount /uint(1000);
        uint256 totalDepositRequired = amount + burnAmount + networkAmount;

        return totalDepositRequired;
    }
}