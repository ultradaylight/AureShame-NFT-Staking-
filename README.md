# AureShame NFT Staking Contract

## Overview
The **AureShame Staking Contract** allows users to stake their **AureShame NFTs** and earn **Aurelips tokens** as rewards. Users can claim rewards once per day and unstake their NFT at any time after a **24-hour minimum staking period**.

## Features
- **Stake AureShame NFTs** to earn Aurelips tokens.
- **Claim rewards once every 24 hours**.
- **Unstake at any time** after a minimum staking period.
- **Automatic approval check** to ensure staking security.
- **Security measures** to prevent exploitation.

## Smart Contract Details
- **NFT Contract**: AureShame
- **Reward Token Contract**: Aurelips
- **Blockchain**: PulseChain

## Contract Addresses
- **AureShame NFT**: `0xE0300Fb1A0ecB5C5B15c53e45de6a71ed66Af0d5`
- **Aurelips Token**: `0x9A880e35fcbb1A080762A0Fe117105Ad5715B897`
- **AureShameStaking Contract**: `0xD2d6Ef6f7409ca48DB64Ef77D1C20832d463A22d`

---

## Functions

### `stake(uint256 _tokenId)`
**Stakes an AureShame NFT** and starts earning rewards.

- **Caller**: NFT owner
- **Requirements**:
  - The user must own the NFT being staked.
  - The user cannot stake more than one NFT at a time.
  - Approval for the contract must be set.

### `calculateRewards(address user)`
**Returns the number of Aurelips tokens earned** since the last claim.

- **Caller**: Anyone
- **Returns**: `uint256` amount of claimable Aurelips tokens.

### `claimRewards()`
**Claims earned Aurelips tokens** once per day.

- **Caller**: Staker
- **Requirements**:
  - The user must have a staked NFT.
  - At least **24 hours** must have passed since the last claim.
  - The contract must have enough Aurelips tokens in balance.

### `unstake()`
**Unstakes the NFT and claims any pending rewards.**

- **Caller**: Staker
- **Requirements**:
  - The user must have an NFT staked.
  - The NFT must be staked for at least **24 hours**.

### `withdrawTokens(uint256 amount)`
**Admin-only function to withdraw unclaimed Aurelips tokens** from the contract.

- **Caller**: Owner
- **Requirements**:
  - The contract must have a sufficient Aurelips balance.

---

## Security Measures
1. **Approval Check**: Ensures the user has granted permission to stake their NFT.
2. **One NFT Per User**: Users can only stake one NFT at a time.
3. **Minimum Staking Period**: Users must stake for at least **24 hours** before unstaking.
4. **Reentrancy Protection**: Prevents exploitative attacks.
5. **Emergency Withdrawal**: Allows admin to recover NFTs in case of failure.


## Usage
### 1. Approve Contract for Staking
```solidity
approveForStaking()
```
### 2. Stake Your NFT
```solidity
stake(tokenId)
```
### 3. Claim Rewards
```solidity
claimRewards()
```
### 4. Unstake NFT
```solidity
unstake()
```

## License
This contract is licensed under **MIT License**.

---






