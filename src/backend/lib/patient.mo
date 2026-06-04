import List "mo:core/List";
import Map "mo:core/Map";
import Time "mo:core/Time";
import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Text "mo:core/Text";
import T "../types/patient-data";

module {

  public type PatientState = {
    patients       : Map.Map<T.PatientId, T.Patient>;
    allergies      : Map.Map<T.PatientId, List.List<T.Allergy>>;
    familyHistory  : Map.Map<T.PatientId, List.List<T.FamilyHistory>>;
    vaccinations   : Map.Map<T.PatientId, List.List<T.Vaccination>>;
    emailIndex     : Map.Map<Text, T.PatientId>;
    registerIndex  : Map.Map<Text, T.PatientId>;
    counter        : { var nextId : Nat; var nextRegSeq : Nat };
  };

  public func emptyState() : PatientState {
    {
      patients      = Map.empty<T.PatientId, T.Patient>();
      allergies     = Map.empty<T.PatientId, List.List<T.Allergy>>();
      familyHistory = Map.empty<T.PatientId, List.List<T.FamilyHistory>>();
      vaccinations  = Map.empty<T.PatientId, List.List<T.Vaccination>>();
      emailIndex    = Map.empty<Text, T.PatientId>();
      registerIndex = Map.empty<Text, T.PatientId>();
      counter       = { var nextId = 1; var nextRegSeq = 0 };
    }
  };

  // ─── Register Number ──────────────────────────────────────────────────────

  // Format: 0001/YY — zero-padded 4-digit seq / 2-digit year
  public func generateRegisterNumber(state : PatientState) : Text {
    let nowSecs = Time.now() / 1_000_000_000;
    let daysSinceEpoch = nowSecs / 86_400;
    // Gregorian year approximation (good enough for display)
    let year = Int.abs(daysSinceEpoch) / 365 + 1970;
    let yy = year % 100;
    let seq = state.counter.nextRegSeq + 1;
    state.counter.nextRegSeq := seq;
    let seqText = Nat.toText(seq);
    let padded = if (seqText.size() < 4) {
      let zeros = 4 - seqText.size();
      let zeroPad = if (zeros == 3) { "000" } else if (zeros == 2) { "00" } else { "0" };
      zeroPad # seqText
    } else { seqText };
    let yyText = Nat.toText(yy);
    let yyPadded = if (yyText.size() < 2) { "0" # yyText } else { yyText };
    padded # "/" # yyPadded
  };

  public func createPatient(state : PatientState, name : Text, nameBn : ?Text,
      dob : T.Timestamp, sex : T.Sex, bloodGroup : T.BloodGroup, phone : Text,
      address : Text, email : ?Text, photo : ?Text, registeredBy : T.UserId) : T.Patient {
    let id = state.counter.nextId;
    state.counter.nextId := id + 1;
    let regNum = generateRegisterNumber(state);
    // Approximate age in years from dob
    let nowNs = Time.now();
    let ageNs = nowNs - dob;
    let ageYears : Nat = Int.abs(ageNs) / (365 * 24 * 60 * 60 * 1_000_000_000);
    let patient : T.Patient = {
      id;
      registerNumber = regNum;
      name;
      nameBn;
      dob;
      age = ageYears;
      sex;
      bloodGroup;
      phone;
      address;
      email;
      photo;
      linkedUserId = null;
      registeredBy;
      registeredAt = nowNs;
      isDeceased = false;
      version = 1;
      isDeleted = false;
    };
    state.patients.add(id, patient);
    state.registerIndex.add(regNum, id);
    switch (email) {
      case (?e) { state.emailIndex.add(e, id) };
      case null {};
    };
    patient
  };

  public func getPatient(state : PatientState, id : T.PatientId) : ?T.Patient {
    switch (state.patients.get(id)) {
      case (?p) { if (p.isDeleted) null else ?p };
      case null { null };
    }
  };

  public func updatePatient(state : PatientState, patient : T.Patient) : T.Patient {
    let existing = switch (state.patients.get(patient.id)) {
      case (?p) { p };
      case null { patient };
    };
    // Remove old email index if email changed
    switch (existing.email) {
      case (?oldEmail) {
        switch (patient.email) {
          case (?newEmail) {
            if (oldEmail != newEmail) {
              state.emailIndex.remove(oldEmail);
              state.emailIndex.add(newEmail, patient.id);
            };
          };
          case null { state.emailIndex.remove(oldEmail) };
        };
      };
      case null {
        switch (patient.email) {
          case (?e) { state.emailIndex.add(e, patient.id) };
          case null {};
        };
      };
    };
    let updated = { patient with version = existing.version + 1 };
    state.patients.add(patient.id, updated);
    updated
  };

  public func listPatients(state : PatientState) : [T.Patient] {
    state.patients.values().toArray().filter(func(p : T.Patient) { not p.isDeleted })
  };

  public func listPatientsSince(state : PatientState, since : T.Timestamp) : [T.Patient] {
    state.patients.values().toArray().filter(
      func(p : T.Patient) { not p.isDeleted and p.registeredAt >= since }
    )
  };

  func textContains(haystack : Text, needle : Text) : Bool {
    let h = Text.toLower(haystack);
    let n = Text.toLower(needle);
    if (n.size() == 0) return true;
    Text.contains(h, #text n)
  };

  public func searchPatients(state : PatientState, query : Text) : [T.PatientSearchResult] {
    let q = Text.toLower(query);
    state.patients.values().toArray()
      .filter(func(p : T.Patient) {
        not p.isDeleted and (
          textContains(p.name, q) or
          textContains(p.phone, q) or
          textContains(p.registerNumber, q) or
          (switch (p.email) { case (?e) textContains(e, q); case null false })
        )
      })
      .map<T.Patient, T.PatientSearchResult>(func(p) {
        { id = p.id; registerNumber = p.registerNumber; name = p.name;
          phone = p.phone; age = p.age; sex = p.sex }
      })
  };

  public func isEmailUnique(state : PatientState, email : Text, excludeId : ?T.PatientId) : Bool {
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

  // ─── Allergy ──────────────────────────────────────────────────────────────

  public func addAllergy(state : PatientState, allergy : T.Allergy) : () {
    let existing = switch (state.allergies.get(allergy.patientId)) {
      case (?lst) { lst };
      case null { List.empty<T.Allergy>() };
    };
    existing.add(allergy);
    state.allergies.add(allergy.patientId, existing)
  };

  public func getAllergies(state : PatientState, patientId : T.PatientId) : [T.Allergy] {
    switch (state.allergies.get(patientId)) {
      case (?lst) { lst.toArray() };
      case null { [] };
    }
  };

  // ─── Family History ───────────────────────────────────────────────────────

  public func addFamilyHistory(state : PatientState, entry : T.FamilyHistory) : () {
    let existing = switch (state.familyHistory.get(entry.patientId)) {
      case (?lst) { lst };
      case null { List.empty<T.FamilyHistory>() };
    };
    existing.add(entry);
    state.familyHistory.add(entry.patientId, existing)
  };

  public func getFamilyHistory(state : PatientState, patientId : T.PatientId) : [T.FamilyHistory] {
    switch (state.familyHistory.get(patientId)) {
      case (?lst) { lst.toArray() };
      case null { [] };
    }
  };

  // ─── Vaccination ──────────────────────────────────────────────────────────

  public func addVaccination(state : PatientState, v : T.Vaccination) : () {
    let existing = switch (state.vaccinations.get(v.patientId)) {
      case (?lst) { lst };
      case null { List.empty<T.Vaccination>() };
    };
    existing.add(v);
    state.vaccinations.add(v.patientId, existing)
  };

  public func getVaccinations(state : PatientState, patientId : T.PatientId) : [T.Vaccination] {
    switch (state.vaccinations.get(patientId)) {
      case (?lst) { lst.toArray() };
      case null { [] };
    }
  };

};
