// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract Prism1155 is ERC1155Supply, Ownable {
  
 using Strings for uint256;

  /**
  @dev global
 */
  uint256 public nextTokenId;
  uint256 public nextCollectionId;
  uint256 public nextProjectId = 1;
  bytes32 public merkleRoot;
  
  /**
  @dev mappings
 */
  
  //Project mappings
  mapping (uint256 => Project) public projects;
  mapping (uint256 => uint256[]) public projectToCollectionIds;
  
  //Collection mappings
  mapping(uint256 => Collection) public collections;
  mapping(uint256 => uint256[]) public collectionIdToTokenIds;
  
  //Token mappings
  mapping (uint256 => Token) public tokens;
  
  //Other mappings
  mapping(address => bool) public whitelistClaimed;
  

  /**
  @dev constructor
 */

  constructor(
    uint256 _nextTokenId,
    uint256 _nextCollectionId
  ) ERC1155("https://game.example/api/item.json"){

    nextTokenId = _nextTokenId;
    nextCollectionId = _nextCollectionId;
  }

  /**
  @dev structs
 */
  
  struct Project {
    string name;
    string projectURI; 
    address manager;
  }

  struct Collection {
    string name;
    uint256 projectId;
    uint256 invocations;
    uint256 maxInvocations; 
    bool paused;
    bool locked;
  }

  struct Token {
    string name;
    uint256 maxSupply;
    uint256 tokenPriceInWei;
    uint256 projectId;
    uint256 collectionId;
    bool paused;
    bool locked;
  }

  /**
  @dev modifiers
 */

  modifier onlyOpenCollection(uint256 _collectionId) {
    require(!collections[_collectionId].locked, "Only unlocked collections");
    require(collections[_collectionId].invocations + 1 <= collections[_collectionId].maxInvocations, "Must not exceed max invocations");
    require(!collections[_collectionId].paused || msg.sender == owner(), "Purchases must not be paused");
    require(!collections[_collectionId].locked, "Only unlocked collections");
    _;
  }

  modifier onlyTokenPrice(uint256 _tokenId, uint256 _value) {
      require(_value >= tokens[_tokenId].tokenPriceInWei,
      "Must send at least current price"
    );
    _;
  }

  modifier onlyAllowedToken(uint256 _tokenId) {
      require(exists(_tokenId), "Token must exist");
      require(tokens[_tokenId].maxSupply > totalSupply(_tokenId),"Must not have reached max Supply"); 
    _;
  }


  /**
  @dev setup and mint Functions
 */

  function mintTo(address _to, uint256 _tokenId, uint256 _amount, uint256 _collectionId) 
    external
    payable  
  {
    if (msg.sender != owner()){
      _splitFunds(_collectionId);
    }
    _mintTo(_to, _tokenId ,_collectionId,_amount);
  }

 function _mintTo(address _to,  uint256 _tokenId, uint256 _collectionId,  uint256 _amount) 
  internal
  onlyOpenCollection(_collectionId)
  onlyAllowedToken(_tokenId)
  {
    collections[_collectionId].invocations++;
    _mint(_to, _tokenId, _amount,"");
    emit Mint(_to,_tokenId,_collectionId,collections[_collectionId].invocations,tokens[_tokenId].tokenPriceInWei);
  }

  function mintBatch(
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) 
    public 
    onlyOwner 
    {
      
      for (uint256 i=0;i < _ids.length; i++){
        require(exists(_ids[i]), "Token must exist");
        require(_amounts[i] + totalSupply(_ids[i]) <= tokens[_ids[i]].maxSupply, "Supply must be smaller than Max");
      }
      _mintBatch(owner(),_ids, _amounts, _data);
    }


  /**
  @dev helpers 
 */

  function _splitFunds(uint256 _tokenId) 
    internal
    onlyTokenPrice(_tokenId, msg.value)
  {
    if (msg.value > 0) {
      uint256 tokenPriceInWei = tokens[_tokenId].tokenPriceInWei;
      uint256 refund = msg.value - tokenPriceInWei;
      if (refund > 0) {
        payable(msg.sender).transfer(refund);
      }
      payable(owner()).transfer(tokenPriceInWei);
    }
  }

  function addBaseURI(string memory _newBaseURI)
    public
    onlyOwner
  {
    _setURI(_newBaseURI);
  }

  /**
  @dev token functions
 */
  
    function createTokens(string[] memory _name, uint256[] memory _price, uint256[] memory _projectId, uint256[] memory _collectionId, uint256[] memory _maxSupply) 
    public 
    onlyOwner
  {
    for (uint256 i= 0; i < _name.length; i++) {
      Token memory token;
      token.name = _name[i];
      token.projectId = _projectId[i];
      token.collectionId = _collectionId[i];
      token.tokenPriceInWei = _price[i];
      token.maxSupply = _maxSupply[i]; 
      token.paused = true;
      token.locked = false;
      tokens[nextTokenId] = token;
      
      collectionIdToTokenIds[token.collectionId].push(nextTokenId);
      emit TokenAdded(token.name, nextTokenId,token.projectId ,token.collectionId , token.tokenPriceInWei, token.maxSupply);
      nextTokenId++;   
    }
  }
  
  function viewTokenConfig(uint256 _tokenId) public view
    returns (
      string memory name,
      uint256 projectId,
      uint256 collectionId,
      uint256 tokenPriceInWei,
      uint256 maxSupply,
      bool paused,
      bool locked
      )
  {
    name = tokens[_tokenId].name;
    projectId = tokens[_tokenId].projectId;
    collectionId = tokens[_tokenId].collectionId;
    tokenPriceInWei = tokens[_tokenId].tokenPriceInWei;
    maxSupply = tokens[_tokenId].maxSupply;
    paused = tokens[_tokenId].paused;
    locked = tokens[_tokenId].locked;
  }

  function exists(uint256 id) public view override returns (bool) {
      return tokens[id].maxSupply != 0;
    }

  function lockToken(uint256 _tokenId) public onlyOwner {
    tokens[_tokenId].locked = true;
  }

  function pauseToken(uint256 _tokenId) public onlyOwner {
    tokens[_tokenId].paused = !tokens[_tokenId].paused;
  }

  function addTokenMaxSupply(uint256 _tokenId, uint256 _maxSupply) public onlyOwner {
    tokens[_tokenId].maxSupply = _maxSupply;
  }

  function tokenURI(uint256 _tokenId)
  public
  view
  returns (string memory)
{
  return string(abi.encodePacked(
    uri(_tokenId),
    "/nfts/", Strings.toString(_tokenId)));
}

  /**
  @dev collection functions
 */

  function viewAllCollectionTokens(uint256 _collectionId) public view
    returns (uint256[] memory)
  {
    return collectionIdToTokenIds[_collectionId];
  }

  function lockCollection(uint256 _collectionId) public onlyOwner {
    collections[_collectionId].locked = true;
  }

  function pauseCollection(uint256 _collectionId) public onlyOwner {
    collections[_collectionId].paused = !collections[_collectionId].paused;
  }

  function addCollectionSize(uint256 _collectionId, uint256 _maxInvocations) public onlyOwner {
    collections[_collectionId].maxInvocations = _maxInvocations;
  }


  function createCollection(
    string memory _name,
    uint256 _maxInvocations,
    uint256 _projectId
  ) public onlyOwner {
    uint256 collectionId = nextCollectionId;
    collections[collectionId].name = _name;
    collections[collectionId].maxInvocations = _maxInvocations;
    collections[collectionId].paused = true;
    collections[collectionId].locked = false;
    projectToCollectionIds[_projectId].push(nextCollectionId);
    nextCollectionId++;
  }


  function viewCollectionDetails(uint256 _collectionId)
    public
    view
    returns (
      string memory name,
      uint256 projectId,
      uint256 invocations,
      uint256 maxInvocations,
      bool paused,
      bool locked
    )
  {
    name = collections[_collectionId].name;
    projectId = collections[_collectionId].projectId;
    maxInvocations = collections[_collectionId].maxInvocations;
    invocations = collections[_collectionId].invocations;
    paused = collections[_collectionId].paused;
    locked = collections[_collectionId].locked;
  }

  /**
  @dev project functions
 */

function createProject(
    string memory _name,
    string memory _projectURI,
    address _manager
  ) public onlyOwner {

    Project memory project;
    project.name = _name;
    project.projectURI = _projectURI;
    project.manager = _manager;
    projects[nextProjectId] = project;
    nextProjectId++;
  }

  function viewCollectionsOfProjects(uint256 _projectId) public view returns (uint256[] memory _collections){
    return projectToCollectionIds[_projectId];
  }

    /**
  @dev events
 */
  event Mint(
    address indexed _to,
    uint256 indexed _tokenId,
    uint256 indexed _collectionId,
    uint256 _invocations,
    uint256 _value
  );

  event TokenAdded(
    string _name,
    uint256 indexed _tokenID,
    uint256 indexed _projectId,
    uint256 indexed _collectionId,
    uint256 _price,
    uint256 _maxSupply
  );

}