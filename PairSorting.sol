// Eliott Teissonniere: https://eliott.teissonniere.org

// A simple example of a pair sorting algorithm for the Pseudonym Pairs idea
// There are probably some optimizations possible

pragma solidity ^0.4.20;

import "./DLL.sol";

contract PairSorting {
    using DLL for DLL.Data;

    DLL.Data listOfPairs;

    mapping(address => address) public pairOf;

    // Should be seeded properly, use a random oracle at least for seeding
    // The developer should seed it, oraclize.it provide a way to generate
    // verifiable random numbers
    bytes32 entropy;

    // add a pair to the list of pairs, helper function
    function _addPair(address someone) internal {
        uint pair = uint(someone); // The DLL libs uses uints

        require(!listOfPairs.contains(pair), "Pair already in list");

        uint previous = listOfPairs.getStart();
        uint next = listOfPairs.getNext(previous);
        listOfPairs.insert(previous, pair, next);
    }

    // remove a pair from the list of pairs, helper function
    function _removePair(address someone) internal {
        uint pair = uint(someone);

        require(listOfPairs.contains(pair), "Pair not in list");

        listOfPairs.remove(pair);
    }

    // this will regenerate the entropy from the old one and return a random
    // pair from the list
    function _getRandomPair() internal returns (uint) {
        // It would be recommended to use something like oraclize.it to reseed
        // the entropy for safety purposes
        entropy = keccak256(
            abi.encodePacked(
                block.blockhash(block.number - 1),
                block.number,
                now,
                msg.sender,
                entropy
            )
        );

        uint randomIndex = uint(entropy) % listOfPairs.length();
        return listOfPairs.getNth(randomIndex);
    }

    // can be called by anyone or used in a contract to match a pair with another
    // random one.
    function matchWith(address someone) public returns (address) {
        uint pair = uint(someone);

        require(listOfPairs.contains(pair), "Pair already matched with someone");
        require(listOfPairs.length() >= 2, "Not enough pairs to form at least one pair");

        _removePair(pair); // We will match it, won't be pairable anymore
        uint randomPair = _getRandomPair();
        _removePair(randomPair); // Paired!

        pairOf[pair] = randomPair;
        pairOf[randomPair] = pair;

        return address(randomPair);
    }
}