import List "mo:core/List";
import CommonTypes "../shared/types/common";

module {

  // ─── Expected Admission ───────────────────────────────────────────────────

  public type ExpectedAdmission = {
    patientId    : CommonTypes.PatientId;
    patientName  : Text;
    patientPhone : Text;
    consultantId : CommonTypes.UserId;
    expectedDate : CommonTypes.Timestamp;
    bedType      : Text;
    ward         : ?Text;
    appointmentId : ?CommonTypes.AppointmentId;
    notes        : ?Text;
    status       : Text;  // "Expected" | "Arrived" | "Cancelled"
  };

  // ─── Extended Admission State ─────────────────────────────────────────────

  public type AdmExtState = {
    expectedAdmissions : List.List<ExpectedAdmission>;
  };

  public func emptyAdmExtState() : AdmExtState {
    { expectedAdmissions = List.empty<ExpectedAdmission>() }
  };

  // ─── Expected Admissions ──────────────────────────────────────────────────

  let dayNs : Int = 86_400_000_000_000;

  public func addExpectedAdmission(
      state : AdmExtState,
      entry : ExpectedAdmission
  ) : ExpectedAdmission {
    state.expectedAdmissions.add(entry);
    entry
  };

  public func getTodayExpectedAdmissions(
      state : AdmExtState,
      date  : CommonTypes.Timestamp
  ) : [ExpectedAdmission] {
    let todayDay = date / dayNs;
    state.expectedAdmissions.toArray().filter(
      func(e : ExpectedAdmission) { e.expectedDate / dayNs == todayDay }
    )
  };

  public func updateExpectedAdmissionStatus(
      state     : AdmExtState,
      patientId : CommonTypes.PatientId,
      status    : Text
  ) : () {
    state.expectedAdmissions.mapInPlace(
      func(e : ExpectedAdmission) : ExpectedAdmission {
        if (e.patientId == patientId) { { e with status } } else { e }
      }
    )
  };

};
