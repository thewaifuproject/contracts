pragma solidity ^0.4.24;

import "./libs/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract WaifuDistribution is ERC721Full{

	constructor() ERC721Full("WaifuChain", "WAIFU") public {}

	//Auction logic to release a new waifu every day
	string[] waifusNames=["Asuna", "Rem"];
	
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
	
	function _mint(address to, uint256 tokenId) internal {
	    super._mint(to, tokenId);
	    
	    _setTokenURI(tokenId, string(abi.encodePacked("https://waifuchain.moe/api?waifu=", uint2str(tokenId))));
	}
}
