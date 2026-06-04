import CommonTypes "common";
import Principal "mo:core/Principal";

module {

  // ─── Role Enum ────────────────────────────────────────────────────────────

  public type Role = {
    #Admin;
    #Consultant;
    #AssistantProfessor;
    #AssociateProfessor;
    #Professor;
    #MedicalOfficer;
    #AssistantRegistrar;
    #Registrar;
    #InternDoctor;
    #Nurse;
    #Reception;
    #Patient;
  };

  // ─── Approval Status ──────────────────────────────────────────────────────

  public type ApprovalStatus = {
    #Pending;
    #Active;
    #Suspended;
  };

  // ─── User ─────────────────────────────────────────────────────────────────

  public type User = {
    id           : CommonTypes.UserId;
    email        : Text;
    passwordHash : Text;
    role         : Role;
    name         : Text;
    phone        : Text;
    profilePhoto : ?Text;
    status       : ApprovalStatus;
    approvedBy   : ?CommonTypes.UserId;
    approvedAt   : ?CommonTypes.Timestamp;
    createdAt    : CommonTypes.Timestamp;
    lastLoginAt  : ?CommonTypes.Timestamp;
    patientId    : ?CommonTypes.PatientId;  // linked patient record if role = #Patient
  };

  // ─── Staff Profile ────────────────────────────────────────────────────────

  public type Shift = { #Morning; #Evening; #Night };

  public type StaffProfile = {
    userId       : CommonTypes.UserId;
    employeeId   : Text;
    department   : Text;
    shift        : Shift;
    ward         : ?Text;
    joiningDate  : CommonTypes.Timestamp;
  };

  // ─── Shift Schedule ───────────────────────────────────────────────────────

  public type ShiftScheduleStatus = {
    #Scheduled;
    #OnDuty;
    #Completed;
    #Absent;
  };

  public type ShiftSchedule = {
    id       : Text;
    userId   : CommonTypes.UserId;
    date     : CommonTypes.Timestamp;
    shift    : Shift;
    ward     : Text;
    status   : ShiftScheduleStatus;
  };

  // ─── Leave Request ────────────────────────────────────────────────────────

  public type LeaveStatus = {
    #Pending;
    #Approved;
    #Rejected;
  };

  public type LeaveRequest = {
    id          : Text;
    userId      : CommonTypes.UserId;
    fromDate    : CommonTypes.Timestamp;
    toDate      : CommonTypes.Timestamp;
    reason      : Text;
    status      : LeaveStatus;
    reviewedBy  : ?CommonTypes.UserId;
    reviewedAt  : ?CommonTypes.Timestamp;
    createdAt   : CommonTypes.Timestamp;
  };

  // ─── Session ──────────────────────────────────────────────────────────────

  public type Session = {
    userId    : CommonTypes.UserId;
    principal : Principal;
    createdAt : CommonTypes.Timestamp;
    expiresAt : CommonTypes.Timestamp;
    deviceId  : CommonTypes.DeviceId;
  };

};
