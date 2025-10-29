// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Agricultural Traceability - Project.sol
/// @notice Simple traceability registry for agricultural batches
contract Project {
    uint256 private nextId;

    struct Trace {
        uint256 id;
        string batchId;       // external batch identifier
        string farmer;        // farmer name or identifier
        string location;      // origin location
        uint256 timestamp;    // when recorded
        string details;       // extra details (crop type, weight, etc.)
        string status;        // e.g., "harvested", "shipped", "processed"
        address recorder;     // who recorded this entry
    }

    // id => Trace
    mapping(uint256 => Trace) private traces;
    // batchId => latest trace id (optional quick lookup for latest)
    mapping(string => uint256) private latestByBatch;

    event TraceRecorded(uint256 indexed id, string batchId, address recorder);
    event TraceUpdated(uint256 indexed id, string newStatus, address updater);

    constructor() {
        nextId = 1;
    }

    /// @notice Record a new trace entry for a batch
    /// @param batchId external identifier for the batch
    /// @param farmer farmer name or id
    /// @param location origin location
    /// @param details extra details like crop, weight, notes
    /// @param status initial status
    /// @return id internal numeric id for the trace
    function recordTrace(
        string calldata batchId,
        string calldata farmer,
        string calldata location,
        string calldata details,
        string calldata status
    ) external returns (uint256) {
        uint256 id = nextId++;
        traces[id] = Trace({
            id: id,
            batchId: batchId,
            farmer: farmer,
            location: location,
            timestamp: block.timestamp,
            details: details,
            status: status,
            recorder: msg.sender
        });
        latestByBatch[batchId] = id;
        emit TraceRecorded(id, batchId, msg.sender);
        return id;
    }

    /// @notice Update status and details of an existing trace entry
    /// @param id internal numeric id returned when created
    /// @param newStatus new status string
    /// @param newDetails optional updated details
    function updateTrace(uint256 id, string calldata newStatus, string calldata newDetails) external {
        require(id > 0 && id < nextId, "Trace: invalid id");
        Trace storage t = traces[id];
        // allow anyone to update in this simple example — production should restrict
        t.status = newStatus;
        t.details = newDetails;
        emit TraceUpdated(id, newStatus, msg.sender);
    }

    /// @notice Retrieve a trace by its internal id
    /// @param id internal numeric id
    /// @return Trace struct fields
    function getTrace(uint256 id) public view returns (
        uint256,
        string memory,
        string memory,
        string memory,
        uint256,
        string memory,
        string memory,
        address
    ) {
        require(id > 0 && id < nextId, "Trace: invalid id");
        Trace storage t = traces[id];
        return (
            t.id,
            t.batchId,
            t.farmer,
            t.location,
            t.timestamp,
            t.details,
            t.status,
            t.recorder
        );
    }

    /// @notice Get the latest trace id for a given batchId (0 if none)
    function getLatestByBatch(string calldata batchId) external view returns (uint256) {
        return latestByBatch[batchId];
    }
}

}



