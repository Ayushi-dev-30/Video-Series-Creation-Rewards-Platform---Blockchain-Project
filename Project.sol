// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VideoSeriesRewards {
    struct VideoSeries {
        string title;
        string description;
        address creator;
        uint256 rewardBalance;
    }

    mapping(uint256 => VideoSeries) public videoSeriesRegistry;
    uint256 public videoSeriesCount;

    event VideoSeriesRegistered(uint256 seriesId, address creator, string title);
    event RewardDeposited(uint256 seriesId, address sender, uint256 amount);
    event RewardClaimed(uint256 seriesId, address creator, uint256 amount);

    function registerVideoSeries(string memory _title, string memory _description) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        videoSeriesRegistry[videoSeriesCount] = VideoSeries({
            title: _title,
            description: _description,
            creator: msg.sender,
            rewardBalance: 0
        });

        emit VideoSeriesRegistered(videoSeriesCount, msg.sender, _title);
        videoSeriesCount++;
    }

    function depositReward(uint256 _seriesId) public payable {
        require(_seriesId < videoSeriesCount, "Invalid series ID");
        require(msg.value > 0, "Reward must be greater than zero");

        videoSeriesRegistry[_seriesId].rewardBalance += msg.value;
        emit RewardDeposited(_seriesId, msg.sender, msg.value);
    }

    function claimReward(uint256 _seriesId) public {
        require(_seriesId < videoSeriesCount, "Invalid series ID");
        VideoSeries storage series = videoSeriesRegistry[_seriesId];
        require(msg.sender == series.creator, "Only the creator can claim rewards");
        require(series.rewardBalance > 0, "No rewards to claim");

        uint256 rewardAmount = series.rewardBalance;
        series.rewardBalance = 0;

        payable(series.creator).transfer(rewardAmount);
        emit RewardClaimed(_seriesId, series.creator, rewardAmount);
    }
}
