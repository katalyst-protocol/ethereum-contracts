// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CustomToken
 * @dev ERC20 Token with minting and transfer capabilities controlled by owner
 */
contract KPT is ERC20, Ownable {
    
    event TokensMinted(address indexed to, uint256 amount);
    event TokensTransferredByOwner(address indexed from, address indexed to, uint256 amount);

    constructor(
        string memory name, 
        string memory symbol,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {}
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
       
        emit TokensMinted(to, amount);
    }

    function transferByOwner(address from, address to, uint256 amount) public onlyOwner {
        _transfer(from, to, amount);
        
        // Emit custom event
        emit TokensTransferredByOwner(from, to, amount);
    }
}