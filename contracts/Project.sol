pragma solidity ^0.8.0;

/**
 * @title CommunityInsurancePool
 * @author Your Name/Project Team
 * @notice A decentralized, community-driven insurance pool where members contribute
 * funds and can file claims against losses.
 */
contract CommunityInsurancePool {
    // --- STATE VARIABLES ---
    
    // 1. Mapping to track contributions from each member
    mapping(address => uint256) public contributions;
    
    // 2. Total amount of Ether tracked within the pool
    uint256 public totalPoolBalance;

    // 3. The minimum required contribution amount (e.g., 0.1 Ether)
    uint256 public minContribution = 100000000000000000; 

    // 4. A simple structure to represent a claim
    struct Claim {
        address claimant;
        uint256 amountRequested;
        bool approved;
        bool processed;
    }

    // 5. Array to store all submitted claims
    Claim[] public claims;

    // 6. Address of the contract deployer (the 'Owner')
    address public owner;

    // --- EVENTS ---

    event ContributionReceived(address indexed member, uint256 amount);
    event ClaimSubmitted(address indexed claimant, uint256 amount, uint256 claimId);
    event ClaimProcessed(uint256 indexed claimId, bool approved, uint256 amountPaid);
    
    // [NEW] Event added for administrative transparency
    event MinContributionUpdated(uint256 oldAmount, uint256 newAmount);

    // --- MODIFIER ---

    // Restricts a function's execution to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _; // Placeholder for the function body
    }

    // --- CONSTRUCTOR ---
    
    // Runs only once when the contract is deployed
    constructor() {
        owner = msg.sender;
    }

    // --- CORE FUNCTIONS ---

    /**
     * @notice Allows a user to contribute to the insurance pool.
     */
    function contribute() public payable {
        // Enforce the minimum contribution amount
        require(msg.value >= minContribution, "Contribution must be at least minContribution.");
        
        // Update the member's personal contribution record
        contributions[msg.sender] += msg.value;
        
        // Update the total pool balance
        totalPoolBalance += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }
    
    /**
     * @notice Allows a member to submit a claim for a loss.
     * @param _amount The amount of Ether requested for the claim.
     */
    function submitClaim(uint256 _amount) public {
        require(contributions[msg.sender] > 0, "Only contributors can submit a claim.");
        require(_amount <= totalPoolBalance, "Claim amount exceeds total pool balance.");
        
        claims.push(Claim({
            claimant: msg.sender,
            amountRequested: _amount,
            approved: false,
            processed: false
        }));
        
        uint256 newClaimId = claims.length - 1;

        emit ClaimSubmitted(msg.sender, _amount, newClaimId);
    }

    /**
     * @notice The owner processes a claim, approving or rejecting it.
     * @param _claimId The ID of the claim in the claims array.
     * @param _approve Boolean indicating whether the claim is approved.
     */
    function processClaim(uint256 _claimId, bool _approve) public onlyOwner {
        require(_claimId < claims.length, "Invalid claim ID.");

        Claim storage claim = claims[_claimId];
        
        require(!claim.processed, "Claim has already been processed.");
        
        claim.approved = _approve;
        claim.processed = true;
        
        if (_approve) {
            uint256 amountToPay = claim.amountRequested;
            
            require(address(this).balance >= amountToPay, "Insufficient actual funds in the pool.");
            
            (bool success, ) = claim.claimant.call{value: amountToPay}("");
            require(success, "Ether transfer failed.");
            
            totalPoolBalance -= amountToPay;

            emit ClaimProcessed(_claimId, true, amountToPay);
        } else {
            emit ClaimProcessed(_claimId, false, 0);
        }
    }

    // [NEW] Administrative Function
    /**
     * @notice Allows the contract owner to update the minimum required contribution.
     * @param _newMinContribution The new minimum amount in Wei.
     */
    function setMinContribution(uint256 _newMinContribution) public onlyOwner {
        // Ensure the new minimum contribution is not zero
        require(_newMinContribution > 0, "Minimum contribution must be greater than zero.");

        uint256 oldMin = minContribution;
        minContribution = _newMinContribution;
        
        emit MinContributionUpdated(oldMin, minContribution);
    }
    
    /**
     * @notice A public view function to check the actual Ether balance of the contract.
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // Fallback function to accept raw Ether sends without calling a function
    receive() external payable {
        contribute();
    }
}
