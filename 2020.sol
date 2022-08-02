pragma solidity ^0.8.0;
//BBSE Exam 2020 Solidity
//import"./Safemath.sol";

contract Auction {
    //using Safemath for uint256;
    address payable owner;
    struct item{
        string item_name;
        uint price;
        address payable highest_bidder;
    }
    item public auctioned_item;
    mapping (address =>uint) public accountBalances;

    modifier isOwner{
        require(msg.sender == owner);
        _;
    }
    constructor () public{
        owner = payable(msg.sender);
    }
    function setAuctionedItem(string memory _item, uint _price) public isOwner{
        auctioned_item = item (_item, _price, payable(address(0)));
    }
    function bid() public payable{
        require(msg.value >0); //
        require(auctioned_item.price > 0); 
        uint bid_amount = msg.value + accountBalances[msg.sender];
        accountBalances[msg.sender] = bid_amount;
        if (bid_amount > auctioned_item.price){
            auctioned_item.highest_bidder = payable(msg.sender);
            auctioned_item.price = msg.value;

        }
    }

    function withdraw() public { // secure transfer -->Pay functions 
        require(msg.sender != auctioned_item.highest_bidder);
        uint amount = accountBalances[msg.sender];
        accountBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    function finishAuction() public isOwner{

        owner.transfer(auctioned_item.price);
    }
    

}