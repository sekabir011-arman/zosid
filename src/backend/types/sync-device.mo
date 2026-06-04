import SyncTypes "../shared/types/sync";
import CommonTypes "../shared/types/common";

module {
  public type SyncQueueEntry  = SyncTypes.SyncQueueEntry;
  public type SyncOperation   = SyncTypes.SyncOperation;
  public type SyncStatus      = SyncTypes.SyncStatus;
  public type DeviceSyncRecord = SyncTypes.DeviceSyncRecord;
  public type ConflictMarker  = SyncTypes.ConflictMarker;
  public type DeltaQuery      = SyncTypes.DeltaQuery;
  public type FullSyncPayload = SyncTypes.FullSyncPayload;
  public type Timestamp       = CommonTypes.Timestamp;
  public type DeviceId        = CommonTypes.DeviceId;
  public type UserId          = CommonTypes.UserId;
};
