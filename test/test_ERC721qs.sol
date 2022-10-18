// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721QS.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract TestERC721QSNFT is ERC721QS1P, Ownable {
    constructor() ERC721("NFT", "symbol") {
        updateDevAddr(_msgSender(), true);
        updateFriend(_msgSender(), true);
        setMktAddress(_msgSender());
        setPause(false);
        updateStage(1);
        stageSupply[1] = 100;
    }

    address public mktAddress;

    function setMktAddress(address _addr) public onlyOwner {
        require(_addr != address(0), "mkt address shall not be black hole");
        mktAddress = _addr;
    }

    uint256 public PRICE;
    address public payToken;

    function setPayToken(address _token) public onlyOwner {
        payToken = _token;
    }

    function updatePrice(uint256 newPrice) public onlyOwner {
        PRICE = newPrice;
    }

    uint256 public MAX_ELEMENTS = 20000;

    function updateMaxSupply(uint256 _supply) public onlyOwner {
        MAX_ELEMENTS = _supply;
    }

    uint256 public MAX_BUY_NUM = 10;

    function setMaxBuyNum(uint256 _num) public onlyOwner {
        MAX_BUY_NUM = _num;
    }

    mapping(address => bool) public devAddrMapping;
    mapping(address => bool) public friendMapping;

    function updateDevAddr(address _dev, bool _enabled) public onlyOwner {
        devAddrMapping[_dev] = _enabled;
    }

    function updateFriend(address _friend, bool _enabled) public onlyOwner {
        friendMapping[_friend] = _enabled;
    }

    modifier onlyDev() {
        require(devAddrMapping[_msgSender()], "only dev can call!");
        _;
    }

    modifier onlyFriend() {
        require(friendMapping[_msgSender()], "only friend can call!");
        _;
    }

    bool private PAUSE = true;

    // simplified token data store
    mapping(uint256 => uint32[]) public nftData;
    function getNftData(uint256 tokenId, uint8 key_index) external view returns(uint32) {
        return nftData[tokenId][key_index];
    }
    uint8 constant key_type = 0; // key type
    uint8 constant key_rarity = 1; // rarity
    uint8 constant key_base_atk = 2; // base atk  index
    uint8 constant key_level = 3; // level
    uint8 constant key_real_atk = 4; // real atk
    uint8 constant key_fatigue = 5; // monster fatigue

    // token data fields
    uint8 constant dataFields = 6;

    uint256 public stage = 0;
    // saves the total supply of every stage
    mapping(uint256 => uint256) public stageSupply;
    // saves the current stage mint progess
    mapping(uint256 => uint256) public stageProgess;

    function updateStageSupply(
        uint8[] calldata _stages,
        uint256[] calldata _supply
    ) public onlyOwner {
        for (uint8 i = 0; i < _stages.length; i++) {
            stageSupply[_stages[i]] = _supply[i];
        }
    }

    function updateStage(uint256 _stage) public onlyOwner {
        stage = _stage;
    }

    string public baseTokenURI;

    event PauseEvent(bool pause);

    modifier saleIsOpen() {
        require(totalSupply() <= MAX_ELEMENTS, "Soldout!");
        require(!PAUSE, "Sales not open");
        _;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    event Mint(address addr, uint256 price, uint256 tokenId);

    function mint(uint256 buyNum) public payable saleIsOpen {
        require(buyNum > 0, "can not mint zero nft!");
        require(buyNum <= MAX_BUY_NUM, "reach max buy num!");
        require(stage > 0, "not in sale stage!");
        require(
            stageProgess[stage] + buyNum <= stageSupply[stage],
            "current stage sold out!"
        );
        address wallet = _msgSender();
        uint256 _tokenId = 0;
        for (uint8 i = 0; i < buyNum; i++) {
            _tokenId = totalSupply() + 1;
            require(_tokenId <= MAX_ELEMENTS, "SALE OUT");
            emit Mint(wallet, PRICE, _tokenId);
            _safeMint(wallet, _tokenId);
        }
        stageProgess[stage] += buyNum;
    }

    function syncData(uint256[] calldata tokenIds, uint32[] calldata _data)
        public
        onlyFriend
    {
        uint256 len = tokenIds.length;
        require(
            len * dataFields == _data.length,
            "data not valid, length invalid"
        );
        for (uint256 i = 0; i < len; i++) {
            uint256 tokenId = tokenIds[i];
            nftData[tokenId] = new uint32[](dataFields);
            nftData[tokenId][0] = _data[i * dataFields + 0];
            nftData[tokenId][1] = _data[i * dataFields + 1];
            nftData[tokenId][2] = _data[i * dataFields + 2];
            nftData[tokenId][3] = _data[i * dataFields + 3];
            nftData[tokenId][4] = _data[i * dataFields + 4];
            nftData[tokenId][5] = _data[i * dataFields + 5];
        }
    }

    event UpdateAttr(uint256 indexed tokenId, uint8 key, uint32 value);

    function updateAttr(
        uint256 tokenId,
        uint8 _key,
        uint32 _value
    ) public onlyFriend {
        nftData[tokenId][_key] = _value;
        emit UpdateAttr(tokenId, _key, _value);
    }

    function batchUpdateAttr(
        uint256[] calldata tokenIds,
        uint8 _key,
        uint32[] calldata _values
    ) public onlyFriend {
        require(tokenIds.length == _values.length, "length not valid");
        for (uint256 i = 0; i < _values.length; i++) {
            updateAttr(tokenIds[i], _key, _values[i]);
        }
    }

    function bulkGetData(uint256[] calldata tokenIds)
        public
        view
        returns (uint32[] memory result)
    {
        result = new uint32[](tokenIds.length * dataFields);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tid = tokenIds[i];
            if (nftData[tid].length == 0) {
                // not inited
                for (uint8 j = 0; j < dataFields; j++) {
                    result[i * dataFields + j] = 0;
                }
            } else {
                for (uint8 j = 0; j < dataFields; j++) {
                    result[i * dataFields + j] = nftData[tid][j];
                }
            }
        }
        return result;
    }

    function getCardData(uint256 tokenId)
        public
        view
        returns (uint32[] memory result)
    {
        result = new uint32[](dataFields);
        require(ownerOf(tokenId) != address(0), "nft not valid!");
        if (nftData[tokenId].length == 0) {
            // not inited
            for (uint8 j = 0; j < dataFields; j++) {
                result[j] = 0;
            }
        } else {
            for (uint8 j = 0; j < dataFields; j++) {
                result[j] = nftData[tokenId][j];
            }
        }
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

    function setPause(bool _pause) public onlyOwner {
        PAUSE = _pause;
        emit PauseEvent(PAUSE);
    }
}
