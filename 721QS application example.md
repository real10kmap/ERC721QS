# 721qs使用示例

## SBT实现

### 传统方式

关闭NFT的转移功能，NFT #0001（owner: Alice）, NFT#0002（owner: Bob）

#### 缺点

在SBT使用者地址私钥泄露或丢失时，找回SBT将成为一个复杂的工作且没有相应的规范。

另外，SBT使用中，仍然需要被管理。比如某大学给自己的毕业生发放了毕业证书SBT，而如果之后该大学发现某个毕业生学术不端或者危害了该大学的声誉，它应该具有收回毕业证书SBT的能力。

### 721QS实现方式

1,在SBT被mint前，即对SBT赋予指定的guard地址。

2,SBT被mint后，SBT#0001（owner: Alice, guard: guard’s address）, SBT#0002（owner: Bob, guard: guard’s address）

3,当Alice的地址被盗或者私钥丢失后，Alice向guard提出申请，guard验证后将SBT转移至Alice的新地址。

4,如果guard发现Bob违反了SBT的使用规范，guard可以收回Bob的SBT。例如，某大学向自己的毕业生发放了大学学位证明SBT，事后发现有的大学生学术论文抄袭或者造假，那么该大学就可以收回相应的SBT。 

### 图示

![SBT-EN](http://assets.processon.com/chart_image/63622b19f346fb33540d3308.png)

传统的SBT的设计方案，是通过关闭NFT的转移功能来实现SBT的不可转移特性；可撤销特性是通过SBT的合约所有者进行管理和实现。

721QS则是在SBT被mint前，即对SBT赋予指定的guard地址，由于存在guard，SBT即无法被owner转移，而可以通过guard实现SBT的可撤销和社交恢复。

## NFT防盗示例

### 传统方式

1,Alice mint NFT，NFT（owner: Alice's address）

2，Alice对NFT进行防盗，将NFT转至冷钱包，NFT（owner: Alice's cold wallet address）

#### 缺点

此时，NFT虽然实现了防盗，但NFT使用便利性大大降低。

### 721QS实现方式

1,Alice mint NFT，NFT（owner :Alice's  hot wallet address，guard:0）

2,Alice对NFT进行防盗，设置guard，NFT（owner:Alice's  hot wallet address，guard:Alice's cold wallet address）

这时，不影响Alice利用热钱包地址证明自己对NFT的持有权，并享受NFT附加的实用价值。

3,如果Alice的热钱包私钥泄露（或私钥丢失，或者进行了不安全的合约授权），黑客通过私钥或者合约授权想要转移NFT，该操作会被拒绝。黑客无法转移该NFT，黑客气死。

4,Alice发现自己私钥泄露，通过guard将NFT转移至安全地址。NFT(owner: Alice's new address，guard :Alice's cold wallet address)

### 图示
![NFT ante-theft](http://assets.processon.com/chart_image/6362289ff346fb33540d23d8.png)

## NFT借贷示例

### 传统方式

1,Alice mint NFT，NFT（owner: Alice's address）

2，Alice想抵押NFT从Bob（或抵押借贷智能合约）那里借ETH，则Alice将NFT转至Bob钱包，并从Bob那里获得ETH，NFT（owner: Bob's address）

3，若Alice偿还了借款，Bob收到ETH的同时，将NFT转给Alice， NFT（owner :Alice's address）

若Alice无法偿还贷款，Bob将拒绝转移该NFT给Alice，NFT（owner: Bob's address）

#### 缺点

NFT是一种具有使用价值的资产，在当前的NFT抵押借贷中，将NFT转至贷款人钱包，会使得原持有者无法使用NFT。举例，很多NFT社区存在discord社区，其中有NFT持有者频道，并对持有者具有一定的福利，比如抽奖、比如新项目白名单等。加入此频道需要验证持有者钱包持有的NFT，如果持有者进行了抵押借贷，他将无法加入该频道，也就无法享受持有者应该具有的福利。

### 721QS实现方式

1,Alice mint NFT，NFT（owner: Alice's address，guard:0）

2，Alice想抵押NFT从Bob（或抵押借贷智能合约）那里借ETH但同时又不影响自己对NFT的使用，则Alice在获得ETH借款的同时，将guard设置为Bob的地址

NFT（owner :Alice's address，guard :Bob's address）

这时，不影响Alice利用热钱包地址证明自己对NFT的持有权，并享受NFT附加的实用价值。

3，Alice如果想转移NFT，将被拒绝

4，若Alice偿还了借款，Bob收到ETH的同时，移除自己的guard角色，NFT（owner:Alice's  hot wallet address，guard:0）

若Alice无法偿还贷款，Bob通过guard将NFT转移至自己的地址。

NFT（owner :Bob's address, guard :Bob's address）

### 图示

![NFT Lending](http://assets.processon.com/chart_image/636229cee0b34d77dbc902dd.png)

传统的NFT防盗和NFT借贷，是通过NFT的转移实现的，由于NFT所有者地址发生了变化，原持有者丧失了对NFT的使用权。而721QS，增加了管理角色，guard，是通过改变NFT的状态实现NFT防盗和NFT借贷的，NFT并没有发生转移，保留了对原持有者的使用权，持有者仍然可以使用该NFT，只是无法转移NFT。

### NFT租赁示例

1，Alice mint NFT，NFT（owner :Alice's  hot wallet address，guard:0）

2，Bob想租NFT，和Alice约定租金和时间，Alice将NFT guard设置为自己的地址，owner设置为owner地址

NFT(owner :Bob's address，guard :Alice's address)

Bob可以享受NFT的实用价值，但无法转移NFT

3，租赁到期，Alice将NFT转移回自己的地址NFT（owner :Alice's address，guard :Alice's address）

### NFT分期付款示例

1，Alice mint NFT，NFT（owner :Alice's  hot wallet address，guard:0）

2，Bob想分期付款买NFT，和Alice约定分期付款金额和时间，Alice将NFT guard设置为自己的地址，owner设置为Bob地址

NFT(owner :Bob's address，guard :Alice's address)

Bob可以立即享受NFT的实用价值，但无法转移NFT

3，Bob分期付款完成，Alice取消自己的guard角色，NFT(owner :Bob's address，guard:0）

### NFT试用示例

1，Alice mint NFT，NFT（owner :Alice's  hot wallet address，guard:0）

2，Bob想购买NFT，但购买之前想试用一下，和Alice约定试用期，Alice将NFT guard设置为自己的地址，owner设置为owner地址

NFT(owner :Bob's address，guard :Alice's address)

Bob可以立即享受NFT的实用价值，但无法转移NFT

3，若Bob试用结束，想购买NFT，付完款后，Alice移除自己的guard身份，NFT（owner: Bob's address,guard:0）

# 附：721QS的基本原理

该标准定义了一个新的角色`guard`，并对`owner`和`guard`的权限进行了以下规范。

`owner`:当`guard`为空时，`owner`可以进行NFT的转移操作，也可以设置`guard`。但NFT已存在`guard`时，不经`guard`允许，`owner`无法修改`guard`，且无法对NFT进行转移操作。

`guard`: 监护人，可以设置为NFT持有者的冷钱包地址，或者是NFT持有者信任的地址。`guard`可以自行移除（remove）自己的`guard`身份，或者在NFT所在的`owner`地址出现异常后，调用合约，将 NFT转移到指定的地址。

NFT流程图
![NFT流程图](http://assets.processon.com/chart_image/62f656aa1e0853070422ac3b.png)

SBT流程图
![SBT](http://assets.processon.com/chart_image/634f6f6c07912975e8a7a187.png)


