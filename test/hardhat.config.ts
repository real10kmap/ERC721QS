import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-waffle';

import { HardhatUserConfig } from 'hardhat/config';

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "hardhat",
  paths: {
    sources: "./ERC721QS/",
  },
};

export default config;
