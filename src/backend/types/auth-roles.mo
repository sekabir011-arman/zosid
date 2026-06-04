import AuthTypes "../shared/types/auth";
import CommonTypes "../shared/types/common";

module {
  // Re-export for canister-local convenience
  public type Role          = AuthTypes.Role;
  public type ApprovalStatus = AuthTypes.ApprovalStatus;
  public type User          = AuthTypes.User;
  public type StaffProfile  = AuthTypes.StaffProfile;
  public type Shift         = AuthTypes.Shift;
  public type ShiftSchedule = AuthTypes.ShiftSchedule;
  public type ShiftScheduleStatus = AuthTypes.ShiftScheduleStatus;
  public type LeaveRequest  = AuthTypes.LeaveRequest;
  public type LeaveStatus   = AuthTypes.LeaveStatus;
  public type Session       = AuthTypes.Session;
  public type UserId        = CommonTypes.UserId;
  public type Timestamp     = CommonTypes.Timestamp;
  public type DeviceId      = CommonTypes.DeviceId;
};
