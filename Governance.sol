pragma solidity ^0.4.24;

import "./SocialMediaWaifus.sol";

contract Governance is SocialMediaWaifus{

	mapping(uint=>string) _newBaseURL;

	function voteBaseURL(uint _tokenId, string _URL) external isWaifuOwner(_tokenId){
		_newBaseURL[_tokenId]=_URL;
	}

	function strcmp(string s1, string s2) pure internal returns (bool){
		return keccak256(s1)==keccak256(s2);
	}

	function setBaseURL(string _URL) external{
		uint votes=0;
		for(uint i=0; i<totalSupply(); i++){
			string votedURL = _newBaseURL[tokenByIndex(i)];
			if(strcmp(votedURL, _URL) && !strcmp(votedURL, "")){
				votes++;
			}
		}
		require(votes>(totalSupply()*0.75) && votes>100);
		baseURL=_URL;
	}

	function _removeTokenFrom(address from, uint256 tokenId) internal {
		super._removeTokenFrom(from, tokenId);
		_newBaseURL[tokenID]="";
	}
}
