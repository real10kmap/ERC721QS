// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IERC721QS.sol";



abstract contract ERC721QS is ERC721Enumerable, iERC721QS {
    struct Guard {
        address guardAddr;
    }

    /// mapping the relationship of tokenId -> Guard
    mapping(uint256 => address) private token_guard_map;

    /// @notice Verify the Guard address
    /// @dev    The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param The NFT tokenId
    function checkOnlyGuard(uint256 tokenId) internal view returns (address) {
        address guard = guardOf(tokenId);
        address sender = _msgSender();
        if (guard != address(0)) {
            require(guard == sender, "sender is not guard of token");
            return guard;
        }else{
            return address(0);
        }

    }

    /// @notice Returns the set gurard address
    /// @dev    return Guard address
    /// Throws if `tokenId` is not valid NFT
    /// @param The NFT tokenId
    function guardOf(uint256 tokenId) public view returns (address) {
        return token_guard_map[tokenId];
    }

    /// @notice Edit Token Guard
    /// @dev    Delete function: set guard  to 0 address,update function: set guard to new address
    /// Throws If `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the user address for
    /// @param The newGuard address
    /// @param Allow 0 address
    function updateGuard(
        uint256 tokenId,
        address newGuard,
        bool allowNull
    ) internal {
        address ward = ownerOf(tokenId); 
        address guard = guardOf(tokenId);
        if (!allowNull) {
            require(newGuard != address(0), "New guard can not be null");
        }
        // Update guard for token
       
         if (guard != address(0)) { 
            require(guard == _msgSender(), "only guard can change it self"); 
        } else { 
            require(ward == _msgSender(), "only owner can set guard"); 
        } 

        if (guard != address(0) || newGuard != address(0)) {
            token_guard_map[tokenId] = newGuard;
            emit updateGuardLog(tokenId, newGuard, guard);
        }
    }

    function _simpleRemoveGuard(uint256 tokenId) internal {
        token_guard_map[tokenId] = address(0);
    }

    /// @notice Set Guard as the new address
    /// @dev    
    /// @param tokenId The NFT to get the user address for
    /// @param The newGuard address
    function changeGuard(uint256 tokenId, address newGuard) public virtual override
    {
        updateGuard(tokenId, newGuard, false);
    }

    /// @notice remove token Guard
    /// @dev    The guard management address is set to 0 address
    /// Throws  if `tokenId` is not valid NFT
    /// @param  tokenId The NFT tokenId
    function removeGuard(uint256 tokenId) public virtual override {
        updateGuard(tokenId, address(0), true);
    }
 
    /// @notice transfer NFT 
    /// @dev    Before transferring the token, you need to check the gurard address
    /// Throws  if `tokenId` is not valid NFT
    /// @param  address from The address of NFT user
    /// @param  address to The address of NFT recipient 
    /// @param  tokenId The NFT to get the user address for
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
            _simpleRemoveGuard(tokenId);
        }
        if (guard == address(0)) {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        }
        _transfer(new_from, to, tokenId);
    }

    /// @notice safe transfer NFT
    /// @dev    Before transferring the token, you need to check the gurard address
    /// Throws  if `tokenId` is not valid NFT
    /// @param  address from The address of NFT user
    /// @param  address to The address of NFT recipient 
    /// @param  tokenId The NFT to get the user address for
    /// @param  _data 
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
            removeGuard(tokenId);
        }
        if (guard == address(0)) {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        }
        _safeTransfer(from, to, tokenId, _data);
    }

    /// @notice Authorization verification
    /// @dev    Add guard verification based on the original authorization verification
    /// @param  address to The address of NFT recipient  verification
    /// @param  tokenId The NFT to get the user address for
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
