pragma solidity ^0.4.24;

import "./libs/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract WaifuDistribution is ERC721Full{


struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

mapping(uint=>mapping(address => Bid[])) public bids;

mapping(address => uint) pendingReturns;

    mapping(uint=>address) public highestBidder;
    mapping(uint=>uint) public highestBid;

	uint public creationTime;
	string baseURL="https://api.waifuchain.moe?waifu=";

	constructor() ERC721Full("WaifuChain", "WAIFU") public {
	    creationTime=now;
	}

	event Bid(uint waifuIndex);

/// Place a blinded bid with `_blindedBid` = keccak256(value,
    /// fake, secret).
    /// The sent ether is only refunded if the bid is correctly
    /// revealed in the revealing phase. The bid is valid if the
    /// ether sent together with the bid is at least "value" and
    /// "fake" is not true. Setting "fake" to true and sending
    /// not the exact amount are ways to hide the real bid but
    /// still make the required deposit. The same address can
    /// place multiple bids.
    function bid(uint _tokenId, bytes32 _blindedBid)
        public
        payable
    {
	(uint min, uint max)=_waifuIndexRangeByDay(now);
	require(_tokenId>=min && _tokenId<=max);
        bids[_tokenId][msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
	Bid(_tokenId);
    }

function _waifuIndexRangeByDay(uint time) view internal returns (uint, uint){
	    uint256 day=(time-creationTime)/(1 days);
	    assert(day>=0)
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
	

    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    function reveal(
	uint _tokenId,
        uint[] _values,
        bool[] _fake,
        bytes32[] _secret
    )
        public
    {
	(uint min, uint max)=_waifuIndexRangeByDay(now - 1 days);
	require(_tokenId>=min && _tokenId<=max);

        uint length = bids[_tokenId][msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);

        uint refund;
        for (uint i = 0; i < length; i++) {
            Bid storage bid = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) =
                    (_values[i], _fake[i], _secret[i]);
            if (bid.blindedBid != keccak256(value, fake, secret)) {
                // Bid was not actually revealed.
                // Do not refund deposit.
                continue;
            }
            refund += bid.deposit;
            if (!fake && bid.deposit >= value) {
                if (placeBid(_tokenId, msg.sender, value))
                    refund -= value;
            }
            // Make it impossible for the sender to re-claim
            // the same deposit.
            bid.blindedBid = bytes32(0);
        }
        msg.sender.transfer(refund);
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(uint _tokenId, address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid[_tokenId]) {
            return false;
        }
        if (highestBidder[_tokenId] != 0) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder[_tokenId]] += highestBid;
        }
        highestBid[_tokenId] = value;
        highestBidder[_tokenId] = bidder;
        return true;
    }

    function withdraw() public {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[msg.sender] = 0;

            msg.sender.transfer(amount);
        }
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

	function claimWaifu(uint waifuIndex) external{
	    require(msg.sender==highestBidder[waifuIndex]);
	    (uint min,)=_waifuIndexRangeByDay(now - 1 days);
	    require(waifuIndex<min);
	    highestBidder[waifuIndex]=address(0);
	    _mint(msg.sender, waifuIndex);
	}

}
    
