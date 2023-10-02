// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {
    address owner;
    struct Order{
        mapping(uint256 => uint256) pin;
        uint transit;
        uint delivered;
    }
    mapping(address=>Order) internal orders;
    constructor()
    {
        owner=msg.sender;
    }
    //This function inititates the shipment
    function shipWithPin(address customerAddress, uint _pin) external {
        require(msg.sender ==owner && _pin>999 && _pin<10000 && msg.sender!=customerAddress );
        ++orders[customerAddress].pin[_pin];
        ++orders[customerAddress].transit;
    }

    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint pin) external {
        require(msg.sender != owner && pin>999 && pin<10000 && orders[msg.sender].pin[pin] > 0);
        --orders[msg.sender].pin[pin];
        --orders[msg.sender].transit;
        ++orders[msg.sender].delivered;
    }

    //This function outputs the status of the delivery
    function checkStatus(address _customerAddress) external view returns (uint){
        require(msg.sender == _customerAddress || msg.sender == owner);
        return orders[_customerAddress].transit;   
    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address _customerAddress) external view returns (uint) {
        require(msg.sender == _customerAddress || msg.sender == owner);
        return orders[_customerAddress].delivered; 

    }

}