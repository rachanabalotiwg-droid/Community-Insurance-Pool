// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Community Insurance Pool
/// @notice A decentralized community-driven insurance fund where members contribute and claim.
contract Project {
    address public admin;
    uint256 public totalPoolBalance;
    uint256 public nextClaimId;

    struct Member {
        bool isMember;
        uint256 contribution;
    }

    struct Claim {
        uint256 id;
        address claimant;
        uint256 amount;
        string reason;
        bool approved;
        bool settled;
    }

    mapping(address => Member) public members;
    mapping(uint256 => Claim) public claims;

    event MemberJoined(address indexed member, uint256 amount);
    event ContributionAdded(address indexed member, uint256 amount);
    event ClaimSubmitted(uint256 indexed id, address indexed claimant, uint256 amount, string reason);
    event ClaimApproved(uint256 indexed id, address indexed claimant, uint256 amount);
    event ClaimRejected(uint256 indexed id, address indexed claimant);
    event ClaimSettled(uint256 indexed id, address indexed claimant, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender].isMember, "Only members can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
        nextClaimId = 1;
    }

    /// @notice Join the insurance pool by contributing Ether
    function joinPool() external payable {
        require(msg.value > 0, "Must send Ether to join");
        require(!members[msg.sender].isMember, "Already a member");

        members[msg.sender] = Member({isMember: true, contribution: msg.value});
        totalPoolBalance += msg.value;

        emit MemberJoined(msg.sender, msg.value);
    }

    /// @notice Add more contributions to the pool
    function addContribution() external payable onlyMember {
        require(msg.value > 0, "Contribution must be > 0");
        members[msg.sender].contribution += msg.value;
        totalPoolBalance += msg.value;

        emit ContributionAdded(msg.sender, msg.value);
    }

    /// @notice Submit an insurance claim
    /// @param amount Amount requested from the pool
    /// @param reason Description of the loss event
    function submitClaim(uint256 amount, string calldata reason) external onlyMember {
        require(amount > 0, "Invalid claim amount");
        require(amount <= totalPoolBalance, "Requested amount exceeds pool");

        uint256 claimId = nextClaimId++;
        claims[claimId] = Claim({
            id: claimId,
            claimant: msg.sender,
            amount: amount,
            reason: reason,
            approved: false,
            settled: false
        });

        emit ClaimSubmitted(claimId, msg.sender, amount, reason);
    }

    /// @notice Admin approves a submitted claim
    function approveClaim(uint256 claimId) external onlyAdmin {
        Claim storage c = claims[claimId];
        require(!c.approved && !c.settled, "Claim already handled");
        c.approved = true;

        emit ClaimApproved(claimId, c.claimant, c.amount);
    }

    /// @notice Admin rejects a submitted claim
    function rejectClaim(uint256 claimId) external onlyAdmin {
        Claim storage c = claims[claimId];
        require(!c.approved && !c.settled, "Claim already handled");

        c.settled = true;
        emit ClaimRejected(claimId, c.claimant);
    }

    /// @notice Admin settles an approved claim by paying claimant
    function settleClaim(uint256 claimId) external onlyAdmin {
        Claim storage c = claims[claimId];
        require(c.approved, "Claim not approved");
        require(!c.settled, "Already settled");
        require(totalPoolBalance >= c.amount, "Insufficient pool balance");

        c.settled = true;
        totalPoolBalance -= c.amount;

        payable(c.claimant).transfer(c.amount);
        emit ClaimSettled(claimId, c.claimant, c.amount);
    }

    /// @notice Get member details
    function getMember(address member) external view returns (bool, uint256) {
        Member storage m = members[member];
        return (m.isMember, m.contribution);
    }
}




