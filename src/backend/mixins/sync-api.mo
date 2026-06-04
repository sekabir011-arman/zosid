import T "../types/sync-device";
import SyncLib "../lib/sync";
import Time "mo:core/Time";

// Exposes the public API of the sync-device domain.
mixin (state : SyncLib.SyncState) {

  // ─── Queue ────────────────────────────────────────────────────────────────

  public shared ({ caller }) func enqueueSync(entry : T.SyncQueueEntry) : async () {
    ignore caller;
    SyncLib.enqueue(state, entry)
  };

  public shared ({ caller }) func markSynced(entryId : Text) : async () {
    ignore caller;
    SyncLib.markSynced(state, entryId)
  };

  public shared ({ caller }) func markFailed(entryId : Text) : async () {
    ignore caller;
    SyncLib.markFailed(state, entryId)
  };

  public query ({ caller }) func getPendingByDevice(deviceId : T.DeviceId) : async [T.SyncQueueEntry] {
    ignore caller;
    SyncLib.getPendingByDevice(state, deviceId)
  };

  public query func getQueueSince(since : T.Timestamp) : async [T.SyncQueueEntry] {
    SyncLib.getQueueSince(state, since)
  };

  // ─── Device Tracking ──────────────────────────────────────────────────────

  public shared ({ caller }) func recordDeviceSync(
      deviceId  : T.DeviceId,
      dataTypes : [Text]
  ) : async () {
    ignore caller;
    let record : T.DeviceSyncRecord = {
      deviceId;
      dataTypes;
      lastSyncTime = Time.now();
      syncCount    = 0; // upserted by lib
    };
    SyncLib.recordDeviceSync(state, record)
  };

  public query func getLastSyncTime(deviceId : T.DeviceId) : async ?T.Timestamp {
    SyncLib.getLastSyncTime(state, deviceId)
  };

  public query func getAllDeviceSyncs() : async [T.DeviceSyncRecord] {
    SyncLib.getAllDeviceSyncs(state)
  };

  // ─── Conflict Resolution ──────────────────────────────────────────────────

  public query func getConflicts() : async [T.ConflictMarker] {
    SyncLib.getConflicts(state)
  };

  public shared ({ caller }) func resolveConflict(
      entityId   : Text,
      resolution : Text
  ) : async () {
    ignore caller;
    SyncLib.resolveConflict(state, entityId, resolution)
  };

  // ─── Incremental Delta ────────────────────────────────────────────────────

  public query func deltaQuery(
      dataType : Text,
      since    : T.Timestamp,
      deviceId : T.DeviceId
  ) : async [T.SyncQueueEntry] {
    SyncLib.deltaQueryByType(state, dataType, since, deviceId)
  };

};
