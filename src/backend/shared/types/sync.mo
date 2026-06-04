import CommonTypes "common";

module {

  // ─── Sync Operation ───────────────────────────────────────────────────────

  public type SyncOperation = { #Create; #Update; #Delete };

  public type SyncStatus = {
    #Pending;
    #Synced;
    #Failed;
    #Conflict;
  };

  // ─── Sync Queue Entry ─────────────────────────────────────────────────────

  public type SyncQueueEntry = {
    id          : Text;
    dataType    : Text;   // "patient" | "vitals" | "prescription" | "bed" | "appointment" | ...
    entityId    : Text;
    operation   : SyncOperation;
    payload     : Text;   // JSON-serialised payload
    status      : SyncStatus;
    retryCount  : Nat;
    createdAt   : CommonTypes.Timestamp;
    syncedAt    : ?CommonTypes.Timestamp;
    deviceId    : CommonTypes.DeviceId;
    userId      : CommonTypes.UserId;
  };

  // ─── Device Sync Record ───────────────────────────────────────────────────

  public type DeviceSyncRecord = {
    deviceId      : CommonTypes.DeviceId;
    userId        : CommonTypes.UserId;
    lastSyncTime  : CommonTypes.Timestamp;
    syncCount     : Nat;
    dataTypes     : [Text];
  };

  // ─── Conflict Marker ──────────────────────────────────────────────────────

  public type ConflictMarker = {
    entityId      : Text;
    dataType      : Text;
    localVersion  : Nat;
    remoteVersion : Nat;
    detectedAt    : CommonTypes.Timestamp;
    resolvedAt    : ?CommonTypes.Timestamp;
    resolution    : ?Text;  // "local_wins" | "remote_wins" | "manual"
  };

  // ─── Delta Query ──────────────────────────────────────────────────────────

  public type DeltaQuery = {
    dataType  : Text;
    since     : CommonTypes.Timestamp;
    deviceId  : CommonTypes.DeviceId;
  };

  // ─── Full Sync Payload ────────────────────────────────────────────────────

  public type FullSyncPayload = {
    patients       : Text;  // JSON array
    vitals         : Text;
    prescriptions  : Text;
    beds           : Text;
    admissions     : Text;
    appointments   : Text;
    queue          : Text;
    alerts         : Text;
    syncedAt       : CommonTypes.Timestamp;
  };

};
