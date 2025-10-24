pragma solidity ^0.8.0;

contract CommunityInsurancePool {
    address payable public owner;
    uint256 public minimumContribution = 0.01 ether;
    uint256 public memberCount = 0;
    uint256 public totalPoolBalance = 0;

    struct Member {
        uint256 balance;
        bool isInsured;
        uint256 registrationTimestamp;
    }

    struct Claim {
        uint256 claimId;
        address claimant;
        uint256 amount;
        string description;
        uint256 totalVotes;
        mapping(address => bool) voted;
        bool approved;
        bool paidOut;
    }

    mapping(address => Member) public members;
    mapping(uint256 => Claim) public claims;
    uint256 public nextClaimId = 1;

    event MemberContributed(address indexed contributor, uint256 amount);
    event ClaimSubmitted(uint256 indexed claimId, address indexed claimant, uint256 amount);
    event ClaimVoted(uint256 indexed claimId, address indexed voter);
    event ClaimPaid(uint256 indexed claimId, address indexed payee, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender].balance >= minimumContribution, "Must be a contributing member.");
        _;
    }

    constructor() payable {
        owner = payable(msg.sender);
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution, "Contribution must meet the minimum requirement.");

        if (members[msg.sender].balance == 0) {
            memberCount++;
        }

        members[msg.sender].balance += msg.value;
        totalPoolBalance += msg.value;

        emit MemberContributed(msg.sender, msg.value);
    }

    function registerForCoverage() public onlyMember {
        members[msg.sender].isInsured = true;
        members[msg.sender].registrationTimestamp = block.timestamp;
    }

    function submitClaim(uint256 _amount, string memory _description) public onlyMember {
        require(members[msg.sender].isInsured, "You must be registered for coverage to submit a claim.");
        require(_amount > 0, "Claim amount must be greater than zero.");

        claims[nextClaimId].claimId = nextClaimId;
        claims[nextClaimId].claimant = msg.sender;
        claims[nextClaimId].amount = _amount;
        claims[nextClaimId].description = _description;
        claims[nextClaimId].approved = false;
        claims[nextClaimId].paidOut = false;

        emit ClaimSubmitted(nextClaimId, msg.sender, _amount);
        nextClaimId++;
    }

    function voteOnClaim(uint256 _claimId) public onlyMember {
        Claim storage claim = claims[_claimId];
        require(claim.claimId != 0, "Claim does not exist.");
        require(claim.claimant != msg.sender, "You cannot vote on your own claim.");
        require(!claim.paidOut, "Claim has already been paid out.");
        require(!claim.voted[msg.sender], "You have already voted on this claim.");

        claim.voted[msg.sender] = true;
        claim.totalVotes++;

        uint256 requiredVotes = memberCount / 2 + 1;

        if (claim.totalVotes >= requiredVotes) {
            claim.approved = true;
            payClaim(_claimId);
        }

        emit ClaimVoted(_claimId, msg.sender);
    }

    function payClaim(uint256 _claimId) private {
        Claim storage claim = claims[_claimId];
        require(claim.approved, "Claim must be approved by the community first.");
        require(!claim.paidOut, "Claim has already been paid out.");
        require(totalPoolBalance >= claim.amount, "Insufficient funds in the pool.");

        claim.paidOut = true;
        totalPoolBalance -= claim.amount;

        (bool success, ) = payable(claim.claimant).call{value: claim.amount}("");
        require(success, "Ether transfer failed.");

        emit ClaimPaid(_claimId, claim.claimant, claim.amount);
    }

    function updateMinimumContribution(uint256 _newMinimum) public onlyOwner {
        minimumContribution = _newMinimum;
    }

    function ownerWithdrawal(uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient contract balance for withdrawal.");
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Withdrawal failed.");
    }
}
    }
}


