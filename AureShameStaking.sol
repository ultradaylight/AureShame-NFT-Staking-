// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IAureShame is IERC721 {
    function name() external view returns (string memory);
}

contract AureShameStaking is Ownable, ReentrancyGuard {
    address public constant AURESHAME_NFT_ADDRESS = 0x658a0Ea978B79A156B130F36bBC6AE3b940BfA35;
    IAureShame public immutable nftContract = IAureShame(AURESHAME_NFT_ADDRESS);
    IERC20 public immutable rewardToken;

    uint256 public constant REWARD_PER_DAY = 100 * 10**18; // Adjusted for Aurelips decimals
    uint256 public constant REWARD_PER_HOUR = REWARD_PER_DAY / 24;
    uint256 public constant CLAIM_COOLDOWN = 1 hours;
    uint256 public constant MIN_STAKING_PERIOD = 24 hours;
    
    struct StakeInfo {
        uint256 tokenId;
        uint256 stakedAt;
        uint256 lastClaimed;
    }

    mapping(address => StakeInfo) public stakes;

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event Claimed(address indexed user, uint256 amount);

    constructor(address _rewardTokenAddress) {
        require(_rewardTokenAddress != address(0), "Invalid reward token address");
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function approveForStaking() external {
        require(!nftContract.isApprovedForAll(msg.sender, address(this)), "Already approved");
        nftContract.setApprovalForAll(address(this), true);
    }

    function stake(uint256 _tokenId) external nonReentrant {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(stakes[msg.sender].tokenId == 0, "Already staking");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Approval required: SetApprovalForAll missing");

        nftContract.transferFrom(msg.sender, address(this), _tokenId);
        stakes[msg.sender] = StakeInfo(_tokenId, block.timestamp, block.timestamp);

        emit Staked(msg.sender, _tokenId);
    }

    function calculateRewards(address user) public view returns (uint256) {
        StakeInfo storage stakeInfo = stakes[user];
        if (stakeInfo.tokenId == 0) return 0;

        uint256 timeElapsed = block.timestamp - stakeInfo.lastClaimed;
        uint256 hoursElapsed = timeElapsed / 1 hours;
        return hoursElapsed * REWARD_PER_HOUR;
    }

    function claimRewards() public nonReentrant {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.tokenId != 0, "No NFT staked");
        require(block.timestamp - stakeInfo.lastClaimed >= CLAIM_COOLDOWN, "Claim cooldown active");
        
        uint256 rewardAmount = calculateRewards(msg.sender);
        require(rewardAmount > 0, "No rewards yet");
        require(rewardToken.balanceOf(address(this)) >= rewardAmount, "Insufficient reward balance");

        stakeInfo.lastClaimed = block.timestamp;
        require(rewardToken.transfer(msg.sender, rewardAmount), "Transfer failed");

        emit Claimed(msg.sender, rewardAmount);
    }

    function unstake() external nonReentrant {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.tokenId != 0, "No NFT staked");
        require(nftContract.ownerOf(stakeInfo.tokenId) == address(this), "NFT not properly staked"); // Verify ownership
        require(block.timestamp - stakeInfo.stakedAt >= MIN_STAKING_PERIOD, "Must stake for at least 24 hours");

        claimRewards();
        nftContract.transferFrom(address(this), msg.sender, stakeInfo.tokenId);
        delete stakes[msg.sender];

        emit Unstaked(msg.sender, stakeInfo.tokenId);
    }

    function emergencyWithdrawNFT(uint256 _tokenId) external onlyOwner {
        require(nftContract.ownerOf(_tokenId) == address(this), "NFT not in contract");
        nftContract.transferFrom(address(this), owner(), _tokenId);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(rewardToken.transfer(owner(), amount), "Transfer failed");
    }

    // Additional security measures
    function hasHeldNFTLongEnough(address user) public view returns (bool) {
        StakeInfo storage stakeInfo = stakes[user];
        return stakeInfo.stakedAt > 0 && (block.timestamp - stakeInfo.stakedAt) >= MIN_STAKING_PERIOD;
    }
}
