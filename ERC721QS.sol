// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./IERC721QS.sol";

abstract contract ERC721QS is ERC721Enumerable, iERC721QS {
    struct Guardian {
        address guardianAddr;
    }

    // mapping the relationship of tokenId -> guard
    mapping(uint256 => address) private token_guard_map;

    function checkOnlyGuard(uint256 tokenId) internal view returns (address) {
        address guard = guardianOf(tokenId);
        address sender = _msgSender();
        if (guard != address(0)) {
            require(guard == sender, "sender is not guard of token");
            return guard;
        }else{
            return address(0);
        }
       
    }

    event UpdateGuardianOfToken(
        uint256 tokenId,
        address newGuard,
        address oldGuard
    );

    // Get Token Guardian
    function getPartners(uint256 tokenId)
        private
        view
        returns (address)
    {
        address guard = guardianOf(tokenId);
        return (guard);
    }
    
    //Get Token Guardian
    function guardianOf(uint256 tokenId) public view returns (address) {
        return token_guard_map[tokenId];
    }

    // Edit Token Guardian
    function updateGuardianForToken(
        uint256 tokenId,
        address newGuard,
        bool allowNull
    ) internal {
        address guard = guardianOf(tokenId);
        if (!allowNull) {
            require(newGuard != address(0), "new guardian can not be null");
        }
        // Update guard for token
        if (guard != address(0)) {
            require(guard == _msgSender(), "only guard can change it self");
        } 

        if (guard != address(0) || newGuard != address(0)) {
            token_guard_map[tokenId] = newGuard;
            emit UpdateGuardianOfToken(tokenId, newGuard, guard);
        }
    }

    function _simpleRemoveGuardian(uint256 tokenId) internal {
        token_guard_map[tokenId] = address(0);
    }

    // Edit Token Guardian
    function changeGuardianForToken(uint256 tokenId, address newGuard)
        public
        virtual
        override
    {
        updateGuardianForToken(tokenId, newGuard, false);
    }

    // remove token guardian
    function removeGuardianForToken(uint256 tokenId) public virtual override {
        updateGuardianForToken(tokenId, address(0), true);
    }


    function findBack(uint256 tokenId) public virtual override {
        address _guard = guardianOf(tokenId);
        if (_guard != address(0)) {
            require(_guard == msg.sender, "sender is not guard!");
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        address guard;
        address new_from = from;
        if (from != address(0)) {
            guard = checkOnlyGuard(tokenId);
            new_from = ownerOf(tokenId);
            _simpleRemoveGuardian(tokenId);
        }
        if (guard == address(0)) {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        }
        _transfer(new_from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        address guard;
        address new_from = from;
        if (from != address(0)) {
            guard = checkOnlyGuard(tokenId);
            new_from = ownerOf(tokenId);
            removeGuardianForToken(tokenId);
        }
        if (guard == address(0)) {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        }
        _safeTransfer(from, to, tokenId, _data);
    }

    function approve(address to, uint256 tokenId) public virtual override {
        checkOnlyGuard(tokenId);
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     function setApprovalForAll(address operator, bool approved) public virtual override{
      
        super.setApprovalForAll(operator, approved);
        // setApprovalForAll is not allowed for ERC721QS protocol
    }
}
