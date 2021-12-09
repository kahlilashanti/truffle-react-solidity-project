pragma solidity ^0.8.7;

//create code to ensure you have to be the owner to perform certain transactions
contract Ownable {
    address payable _owner;

    constructor() public {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(), "you are not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _owner);
    }
}
