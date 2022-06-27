// SPDX-License-Identifier: Ambuj
pragma solidity ^0.8.0;

contract Auction{
    int public count;
    address payable public owner ;
    uint public  highestBindingBid; // selling price of artifact
    address public highestBidder;   // address of highest bidder at a point in time
    uint incrementFactor;           // increment factor to be ad
    mapping(address => uint) internal bids;
    address payable [] public audience;

    uint startingTime;
    uint endingTime;
    enum state {Started,Running,Ended,Cancelled}
    state public auction;

    constructor (){
        owner = payable (msg.sender);
        auction= state.Running;
        startingTime= block.number;
        incrementFactor= 1000000000000000000;
        endingTime=startingTime+3;
        
    }

    modifier stateconstraint{
        require(auction!=state.Ended,"auction ended");
        require(auction!=state.Cancelled);
        _;
    }

    modifier notOwner(){
        require(owner!=msg.sender);
        _;
    }

   
    function showBalance() public view returns (uint) {
    return address(this).balance;
    }

    function min(uint a, uint b) internal pure returns (uint){
        return a<=b?a:b;
    }

    function enterBid() public payable notOwner  stateconstraint returns(bool){
       uint currentBid=bids[msg.sender]+msg.value;
       require(currentBid>=highestBindingBid,"bid is less then the selling price");

       if(bids[msg.sender]==0){
         audience.push(payable (msg.sender)); // ye unique le raha he ya nahi ?
       }
        bids[msg.sender]=currentBid;

       if(bids[msg.sender]>=bids[highestBidder])
       {
        highestBindingBid= min(bids[msg.sender],bids[highestBidder]+incrementFactor);
        highestBidder=msg.sender;
       }
       else{
           highestBindingBid= min(bids[msg.sender]+ incrementFactor,bids[highestBidder]);

       }
       auction= block.number==endingTime?state.Ended:auction;
       return true;
    }


    function cancelAuction() external returns(bool){
        require(owner==msg.sender,"only owner can perform this operation");
       auction=state.Cancelled;

        return true;
    }

    function transfer_ether() internal  {
        require(owner==msg.sender,"only owner can perform this operation");

        for(uint i=0;i<audience.length;i++){
                if(audience[i]==highestBidder && auction==state.Ended){
                      audience[i].transfer(bids[audience[i]]- highestBindingBid);
                     owner.transfer(highestBindingBid);
                }
                  
                else
                    {
                        audience[i].transfer(bids[audience[i]]);
                    }
            }  
    }

    function finalizeAuction() public returns (bool){
        
        require(auction==state.Cancelled || auction==state.Ended,"Sorry! auction is still not completed");
        transfer_ether();
        return true;

    }


}