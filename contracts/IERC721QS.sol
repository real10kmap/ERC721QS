 // SPDX-License-Identifier: CC0-1.0
 
 pragma solidity ^0.8.7;

interface iERC721QS {

    /**
     * @dev Update the guardian of tokenid
     *
     * Requirements:
     *
     * - `guard` is null.
     * - `guard` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     */
    function changeGuard(uint256 tokenId, address newGuard) external;

  
    /**
     * @dev Remove the guard of a token
     *
     * Requirements:
     *
     * - `guard` is not be null.
     * - `guard` must be self.
     * - `tokenId` token must exist and be owned by `from`.
     */
    function removeGuard(uint256 tokenId) external;


    /**
     * @dev Retrieve user's assets
     *
     * Requirements:
     *
     * - Only guardians can call.
    */
    function findBack(uint256 tokenId) external;
}
