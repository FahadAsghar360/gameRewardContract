// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC20/ERC20.sol";

contract TokenContract is ERC1155, Ownable, ERC1155Burnable {

    uint256 minted = 0;
    uint256 rate = 10000000000000000000;
    uint256[] matchIDs;
    bool isPaused;

    address contractor = 0x6Ed18B72a6e9362181f27E6B63ef9c7E72167075;

    ERC20 token = ERC20(0x85EAC5Ac2F758618dFa09bDbe0cf174e7d574D5B);

    constructor() ERC1155("https://subrays.com/token_data/token_metadata.json") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause(bool value) public onlyOwner{
        isPaused = value;
    }

    function changeToken(ERC20 newToken) public onlyOwner{
        token = newToken;
    }

     function changeTicketRate(uint256 newRate) public onlyOwner{
        rate = newRate;
    }

    function changeContractor(address newContractor) public onlyOwner{
        contractor = newContractor;
    }

    function name() public view returns(string memory)
    {
        return "Pet Vs Pets Tracker";
    }

// mint the token and take money from user 
    function buyTicket(uint256 amount)
        public
        payable
    {
        require(isPaused == false, "The contract is paused by owner");
        require(amount > 0, "The amount can't be zero.");
        require(token.balanceOf(msg.sender) >= amount * rate , "Not enough balance to buy");
        
        token.transferFrom(msg.sender,address(this), amount * rate);
        _mint(msg.sender, 1, amount, "");
        minted += amount;
    }

// burn the token and give user money 
     function sellTicket(uint256 amount)
        public
        payable
    {
        require(isPaused == false, "The contract is paused by owner");
        require(amount >= 20, "Minumum limit is 20 tickets");
        require(minted - amount >= 0, "Minted tokens are less than your amount");
        
        uint256 tax = (amount * rate) / 20;
        uint256 remainingBalance = (amount * rate) - tax;

        require(token.balanceOf(address(this)) >= remainingBalance , "Not enough balance in contract");
        
        burn(msg.sender, 1, amount);
        minted -= amount;

        token.transfer(payable(msg.sender), remainingBalance);
    }

// withdraw the money to owner address
    function withdraw() public onlyOwner{
        require (token.balanceOf(address(this)) > 0, "Balance is zero.");
        token.transfer(payable(owner()), token.balanceOf(address(this)));
    }

// deduct a ticket for enterence in match
    function deductTicket(address client,uint256 matchID) public payable
    {   
        require(isPaused == false, "The contract is paused by owner");
        require(balanceOf(client,1) > 0, "Not enough tickets");
        require(msg.sender == contractor, "Only contractor can call this.");

        matchIDs.push(matchID);
        safeTransferFrom(client,payable(owner()),1,1,"");
    }

// reward the user his winning amount
     function rewardUser(address client, uint256 matchID) public payable
    {
        require(isPaused == false, "The contract is paused by owner");
        require(msg.sender == contractor, "Only contractor can call this.");

        uint256 totalAmount = array_exists(matchID);
        require(totalAmount  > 0, "Invalid matchID");

        uint256 tax = totalAmount / 5;
        uint256 remainingAmount = totalAmount - tax;

        require(balanceOf(owner(),1) >= remainingAmount, "Not enough tickets in contract");

        array_remove(matchID);
        safeTransferFrom(owner(),client,1, remainingAmount,"");
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

// remove the match ID from matchIDs array
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
