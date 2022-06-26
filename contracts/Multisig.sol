// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract multisig{
    mapping(address => bool) public admins;
    mapping(uint => bill) public bills;
    uint public billCount;
    uint public requireApproves;

    struct bill {
        address to;
        bool end;
        uint id;
        uint amount;
        uint approveNum;
        address[] approval;
    }

    struct exchangeBill {
        address targetCurrencyAddr;
        bool end;
        uint id;
        uint amount;
        uint approveNum;
        address[] approval;
    }

    constructor(address _adr1,address _adr2,address _adr3, uint _requireApproves){
        admins[_adr1] = true;
        admins[_adr2] = true;
        admins[_adr3] = true;
        requireApproves = _requireApproves;
    }

    function billing(address _to, uint _amount) public adminonly {
        address[] memory arr;
        bills[billCount] = bill({
            to: _to,
            end: false,
            id: billCount,
            amount: _amount,
            approveNum: 0,
            approval: arr
            });
        approve(billCount);
        billCount ++;
    }

    function approve(uint _id) public adminonly {
        require(bills[_id].end != true, "this bill is already ended");
        bool isAlready = false;
        for(uint i=0;i>bills[_id].approval.length;i++){
            if(bills[_id].approval[i] == msg.sender){
                isAlready = true;
            }
        }
        require(!isAlready, "You are already approved");
        bills[_id].approval.push(msg.sender);
        bills[_id].approveNum ++;
    }

    function withdraw(uint _id) public adminonly {
        require(bills[_id].end != true, "this bill is already ended");
        require(bills[_id].approveNum >= requireApproves, "approve is few");
        (bool success, ) = payable(bills[_id].to).call{value: bills[_id].amount}("");
        require(success, "Eth transfer failed");
        bills[_id].end = true;
    }

    modifier adminonly {
        require(admins[msg.sender] == true, "You aren't admin");
        _;
    }
}