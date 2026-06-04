import CommonTypes "common";
import Principal "mo:core/Principal";

module {

  // ─── Demographics ─────────────────────────────────────────────────────────

  public type Sex = { #Male; #Female; #Other };

  public type BloodGroup = {
    #APos; #ANeg;
    #BPos; #BNeg;
    #ABPos; #ABNeg;
    #OPos; #ONeg;
    #Unknown;
  };

  // ─── Patient ──────────────────────────────────────────────────────────────

  public type Patient = {
    id             : CommonTypes.PatientId;
    registerNumber : Text;                 // format: 0001/26
    name           : Text;
    nameBn         : ?Text;                // Bangla name
    dob            : CommonTypes.Timestamp;
    age            : Nat;
    sex            : Sex;
    bloodGroup     : BloodGroup;
    phone          : Text;
    address        : Text;
    email          : ?Text;
    photo          : ?Text;                // URL
    linkedUserId   : ?CommonTypes.UserId;
    registeredBy   : CommonTypes.UserId;
    registeredAt   : CommonTypes.Timestamp;
    isDeceased     : Bool;
    version        : Nat;
    isDeleted      : Bool;
  };

  // ─── Allergy ──────────────────────────────────────────────────────────────

  public type AllergySeverity = { #Mild; #Moderate; #Severe };

  public type Allergy = {
    id          : Text;
    patientId   : CommonTypes.PatientId;
    allergen    : Text;
    reaction    : Text;
    severity    : AllergySeverity;
    recordedBy  : CommonTypes.UserId;
    recordedAt  : CommonTypes.Timestamp;
  };

  // ─── Family History ───────────────────────────────────────────────────────

  public type FamilyHistory = {
    id        : Text;
    patientId : CommonTypes.PatientId;
    condition : Text;
    relation  : Text;
    notes     : ?Text;
    addedAt   : CommonTypes.Timestamp;
  };

  // ─── Vaccination ──────────────────────────────────────────────────────────

  public type Vaccination = {
    id           : Text;
    patientId    : CommonTypes.PatientId;
    vaccineName  : Text;
    dateGiven    : CommonTypes.Timestamp;
    nextDueDate  : ?CommonTypes.Timestamp;
    givenBy      : CommonTypes.UserId;
    notes        : ?Text;
    batchNumber  : ?Text;
  };

  // ─── Patient Search ───────────────────────────────────────────────────────

  public type PatientSearchResult = {
    id             : CommonTypes.PatientId;
    registerNumber : Text;
    name           : Text;
    phone          : Text;
    age            : Nat;
    sex            : Sex;
  };

};
