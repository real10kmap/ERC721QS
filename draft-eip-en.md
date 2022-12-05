---
eip: <to be assigned>
title: Guard of NFT/SBT, an Extension of EIP-721
description: A new management role of NFT/SBT is defined, which realizes the separation of transfer right and holding right of NFT/SBT.
author: 5660.eth<5660@10kuni.io>
discussions-to: xxx
status: Draft
type: Standards Track
category: ERC
created: 2022-9-01
requirements: 20, 165, 721
---

## Abstract

This standard is an extension of ERC721. It separates the holding right and transfer right of NFT/SBT and defines a new role, `guard`. The flexibility of the `guard` setting enables the design of NFT anti-theft, NFT lending, NFT leasing, SBT, etc.

## Motivation

NFT is an asset that has both use and financial value.

Many cases of NFT theft currently exist, and current NFT anti-theft schemes, such as transferring NFT to cold wallets, make NFT inconvenient to be used.

In current NFT lending, the NFT owner needs to transfer the NFT to the NFT lending contract, and the NFT owner no longer has the right to use the NFT while he or she has obtained the loan. In the real world, for example, if a person takes out a mortgage on his own house, he still has the right to use that house.

There are some current solutions for NFT leasing, but they are not compatible with the current application protocols. For example, in eip4907, an address that leases an NFT cannot be seen directly in the NFT viewing platform (e.g. OpenSea). The lease agreement needs to be actively recognized by the application protocol for the lease to be valid.

In addition, for the current NFT installment, the purchaser will only be able to gain access to that NFT once the purchaser has paid in full; until then, the NFT remains in the seller's wallet or escrow contract. In the real world, for example, if you buy a phone in installments, you will immediately get the right to use the phone.

For SBT. The current mainstream view is that SBT is not transferable, which makes SBT bound to an Ether address. However, when the private key of the user address is leaked or lost, retrieving SBT will become a complicated task and there is no corresponding specification. The SBTs essentially realizes the separation of NFT holding rights and transfer rights. When the wallet where SBT is located is stolen or unavailable, SBT should be able to be recoverable. 

In addition, SBTs still need to be managed in use. For example, if a university issues a diploma SBT to its graduates, and if the university later finds that a graduate has committed academic misconduct or jeopardized the reputation of the university, it should have the ability to retrieve the diploma SBT. 


## Specification

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY" and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

### Contract Interface
  
```solidity

interface iERC721QS {

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
  ```

The `supportsInterface` method MUST return `true` when called with `0x...`.

### Rationale 

### Specification Management for Separation of Permissions

The standard defines a new role `guard` and regulates the permissions of `owner` and `guard` as follows

`owner`: when the guard of the NFT is empty, `owner` can transfer the NFT, and also set `guard`. However, when `guard` already exists for the NFT, `owner` cannot modify `guard`, and cannot transfer the NFT.

`guard`: The `guard` can remove its own `guard` identity or transfer the NFT to a specified address. For example, the `guard` can be set as the cold wallet address of the NFT holder, or an address trusted by the NFT holder. After the `owner` address of the NFT is abnormal, the `guard` can call the contract to transfer the NFT to the specified address.

### The design idea of the standard is as follows

#### Universality

There are many application scenarios for NFT/SBT, and there is no need to propose a dedicated eip for each specific application scenario, which would make the overall number of eips inevitably increase and add to the burden of developers. The standard is based on the analysis of the right attached to assets in the real world, and abstracts the right attached to NFT/SBT into holding right and transfer right making the standard more universal.

For example, the standard has and has more than the following use cases.

SBTs. The SBTs issuer can assign a uniform role of `guard` to the SBTs before they are minted, so that the SBTs cannot be transferred by the corresponding holder and can be managed by the SBTs issuer through the `guard`.

NFT anti-theft. NFT holders set the `guard` address of the NFT as their own cold wallet address, the NFT can still be used by the NFT holder, but the risk of theft is greatly reduced.

NFT lending. The borrower sets the `guard` of his own NFT as the lender's address, the borrower still has the right to use the NFT while obtaining the loan, but at the same time cannot transfer or sell the NFT. if the borrower defaults on the loan, the lender can transfer and sell the NFT.

#### Simplicity

Improvements to the ETH protocol should be as simple as possible. Entities should not be multiplied beyond necessity.

#### Extensibility
  
This standard only defines a `guard`, for the complex functions required by NFT and SBT, such as social recovery, multi-signature, expires management, according to the specific application scenarios, the `guard` can be set as a third-party protocol address, through the third-party protocol to achieve more flexible and diverse functions.

### Choice of name

The alternative names are `guardian` and `guard`, both of which basically match the permissions corresponding to the role: protection of NFT or necessary management according to its application scenarios. The `guard` has fewer characters than the `guardian` and is more concise.

## Backwards Compatibility

This standard can be fully EIP-721 compatible by adding an extension function set.

If the NFT issued based on the above standard does not have a `guard` role, then it is no different from the current NFT issued based on the eip721 standard.


## Reference Implementation
  
```solidity
  // SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IERC721QS.sol";



abstract contract ERC721QS is ERC721Enumerable, iERC721QS {
    struct Guard {
        address guardAddr;
    }

    // mapping the relationship of tokenId -> Guard
    mapping(uint256 => address) private token_guard_map;

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

    event updateGuardLog(
        uint256 tokenId,
        address newGuard,
        address oldGuard
    );

    // Get Token Guard
    function getPartners(uint256 tokenId)
        private
        view
        returns (address)
    {
        address guard = guardOf(tokenId);
        return (guard);
    }

    //Get Token Guard
    function guardOf(uint256 tokenId) public view returns (address) {
        return token_guard_map[tokenId];
    }

    // Edit Token Guardian
    function updateGuard(
        uint256 tokenId,
        address newGuard,
        bool allowNull
    ) internal {
        address guard = guardOf(tokenId);
        if (!allowNull) {
            require(newGuard != address(0), "new guard can not be null");
        }
        // Update guard for token
        if (guard != address(0)) {
            require(guard == _msgSender(), "only guard can change it self");
        }

        if (guard != address(0) || newGuard != address(0)) {
            token_guard_map[tokenId] = newGuard;
            emit updateGuardLog(tokenId, newGuard, guard);
        }
    }

    function _simpleRemoveGuard(uint256 tokenId) internal {
        token_guard_map[tokenId] = address(0);
    }

    // Edit Token Guardian
    function changeGuard(uint256 tokenId, address newGuard)
        public
        virtual
        override
    {
        updateGuard(tokenId, newGuard, false);
    }

    // remove token guardian
    function removeGuard(uint256 tokenId) public virtual override {
        updateGuard(tokenId, address(0), true);
    }


    function findBack(uint256 tokenId) public virtual override {
        address _guard = guardOf(tokenId);
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
```


## Security Considerations

When an NFT has a `guard`, if the `owner` has `approve` an address, the address still cannot transfer the NFT.

For NFT trading platforms (such as OpenSea, LooksRare) that trade through `setApprovalForAll` + holder's signature, when NFT has `guard`, it cannot be traded. It is recommended to prevent such pending orders by checking the interface beforehand.

## Copyright (copyright)

Copyright and related rights waived via CC0.
