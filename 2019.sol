pragma solidity ^0.8.0;

contract Lottery {
address owner;
uint pot;
address winner;
mapping(address =>uint) players;

modifier onlyOwner(){
    require(msg.sender == owner);
    _;
}

constructor() public{
    owner = msg.sender;
    pot = 0;
    winner = address(0);
}

function payIn() public payable{
    pot += msg.value;
    players.push(msg.sender);
}

function selectWinner() public onlyOwner{
    require(pot >0);
    require(winner == address(0));
    winner = players([blockhash(block.number-1)% players.length]);

}
function withdraw() public{
    require(msg.sender == winner);
    uint amount = pot;
    pot = 0;
    require(address(this).balance >= pot);
    payable(winner).transfer(amount);
}

}