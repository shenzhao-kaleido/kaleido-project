// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";


contract sz is ERC721 {
    constructor () ERC721("sz1", "sz2"){}
    
    uint256[] private burnedId; //store burned tokenid for remint
    uint256[] private mintedId; //store individually minted tokenid
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //track tokenid to mint

    // mint certain number of token
    function mintMulti(address user, uint256 number) public payable {
        for (uint256 i = 0; i < number; i++) {
            if(burnedId.length != 0){
                uint256 index = burnedId[burnedId.length-1];
                burnedId.pop();
                _safeMint(user, index);
            }
            else{
                uint256 index = _tokenIds.current();
                while (searchFor(mintedId, index) != -1){
                    int256 pos = searchFor(mintedId, index);
                    mintedId[uint256(pos)] = mintedId[mintedId.length-1];
                    mintedId.pop();
                    _tokenIds.increment();
                    index = _tokenIds.current();
                }     
                _safeMint(user, index);
                _tokenIds.increment();
            }        
        }
    }

    // mint certain token
    function mint(address user, uint256 tokenId) public payable{
        require(!_exists(tokenId), "token is minted #1");
        // int256 loc = searchFor(mintedId, tokenId);
        // require(loc == -1, "token has been minted #1");
        if(tokenId >= _tokenIds.current()){
            mintedId.push(tokenId);
        }
        else{
            int256 pos = searchFor(burnedId, tokenId);
            require(pos != -1, "token has been minted #2(shouldn't raise this error)");
            burnedId[uint256(pos)] = burnedId[burnedId.length-1];
            burnedId.pop();
        }
        _safeMint(user, tokenId);
    }

    //burn certain token
    function burn(uint256 tokenId) public{
        require(_exists(tokenId), "token isn't minted");
        _burn(tokenId);
        burnedId.push(tokenId);
    }

    //burn multi tokens for certain user
    function burnMulti(address user, uint256 number) public{
        require(balanceOf(user) >= number, "user doesn't have enough tokens");
        uint256 length = uint256(_tokenIds.current()) + uint256(mintedId.length);
        // put all posible tokenid in token
        uint256[] memory token = new uint256[](length);
        for(uint256 i=0;i<_tokenIds.current();i++){
            token[i] = i;
        }
        for(uint256 i=_tokenIds.current();i<length;i++){
            token[i] = mintedId[i-_tokenIds.current()];
        }
        for(uint256 pos=0; number>0; pos++){
            if(!_exists(token[pos])){
                continue;
            }
            else{
                if(ownerOf(token[pos]) != user){
                    continue;
                }
                else{
                    _burn(token[pos]);
                    burnedId.push(token[pos]);
                    number --;
                }
            }
        }
    }

    // transfer, same as safeTransferFrom, without checking approval
    function transfer(address from, address to, uint256 tokenId) public payable{
        require(_exists(tokenId), "token isn't minted");
        require(ownerOf(tokenId) == from, "token is owned by others");
        _safeTransfer(from, to, tokenId, "");
    }

    // transfer multi tokens
    function transferMulti(address from, address to, uint256 number) public payable{
        require(balanceOf(from) >= number, "user doesn't have enough tokens");
        uint256 length = uint256(_tokenIds.current()) + uint256(mintedId.length);
        // put all posible tokenid in token
        uint256[] memory token = new uint256[](length);
        for(uint256 i=0;i<_tokenIds.current();i++){
            token[i] = i;
        }
        for(uint256 i=_tokenIds.current();i<length;i++){
            token[i] = mintedId[i-_tokenIds.current()];
        }
        for(uint256 pos=0; number>0; pos++){
            if(!_exists(token[pos])){
                continue;
            }
            else{
                if(ownerOf(token[pos]) != from){
                    continue;
                }
                else{
                    _safeTransfer(from, to, token[pos], "");
                    number --;
                }
            }
        }
    }

    // to debug, should be private
    function getCurrentId() public view returns (uint){
        return _tokenIds.current();
    }

    function getBurned() public view returns (uint[] memory){
        return burnedId;
    }

    function getMinted() public view returns (uint[] memory){
        return mintedId;
    }

    // auxiliary, should be private
    function searchFor(uint256[] memory array, uint item) public pure returns(int256){
        for(uint256 i=0; i<array.length; i++){
            if(item == array[i]){
                return int256(i);
            }
        }
        return -1;
    }

    // useless functions
    // function mintNFTOld(address user, uint256 numberOfNfts) public payable {
    //     for (uint i = 0; i < numberOfNfts; i++) {
    //         uint index = _tokenIds.current();
    //         _safeMint(user, index);
    //         _tokenIds.increment();
    //     }
    // }

    // function deleteItem(uint[] memory array, int pos) public returns(uint[] memory){
    //     uint loc = uint(pos);
    //     array[loc] = array[array.length-1];
    //     uint[] memory newArray = array[:array.length-1];
    //     return newArray;
    // }




}