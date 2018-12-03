pragma solidity ^0.4.24;

import "./SocialMediaWaifus.sol";

contract Governance is SocialMediaWaifus{

	mapping(uint=>string) _newBaseURL;
	mapping(uint=>address) _newFundOwner;

	function voteBaseURL(uint _tokenId, string _URL) external isWaifuOwner(_tokenId){
		_newBaseURL[_tokenId]=_URL;
	}
	
	function voteFundOwner(uint _tokenId, address _owner) external isWaifuOwner(_tokenId){
		_newFundOwner[_tokenId]=_owner;
	}

	function strcmp(string s1, string s2) pure internal returns (bool){
		return keccak256(abi.encodePacked(s1))==keccak256(abi.encodePacked(s2));
	}

	function setBaseURL(string _URL) external{
		uint votes=0;
		for(uint i=0; i<totalSupply(); i++){
			string memory votedURL = _newBaseURL[tokenByIndex(i)];
			if(strcmp(votedURL, _URL) && !strcmp(votedURL, "")){
				votes++;
			}
		}
		require(votes>((totalSupply()*3)/4) && votes>100);
		baseURL=_URL;
	}
	
	function transferFunds(address _owner) external{
		uint votes=0;
		for(uint i=0; i<totalSupply(); i++){
			address votedOwner = _newFundOwner[tokenByIndex(i)];
			if(votedOwner==_owner && votedOwner!=address(0)){
				votes++;
			}
		}
		require(votes>((totalSupply()*3)/4) && votes>100);
		_owner.transfer(address(this).balance);
	}

	function _removeTokenFrom(address from, uint256 tokenId) internal {
		super._removeTokenFrom(from, tokenId);
		_newBaseURL[tokenId]="";
		_newFundOwner[tokenId]=address(0);
	}
}
