import Time "mo:core/Time";
import Nat "mo:core/Nat";
import T "../types/patient-data";
import PatientLib "../lib/patient";

// Exposes the public API of the patient-data domain.
mixin (state : PatientLib.PatientState) {

  // ─── Patient CRUD ─────────────────────────────────────────────────────────

  public shared ({ caller }) func createPatient(
      name       : Text,
      nameBn     : ?Text,
      dob        : T.Timestamp,
      sex        : T.Sex,
      bloodGroup : T.BloodGroup,
      phone      : Text,
      address    : Text,
      email      : ?Text,
      photo      : ?Text
  ) : async T.Result<T.Patient> {
    // registeredBy uses 0 as anonymous; real auth wired at main.mo layer
    ignore caller;
    let p = PatientLib.createPatient(state, name, nameBn, dob, sex, bloodGroup,
        phone, address, email, photo, 0);
    #Ok p
  };

  public query func getPatient(id : T.PatientId) : async ?T.Patient {
    PatientLib.getPatient(state, id)
  };

  public shared ({ caller }) func updatePatient(patient : T.Patient) : async T.Result<T.Patient> {
    ignore caller;
    let updated = PatientLib.updatePatient(state, patient);
    #Ok updated
  };

  public query func listPatients() : async [T.Patient] {
    PatientLib.listPatients(state)
  };

  public query func listPatientsSince(since : T.Timestamp) : async [T.Patient] {
    PatientLib.listPatientsSince(state, since)
  };

  public query func searchPatients(searchQuery : Text) : async [T.PatientSearchResult] {
    PatientLib.searchPatients(state, searchQuery)
  };

  // ─── Allergy ──────────────────────────────────────────────────────────────

  public shared ({ caller }) func addAllergy(
      patientId : T.PatientId,
      allergen  : Text,
      reaction  : Text,
      severity  : T.AllergySeverity
  ) : async T.Result<T.Allergy> {
    ignore caller;
    let now = Time.now();
    let allergy : T.Allergy = {
      id         = Nat.toText(patientId) # "-" # debug_show(now);
      patientId;
      allergen;
      reaction;
      severity;
      recordedBy = 0;
      recordedAt = now;
    };
    PatientLib.addAllergy(state, allergy);
    #Ok allergy
  };

  public query func getAllergies(patientId : T.PatientId) : async [T.Allergy] {
    PatientLib.getAllergies(state, patientId)
  };

  // ─── Family History ───────────────────────────────────────────────────────

  public shared ({ caller }) func addFamilyHistory(
      patientId : T.PatientId,
      condition : Text,
      relation  : Text,
      notes     : ?Text
  ) : async T.Result<T.FamilyHistory> {
    ignore caller;
    let now = Time.now();
    let entry : T.FamilyHistory = {
      id        = Nat.toText(patientId) # "-" # debug_show(now);
      patientId;
      condition;
      relation;
      notes;
      addedAt   = now;
    };
    PatientLib.addFamilyHistory(state, entry);
    #Ok entry
  };

  public query func getFamilyHistory(patientId : T.PatientId) : async [T.FamilyHistory] {
    PatientLib.getFamilyHistory(state, patientId)
  };

  // ─── Vaccination ──────────────────────────────────────────────────────────

  public shared ({ caller }) func addVaccination(
      patientId   : T.PatientId,
      vaccineName : Text,
      dateGiven   : T.Timestamp,
      nextDueDate : ?T.Timestamp,
      batchNumber : ?Text,
      notes       : ?Text
  ) : async T.Result<T.Vaccination> {
    ignore caller;
    let v : T.Vaccination = {
      id          = Nat.toText(patientId) # "-" # debug_show(dateGiven);
      patientId;
      vaccineName;
      dateGiven;
      nextDueDate;
      batchNumber;
      notes;
      givenBy     = 0;
    };
    PatientLib.addVaccination(state, v);
    #Ok v
  };

  public query func getVaccinations(patientId : T.PatientId) : async [T.Vaccination] {
    PatientLib.getVaccinations(state, patientId)
  };

};
