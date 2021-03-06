// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Reputoshi is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Reputoshi", "RPT") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}