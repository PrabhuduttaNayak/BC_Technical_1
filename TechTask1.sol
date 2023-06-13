// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

error NotOwner();

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 14;
    
    constructor() {   
        i_owner = msg.sender;
    }

    function fund() public payable {
    require(msg.value >= MINIMUM_USD, "You need to spend more ETH!"); 
        
        if (!isFunder(msg.sender)) {
            funders.push(msg.sender);
            addressToAmountFunded[msg.sender] += msg.value;  //unique address are pushed in the array
        }
        else if(isFunder(msg.sender)){
            addressToAmountFunded[msg.sender] += msg.value; //if the address is repeated you directly increase the value
        }
    }

    function isFunder(address funder) internal view returns (bool) { //this function checks if the address is unique or not by iterating over the funders array
        for (uint256 i = 0; i < funders.length; i++) {
            if (funders[i] == funder) {
                return true;
            }
        }
        return false;
    }
        
    modifier onlyOwner {      
        if (msg.sender != i_owner) revert NotOwner();
        _;  
    }
    //this helps to transfer the ownerhip to new address
    function ownership(address newOwner) public onlyOwner{
        require(newOwner != i_owner, "Invalid new owner address.");  //making sure that we don't put our own address
        i_owner = newOwner;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }


    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

