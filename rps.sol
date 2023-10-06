// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public owner;
    uint256 public betAmount = 100000000000000; // 0.0001 tBNB in Wei

    enum Move { None, Rock, Paper, Scissors }
    enum GameState { None, Win, Lose, Draw }

    struct Game {
        address player;
        Move playerMove;
        Move contractMove;
        GameState state;
        uint256 reward;
    }

    Game[] public games;
    
    constructor() {
        owner = msg.sender;
    }

    function play(Move _playerMove) external payable {
        require(msg.value == betAmount, "Incorrect bet amount");
        require(_playerMove >= Move.Rock && _playerMove <= Move.Scissors, "Invalid move");

        Move contractMove = generateRandomMove();
        GameState result = determineWinner(_playerMove, contractMove);
        uint256 reward = calculateReward(result);

        Game memory newGame = Game({
            player: msg.sender,
            playerMove: _playerMove,
            contractMove: contractMove,
            state: result,
            reward: reward
        });

        games.push(newGame);

        if (result == GameState.Win) {
            payable(msg.sender).transfer(reward);
        }
    }

    function generateRandomMove() internal view returns (Move) {
        bytes32 blockHash = blockhash(block.number - 1);
        bytes32 combinedHash = keccak256(abi.encodePacked(blockHash, msg.sender));
        uint256 randomSeed = uint256(combinedHash);
        return Move(randomSeed % 3 + 1);
    }

    function determineWinner(Move _playerMove, Move _contractMove) internal pure returns (GameState) {
        if (_playerMove == _contractMove) {
            return GameState.Draw;
        } else if ((_playerMove == Move.Rock && _contractMove == Move.Scissors) ||
            (_playerMove == Move.Paper && _contractMove == Move.Rock) ||
            (_playerMove == Move.Scissors && _contractMove == Move.Paper)) {
            return GameState.Win;
        } else {
            return GameState.Lose;
        }
    }

    function calculateReward(GameState _result) internal view returns (uint256) {
        if (_result == GameState.Win) {
            return betAmount * 2;  // Player wins and receives a reward of 2 times the bet amount
        } else if (_result == GameState.Draw) {
            return betAmount;  // Player gets back the bet amount in case of a draw
        }
        return 0;  // Player loses and receives no reward
    }
}
