pragma solidity ^0.8.7;

import "./ItemManager.sol";

//it is better to hand off payment to a different contract to keep the logic readable and minimize
//gas fees
contract Item {
    //this contract will be responsible for taking the payment and
    //handing the payment over to the itemManager contract
    //when we create a new item we create a new instance of the itemManager using the struct
    uint256 public priceInWei;
    //check if item was paid already
    uint256 public pricePaid;
    uint256 public index;

    ItemManager parentContract;

    //we need to set these variables in the constructor
    constructor(
        ItemManager,
        _parentContract,
        uint256 _priceInWei,
        uint256 _index
    ) public {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }

    //fallback function because we are only sending money with no message data
    receive() external payable {
        require(pricePaid == 0, "Item is paid for already");
        require(priceInWei == msg.value, "only full payments allowed");
        pricePaid += msg.value;
        //low level functions are more risky because they don't throw exceptions but they do save gas
        (bool success, ) = address(parentContract).call.value(msg.value)(
            abi.encodeWithSignature("triggerPayment(uint256)", index)
        );
        //the .call method gives you two return values. a boolean for success and any return value
        //abi.encodeWithSignature creates function signatures dynamically
        //check to see if it was successful, otherwise cancel the whole transaction
        require(success, "the transaction wasn't successful. canceling...");
    }

    fallback() external {}
}
