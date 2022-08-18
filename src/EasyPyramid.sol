// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Contract {

    uint256 public constant MINIMUM_INVESTMENT = 1e15;
    uint256 public numInvestors = 0;
    uint256 public depth = 0;
    address[] public investors;
    uint256 investors_length = 0;
    mapping(address => uint256) public balances;
    constructor () payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        investors_length = 3;
        investors[0] = msg.sender;
        numInvestors = 1;
        depth = 1;
        balances[address(this)] = msg.value;
    }

    receive () payable external {
        require(msg.value >= MINIMUM_INVESTMENT);
        //always take $ if over min
        balances[address(this)] += msg.value;
        numInvestors +=1;
        investors[numInvestors-1] = msg.sender;
        
        // once a tier has been filled, start a payout
        if(numInvestors == investors_length){
            //payout higher tiers
            uint256 endIndex = numInvestors - 2**(depth);
            uint256 startIndex = endIndex - 2**(depth-1);
            for(uint256 i = startIndex; i<endIndex; i++){
                balances[investors[i]] += MINIMUM_INVESTMENT;
            }

            //give out the remaining amount to the rest of participants
            uint256 paid = MINIMUM_INVESTMENT * 2**(depth-1);
            uint256 investorPayout = (balances[address(this)] - paid)/numInvestors;
            for(uint256 i = 0; i<numInvestors; i++){
                balances[investors[i]] += investorPayout;
            }

            //st8 update
            balances[address(this)] = 0;
            depth += 1;
            investors_length += 2**depth;
        }
    }

    function withdraw () public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }

}
