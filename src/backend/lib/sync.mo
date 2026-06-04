import List "mo:core/List";
import Map "mo:core/Map";
import Time "mo:core/Time";
import T "../types/sync-device";

module {

  let maxRetries : Nat = 10;

  public type SyncState = {
    queue          : List.List<T.SyncQueueEntry>;
    deviceRecords  : Map.Map<T.DeviceId, T.DeviceSyncRecord>;
    conflictLog    : List.List<T.ConflictMarker>;
  };

  public func emptyState() : SyncState {
    {
      queue         = List.empty<T.SyncQueueEntry>();
      deviceRecords = Map.empty<T.DeviceId, T.DeviceSyncRecord>();
      conflictLog   = List.empty<T.ConflictMarker>();
    }
  };

  // ─── Queue Operations ─────────────────────────────────────────────────────

  public func enqueue(state : SyncState, entry : T.SyncQueueEntry) : () {
    // Ensure status is Pending on enqueue
    let e = { entry with status = #Pending };
    state.queue.add(e)
  };

  public func markSynced(state : SyncState, entryId : Text) : () {
    state.queue.mapInPlace(func(e : T.SyncQueueEntry) : T.SyncQueueEntry {
      if (e.id == entryId) {
        { e with status = #Synced; syncedAt = ?Time.now() }
      } else { e }
    })
  };

  public func markFailed(state : SyncState, entryId : Text) : () {
    state.queue.mapInPlace(func(e : T.SyncQueueEntry) : T.SyncQueueEntry {
      if (e.id == entryId) {
        let newRetry = e.retryCount + 1;
        let newStatus : T.SyncStatus = if (newRetry >= maxRetries) #Failed else #Pending;
        { e with retryCount = newRetry; status = newStatus }
      } else { e }
    })
  };

  public func getPendingByDevice(state : SyncState, deviceId : T.DeviceId) : [T.SyncQueueEntry] {
    state.queue.toArray().filter(
      func(e : T.SyncQueueEntry) { e.deviceId == deviceId and e.status == #Pending }
    )
  };

  public func getQueueSince(state : SyncState, since : T.Timestamp) : [T.SyncQueueEntry] {
    state.queue.toArray().filter(func(e : T.SyncQueueEntry) { e.createdAt >= since })
  };

  // ─── Device Tracking ──────────────────────────────────────────────────────

  public func recordDeviceSync(state : SyncState, record : T.DeviceSyncRecord) : () {
    // Upsert by deviceId: if exists, bump syncCount and update time
    switch (state.deviceRecords.get(record.deviceId)) {
      case (?existing) {
        let updated = {
          record with
          syncCount = existing.syncCount + 1;
          lastSyncTime = Time.now();
        };
        state.deviceRecords.add(record.deviceId, updated)
      };
      case null {
        let fresh = { record with syncCount = 1; lastSyncTime = Time.now() };
        state.deviceRecords.add(record.deviceId, fresh)
      };
    }
  };

  public func getLastSyncTime(state : SyncState, deviceId : T.DeviceId) : ?T.Timestamp {
    switch (state.deviceRecords.get(deviceId)) {
      case (?r) { ?r.lastSyncTime };
      case null { null };
    }
  };

  public func getAllDeviceSyncs(state : SyncState) : [T.DeviceSyncRecord] {
    state.deviceRecords.values().toArray()
  };

  // ─── Conflict Resolution ──────────────────────────────────────────────────

  public func logConflict(state : SyncState, marker : T.ConflictMarker) : () {
    state.conflictLog.add(marker)
  };

  public func resolveConflict(state : SyncState, entityId : Text, resolution : Text) : () {
    state.conflictLog.mapInPlace(func(m : T.ConflictMarker) : T.ConflictMarker {
      if (m.entityId == entityId and m.resolvedAt == null) {
        { m with resolvedAt = ?Time.now(); resolution = ?resolution }
      } else { m }
    })
  };

  public func getConflicts(state : SyncState) : [T.ConflictMarker] {
    state.conflictLog.toArray()
  };

  // ─── Incremental Delta Queries ────────────────────────────────────────────

  public func deltaQueryByType(
      state    : SyncState,
      dataType : Text,
      since    : T.Timestamp,
      deviceId : T.DeviceId
  ) : [T.SyncQueueEntry] {
    state.queue.toArray().filter(
      func(e : T.SyncQueueEntry) {
        e.dataType == dataType and e.createdAt >= since and e.deviceId != deviceId
      }
    )
  };

};
