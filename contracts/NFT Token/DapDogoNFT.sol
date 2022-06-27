// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DapDogoNFT is ERC721 ,Ownable ,ReentrancyGuard
{
  uint256 public mintPrice;
  uint256 public totalSupply;
  uint256 public maxSupply;
  uint256 public maxPerWallet;
  bool public isPublicMintEnabled;
  string internal baseURI;
  mapping(address=> uint256) public walletMint;


  constructor() payable ERC721("DapDogo","DADO"){
    mintPrice=0.1 ether;
    totalSupply=0;
    maxSupply=1000;
    maxPerWallet=5;
    // set wallet withdrawal address
  }

  function setPublicMintEnabled(bool _isPublicMintEnabled) external onlyOwner{

    isPublicMintEnabled=_isPublicMintEnabled;
  }


  function setBaseTokenUri(string calldata _baseURI) external onlyOwner{
    baseURI = _baseURI;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory){
    require(_exists(_tokenId),"Token does not exist !");
    return string(abi.encodePacked(baseURI, Strings.toString(_tokenId),".json"));
  }

  function withdraw() external onlyOwner{
    (bool success,)= owner().call{value:address(this).balance}("");
    require(success,"withdraw failed");
  }


  function mint(uint256 _quantity) public payable nonReentrant 
  {
    require(isPublicMintEnabled,"minting not enabled");
    require(msg.value == _quantity* mintPrice,"wrong mint value");
    require(totalSupply + _quantity <= maxSupply,"sold Out");
    require(walletMint[msg.sender] + _quantity <= maxPerWallet,"exceed max wallet");

    walletMint[msg.sender]= walletMint[msg.sender] + (_quantity);

    for (uint256 i=0;i<_quantity;i++){
      uint256 newTokenId = totalSupply +1;
      totalSupply++;
      _safeMint(msg.sender,newTokenId);
    }


  }




}