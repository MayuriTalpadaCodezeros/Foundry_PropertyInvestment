// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/PropertyInvestment.sol";
import "../src/USDT.sol";

contract PropertyInvestmentTest is Test {
    PropertyInvestment public propertyInvestment;
    USDT public usdt;
    address public owner = address(2324);
    address public holder1 = address(3092857209);
    address public holder2 = address(9325790);
    
    function setUp() public {
        usdt = new USDT(owner);
        propertyInvestment = new PropertyInvestment(address(usdt));
    }

    function  testRegisterProperty() public {
        vm.prank(address(0x1));
        string memory _name = "a1";
        uint256 _totalToken = 10000;
        uint256 _percentage = 50;
        propertyInvestment.registerProperty(_name, _totalToken, _percentage);
    }

    function testInvest() public {
        vm.prank(owner);
        usdt.transfer(holder2,2000);

        vm.prank(holder1);
        propertyInvestment.registerProperty("aa", 10000, 50);

        vm.prank(holder2);
        usdt.approve(address(propertyInvestment), 2000);

        vm.prank(holder2);
        uint allowAmount = usdt.allowance(holder2, address(propertyInvestment));
        uint propertyId = propertyInvestment.propertyIdCounter();
        console.log("----",allowAmount,propertyId);
        console.log("--------->balance holder2:",usdt.balanceOf(holder2));

        vm.prank(holder2);
        propertyInvestment.invest(1, "I1", allowAmount);
    }

    function testRent() public {
        vm.prank(address(0x1));
        string memory _name = "a1";
        uint256 _totalToken = 10000;
        uint256 _percentage = 50;
        propertyInvestment.registerProperty(_name, _totalToken, _percentage);
        uint256 _propertyId = propertyInvestment.propertyIdCounter()-1;
        address add1 = propertyInvestment.checkowner(_propertyId);
        console.log("Owner address: ", add1);
        assertEq(add1, address(0x1));
        vm.prank(address(0x1));
        propertyInvestment.rentProperty(_propertyId);
    }

    function testcloseProperty() public {
        vm.prank(holder1);
        string memory _name = "a1";
        uint256 _totalToken = 10000;
        uint256 _percentage = 50;
        propertyInvestment.registerProperty(_name, _totalToken, _percentage);
        uint256 _propertyId = propertyInvestment.propertyIdCounter()-1;
        address add1 = propertyInvestment.checkowner(_propertyId);
        console.log("Owner address: ", add1);
        assertEq(add1, holder1);
        
        vm.prank(holder1);
        propertyInvestment.rentProperty(_propertyId);

        vm.prank(holder1);
        propertyInvestment.closeProperty(_propertyId);
    }
    
}

