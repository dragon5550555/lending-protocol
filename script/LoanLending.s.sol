// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LoanLending} from "../src/LoanLending.sol";

contract CounterScript is Script {
    LoanLending public loanLending;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        loanLending = new LoanLending(0.1 ether, 10 ether, 0.01 ether, 10);

        vm.stopBroadcast();
    }
}
