pragma solidity ^0.8.0;

contract RockPaperScissors {

    //parties
    address payable public owner;
    address payable public playerTwo;

    // mappings
    mapping(address => bytes32) commitments; // commitments of current round
    mapping(address => bool) isPlaced; // has player placed commitment?
    mapping(address => uint) revealedCommitments; // revealed commitments of current round
    mapping(address => bool) isRevealed; // has player revealed commitment?
    mapping(uint => mapping(uint => uint)) private gameResults; // game results for all rounds
    
    // stake amount
    uint bet;

    // restrict access to players only
    modifier onlyPlayer() {
        require(msg.sender == owner || msg.sender == playerTwo, "Only players can call this function");
        _;
    }

    // 0,1,2 are rock, paper, scissors constructor
    constructor(address _playerTwo) {
        // TODO
        owner =   payable(msg.sender);
        playerTwo = payable(_playerTwo);
        bet = 0;

        // 0 = Loose, 1 = Draw, 2 = Win
        gameResults[0][0] = 0;
        gameResults[0][1] = 2;
        gameResults[0][2] = 1;
        gameResults[1][0] = 1;
        gameResults[1][1] = 0;
        gameResults[1][2] = 2;
        gameResults[2][0] = 2;
        gameResults[2][1] = 1;
        gameResults[2][2] = 0;
    }


    //allows to commit to one choice per game and processes the bet
    function commit(bytes32 _hashedChoice) public payable onlyPlayer {
        commitments[msg.sender] = _hashedChoice;
        isPlaced[msg.sender] = true;
        bet += msg.value;

        require(!isPlaced[msg.sender]);
        if(bet == 0){
            require((msg.value >= 1 ether));
            bet = msg.value;
        }else {
            commitments[msg.sender] = _hashedChoice;
            isPlaced[msg.sender] = true;
        }
    }

    //reveals the commitment and processes the bet
    function reveal(uint _choice, int _nonce) public onlyPlayer {
        require(isPlaced[owner]);
        require(isPlaced[playerTwo]);
        require(isRevealed[msg.sender] == false);
        _choice = _choice % 3;
        bytes32 claimHash = keccak256(abi.encodePacked(_choice, _nonce));
        // TODO
        require(claimHash == commitments[msg.sender]);
        revealedCommitments[msg.sender] = _choice;
        isRevealed[msg.sender] = true;

    }

    // at the end of the game, this method pays the winner
    function distributeWinnings() public onlyPlayer {
        require(isRevealed[owner]);
        require(isRevealed[playerTwo]);

        uint result = gameResults[revealedCommitments[owner]][revealedCommitments[playerTwo]];
        if (result == 0) {
            owner.transfer(bet);
            playerTwo.transfer(bet);
        } else if (result == 1) {
            owner.transfer(bet * 2);
        } else {
            playerTwo.transfer(bet * 2);
        }
        isPlaced[owner] = false;
        isPlaced[playerTwo] = false;
        bet = 0;
        isRevealed[owner] = false;
        isRevealed[playerTwo] = false;
    }
}
