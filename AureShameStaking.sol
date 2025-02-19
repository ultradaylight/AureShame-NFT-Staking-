// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IAureShame is IERC721 {
    function name() external view returns (string memory);
}

contract AureShameStaking is Ownable, ReentrancyGuard {
    address public constant AURESHAME_NFT_ADDRESS = 0x70a4024183E9Bb3d5d4852bcBF3afe7F46Fd5cF3;
    IAureShame public immutable nftContract = IAureShame(AURESHAME_NFT_ADDRESS);
    IERC20 public immutable rewardToken;

    uint256 public constant REWARD_PER_DAY = 10 * 10**18; // Adjusted for Aurelips decimals
    uint256 public constant REWARD_PER_HOUR = REWARD_PER_DAY / 24;
    uint256 public constant CLAIM_COOLDOWN = 1 hours;  // 1 hour cooldown
    uint256 public constant MAX_REWARDS_PER_DAY = 1000 * 10**18;  // Max rewards per day

    struct StakeInfo {
        uint256 tokenId;
        uint256 stakedAt;
        uint256 lastClaimed;
    }

    mapping(address => StakeInfo) public stakes;

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event Claimed(address indexed user, uint256 amount);
    event MaxRewardClaimed(address indexed user, uint256 amount);

    // Constructor now passes the msg.sender to Ownable's constructor
    constructor(address _rewardTokenAddress) Ownable(0xCD11789CEf81Be2BCe676A34CC9331f8cE557116) {
        require(_rewardTokenAddress != address(0), "Invalid reward token address");
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function stake(uint256 _tokenId) external {
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
        
        uint256 totalRewards = hoursElapsed * REWARD_PER_HOUR;
        if (totalRewards > MAX_REWARDS_PER_DAY) {
            totalRewards = MAX_REWARDS_PER_DAY;  // Limit rewards to max per day
        }
        return totalRewards;
    }

    function claimRewards() public {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.tokenId != 0, "No NFT staked");
        require(block.timestamp - stakeInfo.lastClaimed >= CLAIM_COOLDOWN, "Claim cooldown active");
        
        uint256 rewardAmount = calculateRewards(msg.sender);
        require(rewardAmount > 0, "No rewards yet");
        require(rewardToken.balanceOf(address(this)) >= rewardAmount, "Insufficient reward balance");

        // Cap rewards if they exceed max allowed per day
        if (rewardAmount > MAX_REWARDS_PER_DAY) {
            emit MaxRewardClaimed(msg.sender, rewardAmount);
            rewardAmount = MAX_REWARDS_PER_DAY;  // Cap reward
        }

        stakeInfo.lastClaimed = block.timestamp;
        require(rewardToken.transfer(msg.sender, rewardAmount), "Transfer failed");

        emit Claimed(msg.sender, rewardAmount);
    }

    function unstake() external {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.tokenId != 0, "No NFT staked");
        require(nftContract.ownerOf(stakeInfo.tokenId) == address(this), "NFT not properly staked"); // Verify ownership

        // Transfer NFT first to prevent reentrancy risks
        nftContract.transferFrom(address(this), msg.sender, stakeInfo.tokenId);

        // Claim rewards AFTER NFT transfer to prevent reentrancy
        claimRewards();

        // Remove stake info after all operations
        delete stakes[msg.sender];

        emit Unstaked(msg.sender, stakeInfo.tokenId);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(rewardToken.transfer(owner(), amount), "Transfer failed");
    }
}
