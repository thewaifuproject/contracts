pragma solidity ^0.4.24;

import "./WaifuDistribution.sol";

contract WaifuUsers is WaifuDistribution{

	modifier isWaifuOwner(uint _tokenId){
		address owner = ownerOf(_tokenId);
		require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
		_;
	}

	// Associates each tokenId with the profile it's linked to
	mapping(uint=>string) public _tokenToProfile; 

	/// @dev Generate the unique id associated with each profile
	/// @param _profile Profile/user handle 
	function _getProfileId(string _profile) private pure returns (uint){
		return uint256(keccak256(abi.encodePacked(_profile)));
	}

	/// @dev Return an array of tokenIds representing the waifus linked to a profile
	/// @param _profile Profile being queried
	function getWaifusInProfile(string _profile) external view returns (uint[]){
		uint profileId=_getProfileId(_profile);
		uint length=0;
		uint i;
		for(i=0; i<totalSupply(); i++){
			if(_getProfileId(_tokenToProfile[tokenByIndex(i)])==profileId){
				length++;
			}
		}
		uint[] memory waifus=new uint[](length);
		uint index=0;
		for(i=0; i<totalSupply(); i++){
			if(_getProfileId(_tokenToProfile[tokenByIndex(i)])==profileId){
				waifus[index]=tokenByIndex(i);
				index++;
			}
		}
		return waifus;
	}

	function setWaifuProfile(uint _tokenId, string _profile) external isWaifuOwner(_tokenId){
		_tokenToProfile[_tokenId]=_profile;
	}
	
	function getWaifuProfile(uint _tokenId) view external returns (string){
		return _tokenToProfile[_tokenId];
	}
}
