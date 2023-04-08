// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@solvprotocol/erc-3525/ERC3525.sol";
 
contract TT is ERC3525 {    
    using Strings for uint256;   
    address public owner;
    
constructor(address owner_)
    ERC3525("ERC3525GettingStarted", "ERC3525GS", 18) {
        owner = owner_;
    }
 
   function mint(address to_, uint256 slot_, uint256 amount_) external {
   require(msg.sender == owner, 
     "ERC3525GettingStarted: only owner can mint");
   _mint(to_, slot_, amount_);
    }
}
