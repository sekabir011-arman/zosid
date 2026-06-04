import Time "mo:core/Time";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import T "../types/auth-roles";
import AuthLib "../lib/auth";

// Exposes the public API of the auth-roles domain.
mixin (state : AuthLib.AuthState) {

  // ─── User Management ─────────────────────────────────────────────────────

  public shared ({ caller }) func createUser(
      email        : Text,
      passwordHash : Text,
      role         : T.Role,
      name         : Text,
      phone        : Text
  ) : async T.User {
    ignore caller;
    AuthLib.createUser(state, email, passwordHash, role, name, phone)
  };

  public query func getUser(id : T.UserId) : async ?T.User {
    AuthLib.getUser(state, id)
  };

  public query func getUserByEmail(email : Text) : async ?T.User {
    AuthLib.getUserByEmail(state, email)
  };

  public shared ({ caller }) func updateUser(user : T.User) : async T.User {
    ignore caller;
    AuthLib.updateUser(state, user)
  };

  public query func listUsers() : async [T.User] {
    AuthLib.listUsers(state)
  };

  public shared ({ caller }) func approveUser(userId : T.UserId) : async T.User {
    // Caller must be an authenticated user; look up their UserId via session
    let session = switch (AuthLib.getSession(state, caller)) {
      case (?s) { s };
      case null { Runtime.trap("Not authenticated") };
    };
    AuthLib.approveUser(state, userId, session.userId)
  };

  public shared ({ caller }) func suspendUser(userId : T.UserId) : async T.User {
    ignore caller;
    AuthLib.suspendUser(state, userId)
  };

  public shared ({ caller }) func assignRole(userId : T.UserId, role : T.Role) : async T.User {
    ignore caller;
    let user = switch (AuthLib.getUser(state, userId)) {
      case (?u) { u };
      case null { Runtime.trap("User not found") };
    };
    AuthLib.updateUser(state, { user with role })
  };

  // Login / session
  public shared ({ caller }) func login(
      email        : Text,
      passwordHash : Text,
      deviceId     : T.DeviceId
  ) : async ?T.User {
    switch (AuthLib.verifyPassword(state, email, passwordHash)) {
      case null { null };
      case (?user) {
        let session : T.Session = {
          userId    = user.id;
          principal = caller;
          createdAt = Time.now();
          expiresAt = Time.now() + 30 * 24 * 60 * 60 * 1_000_000_000; // 30 days
          deviceId;
        };
        AuthLib.createSession(state, session);
        // Update lastLoginAt
        let updated = { user with lastLoginAt = ?Time.now() };
        AuthLib.updateUser(state, updated);
        ?updated
      };
    }
  };

  public shared ({ caller }) func logout() : async Bool {
    AuthLib.removeSession(state, caller);
    true
  };

  public query ({ caller }) func getCallerUser() : async ?T.User {
    switch (AuthLib.getSession(state, caller)) {
      case null { null };
      case (?session) { AuthLib.getUser(state, session.userId) };
    }
  };

  // Email uniqueness check (for registration validation)
  public query func isEmailRegistered(email : Text) : async Bool {
    not AuthLib.isEmailUnique(state, email, null)
  };

  // ─── Staff Profiles ───────────────────────────────────────────────────────

  public shared ({ caller }) func upsertStaffProfile(profile : T.StaffProfile) : async () {
    ignore caller;
    AuthLib.upsertStaffProfile(state, profile)
  };

  public query func getStaffProfile(userId : T.UserId) : async ?T.StaffProfile {
    AuthLib.getStaffProfile(state, userId)
  };

  // ─── Shift Schedules ──────────────────────────────────────────────────────

  public shared ({ caller }) func createShiftSchedule(schedule : T.ShiftSchedule) : async () {
    ignore caller;
    AuthLib.createShiftSchedule(state, schedule)
  };

  public query func getShiftSchedulesByDate(date : T.Timestamp) : async [T.ShiftSchedule] {
    AuthLib.getShiftSchedulesByDate(state, date)
  };

  public query func getShiftSchedulesByUser(userId : T.UserId) : async [T.ShiftSchedule] {
    AuthLib.getShiftSchedulesByUser(state, userId)
  };

  public shared ({ caller }) func updateShiftStatus(
      scheduleId : Text,
      status     : T.ShiftScheduleStatus
  ) : async () {
    ignore caller;
    AuthLib.updateShiftStatus(state, scheduleId, status)
  };

  // ─── Leave Requests ───────────────────────────────────────────────────────

  public shared ({ caller }) func createLeaveRequest(
      fromDate : T.Timestamp,
      toDate   : T.Timestamp,
      reason   : Text
  ) : async T.LeaveRequest {
    let session = switch (AuthLib.getSession(state, caller)) {
      case (?s) { s };
      case null { Runtime.trap("Not authenticated") };
    };
    let request : T.LeaveRequest = {
      id         = debug_show(Time.now());
      userId     = session.userId;
      fromDate;
      toDate;
      reason;
      status     = #Pending;
      reviewedBy = null;
      reviewedAt = null;
      createdAt  = Time.now();
    };
    AuthLib.createLeaveRequest(state, request);
    request
  };

  public query ({ caller }) func getMyLeaveRequests() : async [T.LeaveRequest] {
    switch (AuthLib.getSession(state, caller)) {
      case null { [] };
      case (?session) { AuthLib.getLeaveRequestsByUser(state, session.userId) };
    }
  };

  public query func getAllLeaveRequests() : async [T.LeaveRequest] {
    AuthLib.getAllLeaveRequests(state)
  };

  public shared ({ caller }) func reviewLeaveRequest(
      requestId : Text,
      approved  : Bool
  ) : async T.LeaveRequest {
    let session = switch (AuthLib.getSession(state, caller)) {
      case (?s) { s };
      case null { Runtime.trap("Not authenticated") };
    };
    AuthLib.reviewLeaveRequest(state, requestId, session.userId, approved)
  };

};
