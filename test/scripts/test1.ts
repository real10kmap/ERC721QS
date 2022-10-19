import 'mocha';

import { expect } from 'chai';
import { constants } from 'ethers';
import { ethers } from 'hardhat';

import { TestERC721QSNFT__factory } from '../../../typechain-types';
import {
  call,
  FormattedAsset,
} from '../../../utils/common';

class MyNft extends FormattedAsset {
  public name(): string {
    return "NFT";
  }
}

describe("testERC721QS", () => {
  it("deploy", async () => {
    const arr = await ethers.getSigners();
    const [owner, user, guard, hacker, market, buyer] = arr;
    [{ owner }, { user }, { guard }, { hacker }, { market }, { buyer }].forEach(
      (item: any) => {
        for (var key in item) {
          console.log(`address ${key} <--> ${item[key].address}`);
        }
      }
    );
    const TestContract: TestERC721QSNFT__factory =
      await ethers.getContractFactory("TestERC721QSNFT");

    let contractIns = await TestContract.deploy();
    await contractIns.deployed();
    console.log("Deployment complete", contractIns.address);

    console.log("totalSupply = ", await contractIns.totalSupply());
    contractIns = contractIns.connect(owner);
    await (await contractIns.setPause(false)).wait();

    // connect to user wallet
    contractIns = contractIns.connect(user);
    // mint
    await call("mint 5 个NFT", contractIns.connect(user).mint(5));
    // check balance
    expect(
      await (await contractIns.balanceOf(user.address)).toNumber(),
      "after mint, user's balance increase"
    ).to.equals(5);

    // mint 3 nft:nft0,nft1,nft2
    const tokenIds = await (
      await contractIns.walletOfOwner(user.address)
    ).map((x) => x.toNumber());

    const [nft0, nft1, nft2, nft3, nft4] = tokenIds.map((id) => new MyNft(id));

    await call(
      `Default not set guard,Click on the phishing website${nft0} approve`,
      contractIns.approve(hacker.address, nft0.id)
    );

    await call(
        `Default not set guard,Click on the phishing website${nft1} approve`,
      contractIns.approve(hacker.address, nft1.id)
    );

    await call(
        `Default not set guard,Click on the phishing website${nft3} approve`,
      contractIns.approve(hacker.address, nft3.id)
    );

    await call(
      `The default guard is not set. Click the phishing website to approve all nfts`,
      contractIns.setApprovalForAll(hacker.address, true)
    );

    console.log("Hacker transferred to his own account");
    await call(
      `Hacker ${nft0} transfer`,
      contractIns
        .connect(hacker)
        .transferFrom(user.address, hacker.address, nft0.id)
    );

    // Check owner
    expect(await contractIns.ownerOf(nft0.id), "Check owner ").to.equals(
      hacker.address
    );

    // User set guard
    console.log("User set guard", nft1.toString(), "-->", guard.address);
    await call(
      `User set ${nft1} guard`,
      contractIns.connect(user).changeGuardianForToken(nft1.id, guard.address)
    );
    expect(await contractIns.guardianOf(nft1.id), "guardian of nft").equals(
      guard.address
    );
    // The hacker steals the user's private key and tries to transfer it
    console.log("The hacker steals the user's private key and tries to transfer it");
    await call(
      `Hacker transfer ${nft1}`,
      contractIns
        .connect(user)
        .transferFrom(user.address, hacker.address, nft1.id),
      false
    );
    // Hackers attempt to approve pending sales
    await call(
      `Hacker calls approve authorization ${nft1}`,
      contractIns.connect(user).approve(market.address, nft1.id),
      false
    );
    await call(
      "The hacker calls setApproveForAll to the market",
      contractIns.connect(user).setApprovalForAll(market.address, true),
      true
    );
    await call(
      "Hacker calls setApproveForAll to hacker",
      contractIns.connect(user).setApprovalForAll(hacker.address, true),
      true
    );
    // Check whether authorization is successful
    expect(
      await contractIns.isApprovedForAll(user.address, market.address)
    ).to.equals(true);
    expect(
      await contractIns.isApprovedForAll(user.address, hacker.address)
    ).to.equals(true);
    await call(
      `Exchange initiated trading pairs${nft1}`,
      contractIns
        .connect(market)
        .transferFrom(user.address, buyer.address, nft1.id),
      false
    );
    await call(
      `Guard initiates a transaction and transfers ${nft1} to his account`,
      contractIns
        .connect(guard)
        .transferFrom(owner.address, guard.address, nft1.id),
      true
    );
    expect(await contractIns.ownerOf(nft1.id)).equals(guard.address);
    expect(await contractIns.guardianOf(nft1.id)).equals(constants.AddressZero);


    await call(
      `The hacker initiated the transaction, because setApproveForAll was authorized before, and transferred ${nft4} to his own account`,
      contractIns
        .connect(hacker)
        .transferFrom(user.address, hacker.address, nft4.id),
      false
    );

    await call(
      `The hacker holds the user's private key to initiate transactions. Because setApproveForAll has been authorized before, the hacker transfers ${nft4} to his own account`,
      contractIns
        .connect(hacker)
        .transferFrom(user.address, hacker.address, nft4.id),
      false
    );

    await call(
      `The hacker holds the user's private key to initiate a transaction and transfers ${nft4} to his own account`,
      contractIns
        .connect(user)
        .transferFrom(user.address, hacker.address, nft4.id),
      false
    );

    await call(
      `Guard initiates a transaction and transfers ${nft4} to his account`,
      contractIns
        .connect(guard)
        .transferFrom(user.address, guard.address, nft4.id),
      true
    );

    expect(await contractIns.ownerOf(nft4.id), `Check the owner of ${nft4}`).equals(
      guard.address
    );

    await call(
      `The user cancels the setApprovalForAll authorization of the hacker`,
      contractIns.connect(user).setApprovalForAll(hacker.address, false),
      true
    );

    await call(
      `Hacker attempts to authorize setApprovalForAll of hacker`,
      contractIns.connect(user).setApprovalForAll(hacker.address, true),
      false
    );

    await call(
      `Guard transfers the asset ${nft4} back to ward`,
      contractIns
        .connect(guard)
        .transferFrom(guard.address, user.address, nft4.id),
      true
    );

    await call(
      `The hacker tried to transfer out the asset ${nft4}`,
      contractIns
        .connect(user)
        .transferFrom(user.address, hacker.address, nft4.id),
      false
    );

    await call(
      `The hacker (user's private key) removes the guard identity`,
      contractIns.connect(user).removeGuardianForToken(nft4.id),
      false
    );

    await call(
      `Remove the identity of guard`,
      contractIns.connect(guard).removeGuardianForToken(nft4.id),
      true
    );
    
  });
});
