// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC1155/extensions/ERC1155Burnable.sol";

contract TokenContract is ERC1155, Ownable, ERC1155Burnable {

    uint256 minted = 0;
    uint256 rate = 1 ether;
    uint256[] matchIDs;
    bool isPaused;

    constructor() ERC1155("https://subrays.com/token_data/token_metadata.json") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause(bool value) public onlyOwner{
        isPaused = value;
    }

// mint the token and take money from user 
    function buyTicket(uint256 amount)
        public
        payable
    {
        require(isPaused == false, "The contract is paused by owner");
        require(amount > 0, "The amount can't be zero.");
        require(msg.value >= amount * rate , "Not enough balance to buy");

        _mint(msg.sender, 1, amount, "");
        minted += amount;
    }

// burn the token and give user money 
     function sellTicket(uint256 amount)
        public
        payable
    {
        require(isPaused == false, "The contract is paused by owner");
        require(amount > 0, "The amount can't be zero.");
        require(minted - amount >= 0, "Minted tokens are less than your amount");
        require(address(this).balance >= amount * rate , "Not enough balance in contract");
        
        burn(msg.sender, 1, amount);
        minted -= amount;

        payable(msg.sender).transfer(amount * rate);
    }

// withdraw the money to owner address
    function withdraw() public onlyOwner{
        require (address(this).balance > 0, "Balance is zero.");
        payable(owner()).transfer(address(this).balance);
    }

// deduct a ticket for enterence in match
    function deductTicket(uint256 matchID) public payable
    {   
        require(isPaused == false, "The contract is paused by owner");
        require(balanceOf(msg.sender,1) > 0, "Not enough tickets");

        matchIDs.push(matchID);
        safeTransferFrom(msg.sender,payable(owner()),1,1,"");
    }

// reward the user his winning amount
     function rewardUser(address client, uint256 matchID) public payable
    {
        require(isPaused == false, "The contract is paused by owner");
        uint256 amount = array_exists(matchID);
        require(amount  > 0, "Invalid matchID");
        require(balanceOf(owner(),1) >= amount, "Not enough tickets in contract");

        array_remove(matchID);
        safeTransferFrom(owner(),client,1,amount,"");
    }

// check if the array have the match ID
    function array_exists(uint256 matchID) public view returns (uint256) 
    {
        uint256 amount;

        for (uint i = 0; i < matchIDs.length; i++) 
        {
            if (matchIDs[i] == matchID) 
                {
                    amount += 1;
                }
        }
    
        return amount;
    }

// remove the match ID from the array
    function array_remove(uint256 matchID) private 
    {
        for (uint i = 0; i < matchIDs.length; i++) 
        {
            if (matchIDs[i] == matchID) 
                {
                    matchIDs[i] = matchIDs[matchIDs.length - 1];
                    matchIDs.pop();
                }
        }
    }
}
