pragma solidity^0.6.0;

//=============================================================================
// ERC20 interface
//=============================================================================
contract ERC20{
     function balanceOf(address account) public view  returns (uint256) {}
      function transfer(address recipient, uint256 amount) public  returns (bool){}
      
}


//=============================================================================
// ERC721 interface
//=============================================================================
contract ERC721{
    function balanceOf(address owner) public view  returns (uint256){}
     function ownerOf(uint256 tokenId) public view  returns (address){}
     function safeTransferFrom(address from, address to, uint256 tokenId) public {}
     function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        public returns (bool){}
         function _transfer(address from, address to, uint256 tokenId) public{}
}


//=============================================================================
// Marketplace Contract
//=============================================================================


contract Marketplace{
    
//=============================================================================
// State Variables
//=============================================================================
   
    address public ERC20TokenAddress;
    address public ERC721TokenAddress;
    uint private TotalTokensAtSale;
     struct Token {
        address owner;
        uint tokenid;
        uint price;
        bool forSale;
    }

    //Tokens for sale by a specific address
   mapping(address=>Token[]) private tokensforSale;
   
   //get Token full details by ERC721 tokenid
   mapping(uint=>Token) public tokenDetailByTokenID;
   
   
//=============================================================================
// Constructor Declaration
//=============================================================================
    constructor(address add_erc20,address add_erc721) public{
        ERC20TokenAddress = add_erc20;
        ERC721TokenAddress = add_erc721;
        TotalTokensAtSale = 0;
    
    }



//=============================================================================
// Function Declarations
//=============================================================================

   /* @dev Checks Ownership for a ERC721 token
   */
    function getOwnershipERC721(uint tokenid) private view returns(address){
         ERC721 erc721 = ERC721(ERC721TokenAddress);
        return erc721.ownerOf(tokenid);
    }
    
     /* @dev Transfer of Ownership of a NFT token
   */
    function safeTransferFromERC721(address from, address to, uint256 tokenId) private{
         ERC721 erc721 = ERC721(ERC721TokenAddress);
         erc721.safeTransferFrom(from,to,tokenId);
        
    }
    
     /* @dev Checks Balance of ERC20 token holder   */
    
    function BalanceOfERC20Holder(address user) private view returns(uint){
        ERC20 erc20 = ERC20(ERC20TokenAddress);
        return erc20.balanceOf(user);
    }
    
     /* @dev Get cost of a NFT token 
   */
    
    function getCost(uint _tokenId) public view returns(uint){
        return tokenDetailByTokenID[_tokenId].price;
    }
    
    
      /* @dev Get Total Number of Tokens at Sale 
   */
   function TokensAtSale() public view returns (uint){
       return TotalTokensAtSale;
   }
    
    
     
   
    /* @dev List ERC721 token for Sale
   */
    function ListERC721TokenforSale(uint _tokenId,uint _amount) public returns(bool){
          require(_amount>0,"Cant be sold at 0 price");
          require(getOwnershipERC721(_tokenId)  == msg.sender,"Not a Valid Token");
          safeTransferFromERC721(msg.sender,address(this),_tokenId);
          
          Token memory newToken = Token ({
              owner:msg.sender,
              tokenid:_tokenId,
              price:_amount,
              forSale:true
          }); 
          tokenDetailByTokenID[_tokenId] = newToken;
         tokensforSale[msg.sender].push(newToken);
         TotalTokensAtSale++;
         return true;
    }
    
    
     /* @dev Buy NFT token
   */    
    function buyERC721Token(uint _tokenid,uint _amount) public returns(bool){
        require(BalanceOfERC20Holder(msg.sender) >= _amount,"Not Enough Balance!");
        require(tokenDetailByTokenID[_tokenid].forSale ==true,"Not for Sale!");
        ERC20 erc20 = ERC20(ERC20TokenAddress);
        erc20.transfer(tokenDetailByTokenID[_tokenid].owner,_amount);
        safeTransferFromERC721(address(this),msg.sender,_tokenid);
        tokenDetailByTokenID[_tokenid].forSale =false;
        
        return true;
    }
    
    
}