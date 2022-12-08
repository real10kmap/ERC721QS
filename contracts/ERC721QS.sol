// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IERC721QS.sol";

abstract contract ERC721QS is ERC721Enumerable, IERC721QS {

    mapping(uint256 => address) internal token_guard_map;

    /// @notice Update the guard of the NFT
    /// @dev Delete function: set guard  to 0 address,update function: set guard to new address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to update the guard address for
    /// @param newGuard The newGuard address
    /// @param allowNull Allow 0 address
    function updateGuard(uint256 tokenId,address newGuard,bool allowNull) internal virtual {
        address owner = ownerOf(tokenId); 
        address guard = guardOf(tokenId);
        if (!allowNull) {
            require(newGuard != address(0), "New guard can not be null");
        }
         if (guard != address(0)) { 
            require(guard == _msgSender(), "only guard can change it self"); 
        } else { 
            require(owner == _msgSender(), "only owner can set guard"); 
        } 

        if (guard != address(0) || newGuard != address(0)) {
            token_guard_map[tokenId] = newGuard;
            emit UpdateGuardLog(tokenId, newGuard, guard);
        }
    }

    /// @notice  Owner can set guard of the NFT and guard can modifiy guard of the NFT
    /// If the NFT has a guard role, the owner of the NFT cannot modify guard
    /// @dev The newGuard can not be zero address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the guard address for
    /// @param newGuard The new guard address of the NFT
    function changeGuard(uint256 tokenId, address newGuard) public virtual
    {
        updateGuard(tokenId, newGuard, false);
    }

    /// @notice Remove the guard of the NFT
    /// Only guard can remove its own guard role
    /// @dev The guard address is set to 0 address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to remove the guard address for
    function removeGuard(uint256 tokenId) public virtual  {
        updateGuard(tokenId, address(0), true);
    }
    
    /// @notice Transfer the NFT and remove its guard role
    /// @dev The NFT is transferred to `to`and the guard address is set to 0 address
    /// Throws if `tokenId` is not valid NFT
    /// @param from The address of the previous owner of the NFT
    /// @param to The address of NFT recipient 
    /// @param tokenId The NFT to get transferred for
    function transferAndRemove(address from,address to,uint256 tokenId) public virtual {
        transferFrom(from,to,tokenId);
        removeGuard(tokenId);
    }
    
    /// @notice Get the guard address of the NFT
    /// @dev The zero address indicates that there is no guard
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the guard address for
    /// @return The guard address for the NFT
    function guardOf(uint256 tokenId) public view virtual returns (address) {
        return token_guard_map[tokenId];
    }
    
    
    /// @notice Check the guard address
    /// @dev The zero address indicates there is no guard
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to check the guard address for
    /// @return The guard address of the NFT
    function checkOnlyGuard(uint256 tokenId) internal view virtual returns (address) {
        address guard = guardOf(tokenId);
        address sender = _msgSender();
        if (guard != address(0)) {
            require(guard == sender, "sender is not guard of token");
            return guard;
        }else{
            return address(0);
        }
    }
 
    /// @dev Before transferring the NFT, need to check the gurard address
    function transferFrom(address from,address to,uint256 tokenId) public virtual override {
        address guard;
        address new_from = from;
        if (from != address(0)) {
            guard = checkOnlyGuard(tokenId);
            new_from = ownerOf(tokenId);
        }
        if (guard == address(0)) {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        }
        _transfer(new_from, to, tokenId);
    }

    /// @dev Before safely transferring the NFT, need to check the gurard address
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public virtual override {
        address guard;
        address new_from = from;
        if (from != address(0)) {
            guard = checkOnlyGuard(tokenId);
            new_from = ownerOf(tokenId);
        }
        if (guard == address(0)) {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        }
        _safeTransfer(from, to, tokenId, _data);
    }
    
    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721QS).interfaceId || super.supportsInterface(interfaceId);
    }
}
