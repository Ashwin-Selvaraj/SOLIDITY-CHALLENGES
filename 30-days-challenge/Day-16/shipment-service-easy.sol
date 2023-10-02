// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {
    address owner;
    // used to view the no of orders placed by an address
    mapping(address=>uint) internal counter;
    enum Status{NO_ORDERS_PLACED,SHIPPED,DELIVERED}
    struct Order{
        Status sts;
        uint pin;
    }
    mapping(address=>Order) internal orders;
    constructor()
    {
        owner=msg.sender;
    }
    //This function inititates the shipment
    function shipWithPin(address customerAddress, uint pin) external {
        require(msg.sender ==owner && pin>999 && pin<10000 && msg.sender!=customerAddress && uint(orders[customerAddress].sts) != 1);
        orders[customerAddress].pin=pin;
        orders[customerAddress].sts=Status.SHIPPED;
    }

    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint pin) external {
        require(msg.sender != owner && pin>999 && pin<10000 && pin == orders[msg.sender].pin);
        orders[msg.sender].sts=Status.DELIVERED;
        unchecked{counter[msg.sender]+=1;}
    }

    //This function outputs the status of the delivery
    function checkStatus(address _customerAddress) external view returns (string memory){
        checkSender(_customerAddress);
        if(uint(orders[_customerAddress].sts)==1)
        {
            return "shipped";
        }
        else if(uint(orders[_customerAddress].sts)==2)
        {
            return "delivered";
        }
        else {
            return "no orders placed";
        }

    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address _customerAddress) external view returns (uint) {
        checkSender(_customerAddress);
        return counter[_customerAddress];
    }

    function checkSender(address _customerAddress) internal view {
        require(msg.sender == _customerAddress || msg.sender == owner);
    }
}