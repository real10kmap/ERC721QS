---
eip: xxx
title: Guard of NFT/SBT, an Extension of EIP-721
description: A new management role of NFT/SBT, guard, which realizes the separation of transfer right and holding right of NFT/SBT is defined. A new management role of NFT/SBT is defined, which realizes the separation of transfer right and holding right of NFT/SBT.
author: xxx
discussions-to: xxx
status: Draft
type: Standards Track
category: ERC
created: 2022-9-01
requirements: 20, 165, 721
---

## Abstract(Abstract)

This standard is an extension of ERC721. It separates the holding right and transfer right of NFT/SBT and defines a new role, `guard`. The flexibility of the `guard` setting enables the design of NFT theft prevention, NFT lending, NFT leasing, SBT, etc.

## Motivation

NFT is an asset that has both use and financial value.

Many cases of NFT theft currently exist, and current NFT theft prevention schemes, such as transferring NFT to cold wallets, make NFT inconvenient to be used.

In current NFT secured lending, the NFT owner needs to transfer the NFT to a secured lending contract, and the NFT owner no longer has the right to use it even though he or she has obtained the loan. In the real world, for example, if a person takes out a mortgage on his own property, he still has the right to use that property.

(There are some current solutions for NFT leasing, but they are not compatible with the current application protocols. For example, in eip4907, an address that leases an NFT cannot be seen directly in the NFT viewing platform (e.g. OpenSea). the lease agreement needs to be actively approved by the application protocol for the lease to be valid.

In addition, for the current NFT installment, the purchaser will only be able to gain access to that NFT once the purchaser has paid in full; until then, the NFT remains in the seller's wallet or escrow contract. (In the real world, for example, if you buy a phone in installments, you will immediately get the right to use the phone.)

For SBT. the current mainstream view is that SBT is not transferable, which makes SBT tied to an Ether address. The SBT is also essentially a separation of the right to hold and the right to transfer the NFT, so when the wallet where the SBT is located is stolen or unavailable, the SBT should be recoverable.

In addition, SBTs still need to be managed in use. For example, if a university issues a diploma SBT to its graduates, and if the university later finds that a graduate has committed academic misconduct or jeopardized the reputation of the university, it should have the ability to retrieve the diploma SBT.

## Specification

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY" and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

### Contract Interface

https://github.com/real10kmap/ERC721QS/blob/main/contracts/IERC721QS.sol

xxxx (further explanation required as may be done under the contract)

### Rationale (fundamentals)

### Specification Management for Separation of Permissions

The standard defines a new role `guard` and regulates the permissions of `owner` and `guard` as follows

`owner`:When `guard` is empty, `owner` can perform the transfer operation of NFT, and also set `guard`. However, when `guard` already exists for NFT, `owner` cannot modify `guard` without `guard` permission, and cannot perform transfer operations on NFT.

`guard`: The guardian, which can be set to the cold wallet address of the NFT holder, or an address trusted by the NFT holder. The `guard` can remove (remove) its own `guard` identity or invoke a contract to transfer the NFT to a specified address after an exception occurs at the `owner` address where the NFT is located.

### The standard is designed with the following ideas in mind

#### Generality

There are many application scenarios for NFT/SBT, and there is no need to propose a dedicated eip for each specific application scenario, which would make the overall number of eips inevitably increase and add to the burden of developers. The standard is based on the analysis of the power attached to assets in the real world, and abstracts the power attached to NFTs into holding and transferring rights, making the standard more general.

For example, the standard has and has more than the following use cases.

SBT. before SBT mint, i.e., the SBT is uniformly assigned the role of `guard`, then the SBT will not be transferable by the holder, and the SBT issuer can manage the SBT through the `guard`.

NFT anti-theft. NFT holders set the `guard` address of the NFT as their own cold wallet address, the NFT can still be used by the NFT holder, but the risk of theft is greatly reduced.

NFT secured lending. The borrower sets the `guard` as the lender's address, the borrower still has the right to use the NFT while obtaining the loan, but at the same time cannot transfer or sell the NFT. if the borrower defaults on the loan, the lender can transfer and sell the NFT.

#### Simplicity

Improvements to the ETH protocol should be as simple as possible and should not add entities if not necessary.

#### Extensibility

This standard only defines a `guard`, for the complex functions required by NFT and SBT, such as social recovery, multi-signature, time management, according to the specific application scenarios, the `guard` can be set as a third party protocol address, through the third party protocol to achieve more flexible and diverse functions.

### Choice of name

The alternative names are `guardian` and `guard`, both of which basically match the permissions corresponding to the role: protection of NFT or necessary management according to its application scenarios. The `guard` has fewer characters than the `guardian` and is more concise.

## Backwards Compatibility

As mentioned in the specifications section, this standard can be fully EIP-721 compatible by adding an extension function set.

In addition, new functions introduced in this standard have many similarities with the existing functions in EIP-721. This allows developers to easily adopt the standard quickly.

## Test Cases

https://github.com/real10kmap/ERC721QS/tree/main/test 

## Reference Implementation

https://github.com/real10kmap/ERC721QS/blob/main/contracts/ERC721QS.sol

## Security Considerations

When an NFT has a `guard`, if the `owner` has `approved` a contract, the contract is still unable to perform operations such as transferring the NFT.

For `approve` + signature for trading NFT trading platform (such as OpenSea, LooksRare), NFT has `guard`, the signature can be pending orders, but can not be traded. It is recommended to prevent such pending orders by checking the interface beforehand.

## Copyright (copyright)

Copyright and related rights waived via CC0.


Translated with www.DeepL.com/Translator (free version)
