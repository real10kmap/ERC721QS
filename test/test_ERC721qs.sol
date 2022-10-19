// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../ERC721QS.sol";
import "./../Ownable.sol";
import "./../ERC20.sol";

contract TestERC721QSNFT is ERC721QS, Ownable {
    constructor() ERC721("NFT", "symbol") {

    }

    uint256 public MAX_ELEMENTS = 20000;

    uint256 public MAX_BUY_NUM = 10;

    bool private PAUSE = true;

    // simplified token data store
    mapping(uint256 => uint32[]) public nftData;
    function getNftData(uint256 tokenId, uint8 key_index) external view returns(uint32) {
        return nftData[tokenId][key_index];
    }

    // token data fields
    uint8 constant dataFields = 6;

    uint256 public stage = 0;
    // saves the total supply of every stage
    mapping(uint256 => uint256) public stageSupply;
    // saves the current stage mint progess
    mapping(uint256 => uint256) public stageProgess;


    string public baseTokenURI;

    event PauseEvent(bool pause);

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    event Mint(address addr,  uint256 tokenId);

    function mint(uint256 buyNum) public payable {
        require(buyNum > 0, "can not mint zero nft!");

        address wallet = _msgSender();
        uint256 _tokenId = 0;
        for (uint8 i = 0; i < buyNum; i++) {
            _tokenId = totalSupply() + 1;
            require(_tokenId <= MAX_ELEMENTS, "SALE OUT");
            emit Mint(wallet, _tokenId);
            _safeMint(wallet, _tokenId);
        }
        stageProgess[stage] += buyNum;
    }


    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

}
