---
eip:
title:Guard of NFT/SBT，an Extension of EIP-721
Description:定义了一个新的NFT/SBT的管理角色，guard，实现了NFT/SBT的转移权和持有权的分离。
A new management role of NFT/SBT is defined, which realizes the separation of transfer right and holding right of NFT/SBT.
Author：
discussions-to：
status: Draft	
type: Standards Track	
category (*only required for Standards Track): ERC	
created	: 2022-9-01
requires (*optional): 20, 165, 721
---
---
eip: 4907
title: Rental NFT, an Extension of EIP-721
description: Add a time-limited role with restricted permissions to EIP-721 tokens.
author: Anders (@0xanders), Lance (@LanceSnow), Shrug <shrug@emojidao.org>
discussions-to: https://ethereum-magicians.org/t/idea-erc-721-user-and-expires-extension/8572
status: Final
type: Standards Track
category: ERC
created: 2022-03-11
requires: 165, 721
---

|eip|title|Description|Author|discussions-to|status|type|category|created|requires|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|xxx|Guard of NFT/SBT，an Extension of EIP-721|定义了一个新的NFT/SBT的管理角色，guard，实现了NFT/SBT的转移权和持有权的分离。A new management role of NFT/SBT is defined, which realizes the separation of transfer right and holding right of NFT/SBT.|xxx|xxx|Draft|Standards Track|ERC|2022-9-01|20, 165, 721|

## Abstract(摘要)

本标准是ERC721的扩展。它将NFT/SBT的持有权（holding right）和转移权(transfer right)分离，并新定义了一个角色， `guard`。`guard`设置的灵活性，使得NFT防盗、NFT借贷、NFT租赁和SBT等的设计成为可能。

## Motivation（动机）

NFT是一种兼具使用价值和金融价值的资产。

当前存在许多NFT被盗案例，而目前NFT的防盗方案，例如将NFT转入冷钱包，使得NFT不方便被使用。

在当前NFT抵押借贷中，NFT所有者需要将NFT转入抵押借贷合约，而NFT所有者虽然获得了借款，但不再具有使用权。而在现实世界中，比如一个人以自己的房产进行了抵押贷款，他仍然具有该房产的使用权。

（当前也有一些对于NFT租赁的解决方案，但对目前的已有的应用协议不够兼容。例如，在eip4907中，一个地址租用了一个NFT，目前无法在NFT查看平台（例如OpenSea）直接看到该地址的租用的NFT。该租赁协议需要得到应用协议主动认可，此租赁才能生效。

此外，对于目前的NFT分期付款，只有当购买者付完全款后，购买者才能够获得该NFT使用权，在此之前，NFT依然在销售者钱包或者托管合约中。而现实世界中，例如你分期付款购买了一部手机，你将立刻获得手机使用权。）

对于SBT。目前主流观点是认为SBT不可转移，这使得SBT与以太坊地址进行了绑定。但在使用者地址私钥泄露或丢失时，找回SBT将成为一个复杂的工作且没有相应的规范。SBT本质上也是实现了NFT的持有权和转移权的分离，当SBT所在钱包被盗或者不可用时，SBT应该可以被找回。

另外，SBT使用中，仍然需要被管理。比如某大学给自己的毕业生发放了毕业证书SBT，而如果之后该大学发现某个毕业生学术不端或者危害了该大学的声誉，它应该具有收回毕业证书SBT的能力。

## Specification（规格）

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY" and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

https://github.com/real10kmap/ERC721QS/blob/main/contracts/IERC721QS.sol

xxxx(需要根据合约可能做的进一步解释)

## Rationale（基本原理）

权限分离的规范管理

该标准定义了一个新的角色`guard`，并对`owner`和`guard`的权限进行了以下规范。

`owner`:当`guard`为空时，`owner`可以进行NFT的转移操作，也可以设置`guard`。但NFT已存在`guard`时，不经`guard`允许，`owner`无法修改`guard`，且无法对NFT进行转移操作。

`guard`: 监护人，可以设置为NFT持有者的冷钱包地址，或者是NFT持有者信任的地址。`guard`可以自行移除（remove）自己的`guard`身份，或者在NFT所在的`owner`地址出现异常后，调用合约，将 NFT转移到指定的地址。

该标准的设计思想如下

通用性

NFT/SBT的应用场景很多，没必要为每个具体的应用场景提出专用的eip，这会使得eip整体数量不可避免的增多，增加开发者的负担。该标准基于现实世界中资产所附带的权力的分析，将NFT所附带的权力抽象为持有权和转移权，使得标准具有较强的通用性。

例如，该标准有且不止有以下用例。

SBT。在SBT mint前，即对SBT统一赋予指定的`guard`角色，那么SBT将不可被持有者转移，且SBT发行方可通过`guard`对SBT进行管理。

NFT防盗。NFT持有者将该NFT的`guard`地址设置为自己的冷钱包地址，该NFT仍然可被NFT持有者使用，但被盗风险大大降低。

NFT抵押借贷。借款人将`guard`设置为贷款人地址，借款人在获得借款的同时，仍具有该NFT的使用权，但同时无法转移或出售该NFT。如果借款人违约，贷款人可以对该NFT进行转移和出售。

简洁性

对ETH协议的改进，应尽可能简洁，如无必要，勿增实体。

扩展性

本标准仅定义了一个`guard`，对于NFT和SBT所需要的复杂功能，例如社交恢复、多签、时间管理，根据具体应用场景，可以将`guard`设置为第三方协议地址，通过第三方协议实现更加灵活多样的功能。

对名字的选择

备选的名字有`guardian`和`guard`，它们都基本符合该角色对应的权限：对NFT进行保护或根据其应用场景进行必要的管理。而`guard`字符数少于`guardian`，更加简洁。

## Backwards Compatibility（向后兼容性）

As mentioned in the specifications section, this standard can be fully EIP-721 compatible by adding an extension function set.

In addition, new functions introduced in this standard have many similarities with the existing functions in EIP-721. This allows developers to easily adopt the standard quickly.

## Test Cases（测试用例）

https://github.com/real10kmap/ERC721QS/tree/main/test 

## Reference Implementation（参考实现）

https://github.com/real10kmap/ERC721QS/blob/main/contracts/ERC721QS.sol

## Security Considerations（安全注意事项）

当NFT具有`guard`时，如果`owner`对某合约进行了`approve`，合约依然无法对该NFT进行转移等操作。

对于通过`approve`+签名进行交易的NFT交易平台（如OpenSea、LooksRare），NFT具有`guard`时，可以通过签名被挂单，但不可被交易。建议事前通过接口进行检查阻止此类挂单。

## Copyright（版权）

Copyright and related rights waived via CC0.
