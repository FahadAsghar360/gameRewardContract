// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.1/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.1/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.1/token/ERC20/ERC20.sol";

contract PetVsPetsNFTs is ERC1155, Ownable {
    
     uint256[] supplies;
     uint256[] minted;
     uint256[] rates;
 
     ERC20 token = ERC20(0x85EAC5Ac2F758618dFa09bDbe0cf174e7d574D5B);

    constructor() ERC1155("https://subrays.com/nfts/{id}.json") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    
    function name() public view returns(string memory)
    {
        return "Pet Vs Pets NFTs";
    }

    function changeToken(ERC20 newToken) public onlyOwner{
        token = newToken;
    }

    function buyNFT(uint256 id)
        public
        payable
    {
        require(id <= supplies.length, "Token doesn't exist!");
        require(id > 0, "Token doesn't exist!");
        uint256 index = id - 1;

        require(minted[index] + 1 <= supplies[index], "Not enough supply");
        require(token.balanceOf(msg.sender) >= rates[index] , "Not enough balance to buy");

        token.transferFrom(payable(msg.sender),address(this), rates[index]);
        _mint(msg.sender, id, 1, "");
        minted[index] += 1; 
    }

    function withdraw() public onlyOwner{
        require (token.balanceOf(address(this)) > 0, "Balance is zero.");
        token.transfer(payable(owner()), token.balanceOf(address(this)));
    }

    function addNFT(uint256 supply,uint256 rate) 
       public 
       onlyOwner
    {
        require(supply > 0, "Supply can't be zero or negative");
        require(rate > 0, "Rate can't be zero or negative");

        supplies.push(supply);
        minted.push(0);
        rates.push(rate);
    }

    function getRate(uint256 id) public view returns (uint256) 
    {
        uint256 index = id - 1;
        return rates[index];
    }
    function getSupply(uint256 id) public view returns (uint256) 
    {
        uint256 index = id - 1;
        return supplies[index];
    }
    function getMinted(uint256 id) public view returns (uint256) 
    {
        uint256 index = id - 1;
        return minted[index];
    }

    function addSupply(uint256 id, uint256 supplyToAdd) public onlyOwner
    {
        require(supplyToAdd > 0, "Supply can't be zero or negative");
        require(id <= supplies.length, "Token doesn't exist!");
        require(id > 0, "Token doesn't exist!");
        
        supplies[id - 1] += supplyToAdd;
    }

    function changeRate(uint256 id, uint256 newRate) public onlyOwner
    {
        require(newRate > 0, "Rate can't be zero or negative");
        require(id <= supplies.length, "Token doesn't exist!");
        require(id > 0, "Token doesn't exist!");

        rates[id - 1] = newRate;
    }
}
