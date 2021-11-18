pragma solidity 0.8.5;

import "./SafeMath.sol";

contract TreasuryVester {
    using SafeMath for uint256;

    address public immutable gtc;
    address public recipient;

    uint256 public immutable vestingAmount;
    uint256 public immutable vestingBegin;
    uint256 public immutable vestingCliff;
    uint256 public immutable vestingEnd;

    uint256 public lastUpdate;

    constructor(
        address gtc_,
        address recipient_,
        uint256 vestingAmount_,
        uint256 vestingBegin_,
        uint256 vestingCliff_,
        uint256 vestingEnd_
    ) public {
        require(
            vestingBegin_ >= block.timestamp,
            "TreasuryVester::constructor: vesting begin too early"
        );
        require(
            vestingCliff_ >= vestingBegin_,
            "TreasuryVester::constructor: cliff is too early"
        );
        require(
            vestingEnd_ > vestingCliff_,
            "TreasuryVester::constructor: end is too early"
        );

        gtc = gtc_;
        recipient = recipient_;

        vestingAmount = vestingAmount_;
        vestingBegin = vestingBegin_;
        vestingCliff = vestingCliff_;
        vestingEnd = vestingEnd_;

        lastUpdate = vestingBegin_;
    }

    function setRecipient(address recipient_) public {
        require(
            msg.sender == recipient,
            "TreasuryVester::setRecipient: unauthorized"
        );
        recipient = recipient_;
    }

    function claim() public {
        require(
            block.timestamp >= vestingCliff,
            "TreasuryVester::claim: not time yet"
        );
        uint256 amount;
        if (block.timestamp >= vestingEnd) {
            amount = IGtc(gtc).balanceOf(address(this));
        } else {
            amount = vestingAmount.mul(block.timestamp - lastUpdate).div(
                vestingEnd - vestingBegin
            );
            lastUpdate = block.timestamp;
        }
        IGtc(gtc).transfer(recipient, amount);
    }
}

interface IGtc {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address dst, uint256 rawAmount) external returns (bool);
}
