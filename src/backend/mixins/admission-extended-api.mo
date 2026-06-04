import AdmExt "../lib/admission-extended";
import CommonTypes "../shared/types/common";
import Time "mo:core/Time";

// Exposes extended admission API: ExpectedAdmissions panel.
mixin (state : AdmExt.AdmExtState) {

  public shared ({ caller }) func addExpectedAdmission(
      entry : AdmExt.ExpectedAdmission
  ) : async AdmExt.ExpectedAdmission {
    ignore caller;
    AdmExt.addExpectedAdmission(state, entry)
  };

  public query func getTodayExpectedAdmissions(
      date : CommonTypes.Timestamp
  ) : async [AdmExt.ExpectedAdmission] {
    AdmExt.getTodayExpectedAdmissions(state, date)
  };

  public shared ({ caller }) func updateExpectedAdmissionStatus(
      patientId : CommonTypes.PatientId,
      status    : Text
  ) : async () {
    ignore caller;
    AdmExt.updateExpectedAdmissionStatus(state, patientId, status)
  };

};
