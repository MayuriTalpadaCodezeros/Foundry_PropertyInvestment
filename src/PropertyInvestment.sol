// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./USDT.sol";

contract PropertyInvestment is ERC1155{

    USDT public usdtToken;
    struct Property {
        string name;
        uint256 totalValue;
        uint256 percentageInvested;
        address owner;
        bool isOnRent;
        bool propertyOnInvest;
        uint256 rentStartTime;
        uint256 investmentProfits;
    }

    struct Investor {
        string name;
        address wallet;
        uint256 investedAmount;
    }

    mapping(uint256 => Property) public properties;
    mapping(uint256 => mapping(address => Investor)) public investors;
    mapping(uint256 => address[]) public investorAddresses;

    uint256 public propertyIdCounter=1;

    constructor(address _usdt) ERC1155("ipfs://CID/{id}.json") {
        usdtToken = USDT(_usdt);
    }

    modifier onlyPropertyOwmer(uint256 _propertyId){
        require(msg.sender == properties[_propertyId].owner, "Only the property owner can rent the property");
        _;
    }

    function registerProperty(
        string memory _name,
        uint256 _totalValue,
        uint256 _percentageInvested
    ) public {
        require(_percentageInvested <= 100, "Percentage invested must be less than or equal to 100");
        require(_percentageInvested > 0, "Percentage invested must be greater than zero");

        uint256 tokenAmount = (_percentageInvested * _totalValue) / 100;
        Property memory newProperty = Property({
            name: _name,
            totalValue: _totalValue,                                                        
            percentageInvested: tokenAmount,
            owner: msg.sender,
            isOnRent: false,  
            propertyOnInvest: true,              
            rentStartTime: 0,
            investmentProfits:0
        });
                                         
        properties[propertyIdCounter] = newProperty;

        _mint(msg.sender, propertyIdCounter, tokenAmount, "");

        propertyIdCounter++;
    }

    function invest(
        uint256 _propertyId,
        string memory _name,
        uint256 _investedAmount
    ) public {
        require(properties[_propertyId].owner != msg.sender, "Owner cannot invest in their own property");
        require(_investedAmount > 0, "Invested amount must be greater than zero");
        require(properties[_propertyId].propertyOnInvest == true, "property is not on Invest" );

        Property memory property = properties[_propertyId];

        Investor memory investor = investors[_propertyId][msg.sender];
        if (investor.wallet == address(0)) {
            investor = Investor({
                name: _name,
                wallet: msg.sender,
                investedAmount: _investedAmount
            });

            investorAddresses[_propertyId].push(msg.sender);
        } else {
            investor.investedAmount += _investedAmount;
        }

        usdtToken.transferFrom(msg.sender, property.owner, _investedAmount);
        investors[_propertyId][msg.sender] = investor;
    }

    function checkTotalvalue(uint256 _propertyId) public view returns(uint256){
        uint256 value = (properties[_propertyId].totalValue*properties[_propertyId].percentageInvested)/100;
        return value;
    }

    function rentProperty(uint256 _propertyId) public onlyPropertyOwmer(_propertyId) {
        // Property storage property = properties[_propertyId];
        
        require(! properties[_propertyId].isOnRent, "Property is already on rent");

        properties[_propertyId].isOnRent = true;
        properties[_propertyId].rentStartTime = block.timestamp;
    }
    
    function checkowner(uint256 _propertyId) public view returns(address){
        address add = properties[_propertyId].owner;
        return add;
    }

    function closeProperty(uint256 _propertyId) public onlyPropertyOwmer(_propertyId) {
        Property memory property = properties[_propertyId];
        require(property.isOnRent, "Property is not on rent");

        uint256 rentDuration = block.timestamp - property.rentStartTime;
        uint256 rentProfit = rentDuration * 5; // Assuming the profit is 5 USDT per second

        uint256 totalInvestedAmount = 0;
        for (uint256 i = 0; i < investorAddresses[_propertyId].length; i++) {
            Investor memory investor = investors[_propertyId][investorAddresses[_propertyId][i]];
            totalInvestedAmount += investor.investedAmount;
        }

        for (uint256 i = 0; i < investorAddresses[_propertyId].length; i++) {
            Investor memory investor = investors[_propertyId][investorAddresses[_propertyId][i]];
            uint256 investorPercentage = (investor.investedAmount * 100) / totalInvestedAmount;
            uint256 investorProfit = (investorPercentage * rentProfit) / 100;

            uint256 senderBalance = usdtToken.balanceOf(msg.sender);
            if (senderBalance < investorProfit) {
                revert("Sender has insufficient balance to transfer tokens");
            }

            properties[_propertyId].investmentProfits += investorProfit;
            usdtToken.transferFrom(msg.sender, investor.wallet, investorProfit);
        }
        properties[_propertyId].isOnRent = false;
        properties[_propertyId].propertyOnInvest = false;
        properties[_propertyId].rentStartTime = 0;
    }

}

