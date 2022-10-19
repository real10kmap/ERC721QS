import { expect } from 'chai';
import {
  BigNumber,
  BigNumberish,
  constants,
  ContractTransaction,
} from 'ethers';

export async function call(
  msg: string,
  action: Promise<ContractTransaction>,
  expectedSuccess = true
) {
  console.log("==================");
  let result = true;
  try {
    await (await action).wait();
    console.log("✔️ ", msg, "\n|---- 执行成功");
  } catch (e) {
    result = false;
    console.log("❌ ", msg, "\n|---- 执行失败 *", formatErrorMsg(e));
  }
  expect(result, msg).equals(expectedSuccess);
}

function formatErrorMsg(e: any) {
  const msg = e.message;
  const prefix =
    "VM Exception while processing transaction: reverted with reason string ";
  return msg.replace(prefix, "");
}

export class FormattedAsset {
  public name() {
    return "Asset";
  }

  constructor(public readonly id: BigNumberish | string) {}

  valueOf() {
    return;
  }

  public tokenId() {
    return BigNumber.from(this.id);
  }

  public toString() {
    return ` <<${this.name()}(${this.tokenId()})>> `;
  }
}

export function wait(ms) {
  return new Promise((r)=>{
    setTimeout(r,ms);
  });
}
export { constants };
