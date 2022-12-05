 // SPDX-License-Identifier: CC0-1.0
 
 pragma solidity ^0.8.7;

interface iERC721QS {

    event updateGuardLog(
        uint256 tokenId,
        address newGuard,
        address oldGuard
    );
    
    /**
     * @dev Update the Guard of tokenid
     *
     * Requirements:
     *
     * - `Guard` is null.
     * - `Guard` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     */
    function changeGuard(uint256 tokenId, address newGuard) external;

  
    /**
     * @dev Remove the guard of a token
     *
     * Requirements:
     *
     * - `Guard` is not be null.
     * - `Guard` must be self.
     * - `tokenId` token must exist and be owned by `from`.
     */
    function removeGuard(uint256 tokenId) external;


    /**
     * @dev Retrieve user's assets
     *
     * Requirements:
     *
     * - Only Guard can call.
    */
    function findBack(uint256 tokenId) external;
   
   
}
