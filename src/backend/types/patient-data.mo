import PatientTypes "../shared/types/patient";
import CommonTypes "../shared/types/common";

module {
  public type Patient              = PatientTypes.Patient;
  public type Sex                  = PatientTypes.Sex;
  public type BloodGroup           = PatientTypes.BloodGroup;
  public type Allergy              = PatientTypes.Allergy;
  public type AllergySeverity      = PatientTypes.AllergySeverity;
  public type FamilyHistory        = PatientTypes.FamilyHistory;
  public type Vaccination          = PatientTypes.Vaccination;
  public type PatientSearchResult  = PatientTypes.PatientSearchResult;
  public type PatientId            = CommonTypes.PatientId;
  public type UserId               = CommonTypes.UserId;
  public type Timestamp            = CommonTypes.Timestamp;
  public type Result<T>            = CommonTypes.Result<T>;
};
