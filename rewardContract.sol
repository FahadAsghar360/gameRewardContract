// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC1155/extensions/ERC1155Burnable.sol";

contract TokenContract is ERC1155, Ownable, ERC1155Burnable {
    uint256 supply = 100000;
    uint256 minted = 0;
    uint256 rate = 1 ether;

    constructor() ERC1155("https://subrays.com/token_data/token_metadata.json") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function buyTicket(uint256 amount)
        public
        payable
    {
        require(amount > 0, "The amount can't be zero.");
        require(minted + amount <= supply, "Not enough supply");
        require(msg.value >= amount * rate , "Not enough balance to buy");

        _mint(msg.sender, 1, amount, "");
        minted += amount;
    }

     function sellTicket(uint256 amount)
        public
        payable
    {
        require(amount > 0, "The amount can't be zero.");
        require(minted - amount >= 0, "Minted tokens are less than your amount");
        require(address(this).balance >= amount * rate , "Not enough balance in contract");

        burn(msg.sender, 1, amount);
        minted -= amount;

        payable(msg.sender).transfer(amount * rate);
    }

    function withdraw() public onlyOwner{
        require (address(this).balance > 0, "Balance is zero.");
        payable(owner()).transfer(address(this).balance);
    }


    function changeSupply(uint256 newSupply) public onlyOwner{
        supply = newSupply;
    }

    function changeRate(uint256 newRate) public onlyOwner{
        rate = newRate;
    }
}
