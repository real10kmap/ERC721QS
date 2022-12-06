 // SPDX-License-Identifier: CC0-1.0
 
 pragma solidity ^0.8.7;

interface IERC721QS {

    /// Logged when the guard of an NFT is changed 
    /// @notice Emitted when  the `guard` is changed
    /// The zero address for guard indicates that there is no guard address
    event updateGuardLog(uint256 tokenId,address newGuard,address oldGuard);
    
    /// @notice  Owner sets guard or guard modifies guard
    /// @dev The newGuard can not be zero address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the guard address for
    /// @param newGuard The new guard address of the NFT
    function changeGuard(uint256 tokenId, address newGuard) external;

  
    /// @notice Remove the guard of an NFT
    /// @dev The guard address is set to 0 address
    /// @dev Only guard can remove its own guard role
    /// Throws  if `tokenId` is not valid NFT
    /// @param tokenId The NFT to remove the guard address for
    function removeGuard(uint256 tokenId) external;

    /// @notice Get the guard address of an NFT
    /// @dev The zero address indicates that there is no guard
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the guard address for
    /// @return The guard address for this NFT
   function guardOf(uint256 tokenId) external view returns (address);   
}
