pragma solidity ^0.4.24;

import "./libs/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract WaifuDistribution is ERC721Full{
    
	uint public creationTime;
	string baseURL="https://api.waifuchain.moe?waifu=";

	constructor() ERC721Full("WaifuChain", "WAIFU") public {
	    creationTime=now;
	    _mint(msg.sender, 0);
	    _mint(msg.sender, 1);
	    _mint(msg.sender, 2);
	}
	
	//Auction logic to release a new waifu every day
	mapping(uint=>address) topDonor;
	mapping(uint=>uint) topPaid;
	
	function _waifuIndexRangeByDay(uint time) view internal returns (uint, uint){
	    uint256 day=(time-creationTime)/(1 days);
	    uint256 month=day/30;
	    require(month<=3);
	    uint min;
	    uint max;
	    if(month==3){
	        min=(8+4+2)*30+day%30;
	        max=min;
	    }
	    else if(month==2){
	        min=(8+4)*30+2*(day%30);
	        max=min+1;
	    }
	    else if(month==1){
	        min=(8)*30+4*(day%30);
	        max=min+3;
	    }
	    else if(month==0){
	        min=8*(day%30);
	        max=min+7;
	    }
	    return (min, max);
	}
	
	event Bid(uint waifuIndex, uint amount);
	
	function getMaxBid(uint waifuIndex) view external returns (uint){
		return topPaid[waifuIndex];
	}
	
	function bidWaifu(uint waifuIndex) external payable{
	    (uint min, uint max)=_waifuIndexRangeByDay(now);
	    require(waifuIndex>=min && waifuIndex<=max);
	    require(msg.value>topPaid[waifuIndex]);
	    topDonor[waifuIndex].transfer(topPaid[waifuIndex]);
	    topPaid[waifuIndex]=msg.value;
	    topDonor[waifuIndex]=msg.sender;
	    emit Bid(waifuIndex, msg.value);
	}
	
	function claimWaifu(uint waifuIndex) external{
	    require(msg.sender==topDonor[waifuIndex]);
	    (,uint max)=_waifuIndexRangeByDay(now);
	    require(waifuIndex>max);
	    topDonor[waifuIndex]=address(0);
	    _mint(msg.sender, waifuIndex);
	}
	
	//Copied from Oraclize
	function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

	function tokenURI(uint256 tokenId) external view returns (string) {
	    return string(abi.encodePacked(baseURL, uint2str(tokenId)));
	}
}
