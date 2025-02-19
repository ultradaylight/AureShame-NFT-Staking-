# AureShame NFT Staking Contract

This smart contract allows users to stake their **AureShame NFTs** on the **PulseChain** blockchain. In return, users will earn rewards in **Aurelips (ALIPS)** tokens. The rewards are distributed on an hourly basis with a cooldown period for claiming.

## Features

- **Staking:** Stake your AureShame NFT and earn Aurelips tokens.
- **Reward Distribution:** Rewards are given every hour based on the staked NFT.
- **Cooldown Period:** A one-hour cooldown between claiming rewards.
- **Max Daily Rewards Cap:** A maximum daily reward limit to prevent abuse.
- **Unstaking:** Unstake your NFT at any time while claiming your accrued rewards.

## Table of Contents

1. [Contract Overview](#contract-overview)
2. [How to Use](#how-to-use)
   - [Staking NFTs](#staking-nfts)
   - [Claiming Rewards](#claiming-rewards)
   - [Unstaking NFTs](#unstaking-nfts)
3. [Owner Withdraw](#owner-withdraw)
4. [Security Considerations](#security-considerations)
5. [License](#license)

---

## Contract Overview

The **AureShameStaking** contract allows users to stake their **AureShame NFTs** and earn **Aurelips (AURE)** token rewards. Users must approve the contract to transfer their NFTs before staking.

### Key Variables

- **AureShame NFT Address:** 0x70a4024183E9Bb3d5d4852bcBF3afe7F46Fd5cF3
- **Reward Token:** 0x9A880e35fcbb1A080762A0Fe117105Ad5715B897
- **AureShameStaking Contract**: 0x0C4b3c4BD7090eA2B1b6724a456d18D30c05b23e
- **Reward per Hour:** 10 Aurelips tokens per hour per staked NFT.
- **Cooldown:** 1-hour cooldown for claiming rewards.
- **Max Rewards:** Max rewards capped at 1000 Aurelips tokens per day.

### Events

- **Staked:** Emitted when a user stakes an NFT.
- **Unstaked:** Emitted when a user unstakes an NFT.
- **Claimed:** Emitted when a user successfully claims rewards.
- **MaxRewardClaimed:** Emitted when the user reaches the daily reward cap.

---

## How to Use

### Staking NFTs

To stake your AureShame NFT:

1. **Approve the contract** to transfer your NFT:
   - Use the `setApprovalForAll` function on the AureShame NFT contract, approving the staking contract to transfer your NFTs.
   
2. **Stake the NFT:**
   - Call the `stake(uint256 _tokenId)` function on the staking contract.
   - The contract will transfer your NFT to the staking contract and begin accruing rewards for you.

```solidity
function stake(uint256 _tokenId) external;
```

### Claiming Rewards

To claim your earned rewards:

1. Wait for the cooldown period (1 hour) to pass since your last claim.
2. Call the `claimRewards()` function to claim your accrued Aurelips tokens.

```solidity
function claimRewards() external;
```

### Unstaking NFTs

To unstake your NFT and claim rewards:

1. Call the `unstake()` function.
2. Your NFT will be transferred back to you, and any rewards will be claimed.

```solidity
function unstake() external;
```

---

## Owner Withdraw

The contract owner can withdraw Aurelips tokens from the contract. This is done using the `withdrawTokens(uint256 amount)` function:

```solidity
function withdrawTokens(uint256 amount) external onlyOwner;
```

---

## Security Considerations

- **Reentrancy Guard:** The contract implements a reentrancy guard to protect against reentrancy attacks during the unstaking process.
- **Cooldown Mechanism:** A cooldown ensures that users cannot claim rewards too frequently, preventing abuse.
- **Max Rewards Cap:** The contract limits the maximum daily rewards a user can earn to 1000 Aurelips tokens.

Ensure that the reward token address and NFT contract address are valid before interacting with the contract to avoid errors or loss of funds.

---

## License

This contract is licensed under the MIT License. See LICENSE for more details.

---

## Acknowledgements

- **OpenZeppelin** for the contracts used for ownership management and security.
- **PulseChain** for being the blockchain platform where this contract runs.



