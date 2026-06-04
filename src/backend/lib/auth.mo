import List "mo:core/List";
import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Time "mo:core/Time";
import T "../types/auth-roles";
import Runtime "mo:core/Runtime";

module {

  public type AuthState = {
    users          : Map.Map<T.UserId, T.User>;
    emailIndex     : Map.Map<Text, T.UserId>;
    sessions       : Map.Map<Principal, T.Session>;
    staffProfiles  : Map.Map<T.UserId, T.StaffProfile>;
    shiftSchedules : List.List<T.ShiftSchedule>;
    leaveRequests  : List.List<T.LeaveRequest>;
    counter        : { var nextId : Nat };
  };

  public func emptyState() : AuthState {
    let state = {
      users          = Map.empty<T.UserId, T.User>();
      emailIndex     = Map.empty<Text, T.UserId>();
      sessions       = Map.empty<Principal, T.Session>();
      staffProfiles  = Map.empty<T.UserId, T.StaffProfile>();
      shiftSchedules = List.empty<T.ShiftSchedule>();
      leaveRequests  = List.empty<T.LeaveRequest>();
      counter        = { var nextId = 1 };
    };
    // Pre-populate admin user (dr.armankabir011@gmail.com / 01197247219)
    let adminId = state.counter.nextId;
    state.counter.nextId := adminId + 1;
    let admin : T.User = {
      id = adminId;
      email = "dr.armankabir011@gmail.com";
      passwordHash = "01197247219";
      role = #Admin;
      name = "Dr. Arman Kabir";
      phone = "+8801751959262";
      profilePhoto = null;
      status = #Active;
      approvedBy = null;
      approvedAt = null;
      createdAt = Time.now();
      lastLoginAt = null;
      patientId = null;
    };
    state.users.add(adminId, admin);
    state.emailIndex.add(admin.email, adminId);
    // Pre-populate admin2
    let admin2Id = state.counter.nextId;
    state.counter.nextId := admin2Id + 1;
    let admin2 : T.User = {
      id = admin2Id;
      email = "admin2@clinic.local";
      passwordHash = "admin2";
      role = #Admin;
      name = "Admin2";
      phone = "";
      profilePhoto = null;
      status = #Active;
      approvedBy = null;
      approvedAt = null;
      createdAt = Time.now();
      lastLoginAt = null;
      patientId = null;
    };
    state.users.add(admin2Id, admin2);
    state.emailIndex.add(admin2.email, admin2Id);
    state
  };

  // ─── User CRUD ────────────────────────────────────────────────────────────

  public func createUser(state : AuthState, email : Text, passwordHash : Text,
      role : T.Role, name : Text, phone : Text) : T.User {
    if (not isEmailUnique(state, email, null)) {
      // Return existing user if email already registered (idempotent for seeding)
      switch (getUserByEmail(state, email)) {
        case (?u) { return u };
        case null {};
      };
    };
    let id = state.counter.nextId;
    state.counter.nextId := id + 1;
    let user : T.User = {
      id;
      email;
      passwordHash;
      role;
      name;
      phone;
      profilePhoto = null;
      status = #Pending;
      approvedBy = null;
      approvedAt = null;
      createdAt = Time.now();
      lastLoginAt = null;
      patientId = null;
    };
    state.users.add(id, user);
    state.emailIndex.add(email, id);
    user
  };

  public func getUser(state : AuthState, id : T.UserId) : ?T.User {
    state.users.get(id)
  };

  public func getUserByEmail(state : AuthState, email : Text) : ?T.User {
    switch (state.emailIndex.get(email)) {
      case (?id) { state.users.get(id) };
      case null { null };
    }
  };

  public func updateUser(state : AuthState, user : T.User) : T.User {
    // Update email index if changed
    switch (state.users.get(user.id)) {
      case (?existing) {
        if (existing.email != user.email) {
          state.emailIndex.remove(existing.email);
          state.emailIndex.add(user.email, user.id);
        };
      };
      case null {};
    };
    state.users.add(user.id, user);
    user
  };

  public func listUsers(state : AuthState) : [T.User] {
    state.users.values().toArray()
  };

  public func isEmailUnique(state : AuthState, email : Text, excludeId : ?T.UserId) : Bool {
    switch (state.emailIndex.get(email)) {
      case null { true };
      case (?existingId) {
        switch (excludeId) {
          case (?eid) { existingId == eid };
          case null { false };
        }
      };
    }
  };

  public func approveUser(state : AuthState, userId : T.UserId, approvedBy : T.UserId) : T.User {
    let user = switch (state.users.get(userId)) {
      case (?u) { u };
      case null { Runtime.trap("User not found") };
    };
    let updated = { user with status = #Active; approvedBy = ?approvedBy; approvedAt = ?Time.now() };
    state.users.add(userId, updated);
    updated
  };

  public func suspendUser(state : AuthState, userId : T.UserId) : T.User {
    let user = switch (state.users.get(userId)) {
      case (?u) { u };
      case null { Runtime.trap("User not found") };
    };
    let updated = { user with status = #Suspended };
    state.users.add(userId, updated);
    updated
  };

  // Accepts plaintext comparison (passwordHash stores the raw password for seeding convenience)
  public func verifyPassword(state : AuthState, email : Text, passwordHash : Text) : ?T.User {
    switch (getUserByEmail(state, email)) {
      case null { null };
      case (?user) {
        if (user.passwordHash == passwordHash and user.status == #Active) { ?user } else { null }
      };
    }
  };

  public func isConsultantLevel(role : T.Role) : Bool {
    switch (role) {
      case (#Consultant or #AssistantProfessor or #AssociateProfessor or #Professor) { true };
      case _ { false };
    }
  };

  public func isAdmin(state : AuthState, userId : T.UserId) : Bool {
    switch (state.users.get(userId)) {
      case (?u) { u.role == #Admin };
      case null { false };
    }
  };

  // ─── Staff Profile ────────────────────────────────────────────────────────

  public func upsertStaffProfile(state : AuthState, profile : T.StaffProfile) : () {
    state.staffProfiles.add(profile.userId, profile)
  };

  public func getStaffProfile(state : AuthState, userId : T.UserId) : ?T.StaffProfile {
    state.staffProfiles.get(userId)
  };

  // ─── Shift Schedule ───────────────────────────────────────────────────────

  // One nanosecond day = 86_400_000_000_000
  let dayNs : Int = 86_400_000_000_000;

  public func createShiftSchedule(state : AuthState, schedule : T.ShiftSchedule) : () {
    state.shiftSchedules.add(schedule)
  };

  public func getShiftSchedulesByDate(state : AuthState, date : T.Timestamp) : [T.ShiftSchedule] {
    let dayStart = (date / dayNs) * dayNs;
    let dayEnd   = dayStart + dayNs;
    state.shiftSchedules.toArray().filter(
      func(s : T.ShiftSchedule) { s.date >= dayStart and s.date < dayEnd }
    )
  };

  public func getShiftSchedulesByUser(state : AuthState, userId : T.UserId) : [T.ShiftSchedule] {
    state.shiftSchedules.toArray().filter(func(s : T.ShiftSchedule) { s.userId == userId })
  };

  public func updateShiftStatus(state : AuthState, scheduleId : Text, status : T.ShiftScheduleStatus) : () {
    state.shiftSchedules.mapInPlace(func(s : T.ShiftSchedule) : T.ShiftSchedule {
      if (s.id == scheduleId) { { s with status } } else { s }
    })
  };

  // ─── Leave Request ────────────────────────────────────────────────────────

  public func createLeaveRequest(state : AuthState, request : T.LeaveRequest) : () {
    state.leaveRequests.add(request)
  };

  public func getLeaveRequestsByUser(state : AuthState, userId : T.UserId) : [T.LeaveRequest] {
    state.leaveRequests.toArray().filter(func(r : T.LeaveRequest) { r.userId == userId })
  };

  public func getAllLeaveRequests(state : AuthState) : [T.LeaveRequest] {
    state.leaveRequests.toArray()
  };

  public func reviewLeaveRequest(state : AuthState, requestId : Text,
      reviewedBy : T.UserId, approved : Bool) : T.LeaveRequest {
    var found : ?T.LeaveRequest = null;
    state.leaveRequests.mapInPlace(func(r : T.LeaveRequest) : T.LeaveRequest {
      if (r.id == requestId) {
        let updated = {
          r with
          status = if (approved) #Approved else #Rejected;
          reviewedBy = ?reviewedBy;
          reviewedAt = ?Time.now();
        };
        found := ?updated;
        updated
      } else { r }
    });
    switch (found) {
      case (?r) { r };
      case null { Runtime.trap("Leave request not found") };
    }
  };

  // ─── Session ──────────────────────────────────────────────────────────────

  public func createSession(state : AuthState, session : T.Session) : () {
    state.sessions.add(session.principal, session)
  };

  public func getSession(state : AuthState, principal : Principal) : ?T.Session {
    state.sessions.get(principal)
  };

  public func removeSession(state : AuthState, principal : Principal) : () {
    state.sessions.remove(principal)
  };

};
