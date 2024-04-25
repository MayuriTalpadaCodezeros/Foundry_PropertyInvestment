// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PropertyInvestment} from "../src/PropertyInvestment.sol";
import {USDT} from "../src/USDT.sol";


contract PropertyScript is Script {
    address public owner = address(2324);

    function setUp() public {}

    function run() public {
        vm.broadcast();
        USDT usdt = new USDT(owner);
        PropertyInvestment propertyInvestment = new PropertyInvestment(address(usdt));

        console.log("PropertyInvestment address: ", address(propertyInvestment));
    }
}
