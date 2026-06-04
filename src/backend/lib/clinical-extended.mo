import Map "mo:core/Map";
import Time "mo:core/Time";
import CommonTypes "../shared/types/common";

module {

  // ─── Investigation Result ─────────────────────────────────────────────────

  public type InvestigationResult = {
    id            : Text;
    orderId       : Text;
    patientId     : CommonTypes.PatientId;
    testName      : Text;
    result        : Text;
    numericValue  : ?Float;
    unit          : ?Text;
    normalRange   : ?Text;
    isAbnormal    : Bool;
    interpretation : ?Text;
    reportedBy    : CommonTypes.UserId;
    reportedAt    : CommonTypes.Timestamp;
    verifiedBy    : ?CommonTypes.UserId;
    verifiedAt    : ?CommonTypes.Timestamp;
    reportFile    : ?Text;
  };

  // ─── Referral Letter ──────────────────────────────────────────────────────

  public type ReferralLetter = {
    id              : Text;
    patientId       : CommonTypes.PatientId;
    admissionId     : ?Text;
    referredBy      : CommonTypes.UserId;
    referredTo      : Text;
    institution     : ?Text;
    reason          : Text;
    clinicalSummary : Text;
    urgency         : Text;
    status          : Text;
    createdAt       : CommonTypes.Timestamp;
    sentAt          : ?CommonTypes.Timestamp;
  };

  // ─── Discharge Summary ────────────────────────────────────────────────────

  public type DischargeSummary = {
    id                  : Text;
    patientId           : CommonTypes.PatientId;
    admissionId         : Text;
    draftedBy           : CommonTypes.UserId;
    approvedBy          : ?CommonTypes.UserId;
    admissionDiagnosis  : Text;
    finalDiagnosis      : Text;
    proceduresDone      : [Text];
    conditionAtDischarge : Text;
    dischargeMedications : [Text];
    followUpDate        : ?CommonTypes.Timestamp;
    instructions        : Text;
    status              : Text;
    createdAt           : CommonTypes.Timestamp;
    approvedAt          : ?CommonTypes.Timestamp;
  };

  // ─── Consent Form ─────────────────────────────────────────────────────────

  public type ConsentForm = {
    id            : Text;
    patientId     : CommonTypes.PatientId;
    formType      : Text;
    content       : Text;
    signedByPatient : Bool;
    patientSignature : ?Text;
    witnessId     : ?CommonTypes.UserId;
    signedAt      : ?CommonTypes.Timestamp;
    createdBy     : CommonTypes.UserId;
    createdAt     : CommonTypes.Timestamp;
  };

  // ─── Discharge Checklist ──────────────────────────────────────────────────

  public type DischargeChecklist = {
    admissionId          : Text;
    ivLineRemoved        : Bool;
    medicationsStopped   : Bool;
    dischargeSummarySigned : Bool;
    belongingsCollected  : Bool;
    completedBy          : ?CommonTypes.UserId;
    completedAt          : ?CommonTypes.Timestamp;
  };

  // ─── Extended Clinical State ──────────────────────────────────────────────

  public type ExtClinicalState = {
    investigationResults : Map.Map<Text, InvestigationResult>;
    referralLetters      : Map.Map<Text, ReferralLetter>;
    dischargeSummaries   : Map.Map<Text, DischargeSummary>;
    consentForms         : Map.Map<Text, ConsentForm>;
    dischargeChecklists  : Map.Map<Text, DischargeChecklist>;
  };

  public func emptyExtState() : ExtClinicalState {
    {
      investigationResults = Map.empty<Text, InvestigationResult>();
      referralLetters      = Map.empty<Text, ReferralLetter>();
      dischargeSummaries   = Map.empty<Text, DischargeSummary>();
      consentForms         = Map.empty<Text, ConsentForm>();
      dischargeChecklists  = Map.empty<Text, DischargeChecklist>();
    }
  };

  // ─── Investigation Results ────────────────────────────────────────────────

  public func createInvestigationResult(
      state  : ExtClinicalState,
      result : InvestigationResult
  ) : InvestigationResult {
    state.investigationResults.add(result.id, result);
    result
  };

  public func getInvestigationResult(state : ExtClinicalState, id : Text) : ?InvestigationResult {
    state.investigationResults.get(id)
  };

  public func getResultsByPatient(
      state : ExtClinicalState, patientId : CommonTypes.PatientId
  ) : [InvestigationResult] {
    state.investigationResults.values().toArray().filter(
      func(r : InvestigationResult) { r.patientId == patientId }
    )
  };

  public func getResultsByOrder(state : ExtClinicalState, orderId : Text) : [InvestigationResult] {
    state.investigationResults.values().toArray().filter(
      func(r : InvestigationResult) { r.orderId == orderId }
    )
  };

  // ─── Referral Letter ──────────────────────────────────────────────────────

  public func createReferralLetter(
      state  : ExtClinicalState,
      letter : ReferralLetter
  ) : ReferralLetter {
    state.referralLetters.add(letter.id, letter);
    letter
  };

  public func getReferralLetter(state : ExtClinicalState, id : Text) : ?ReferralLetter {
    state.referralLetters.get(id)
  };

  public func getReferralsByPatient(
      state : ExtClinicalState, patientId : CommonTypes.PatientId
  ) : [ReferralLetter] {
    state.referralLetters.values().toArray().filter(
      func(l : ReferralLetter) { l.patientId == patientId }
    )
  };

  public func updateReferralStatus(
      state  : ExtClinicalState,
      id     : Text,
      status : Text
  ) : ?ReferralLetter {
    switch (state.referralLetters.get(id)) {
      case null { null };
      case (?letter) {
        let updated = { letter with status };
        state.referralLetters.add(id, updated);
        ?updated
      };
    }
  };

  // ─── Discharge Summary ────────────────────────────────────────────────────

  public func createDischargeSummary(
      state   : ExtClinicalState,
      summary : DischargeSummary
  ) : DischargeSummary {
    state.dischargeSummaries.add(summary.id, summary);
    summary
  };

  public func getDischargeSummary(
      state : ExtClinicalState, id : Text
  ) : ?DischargeSummary {
    state.dischargeSummaries.get(id)
  };

  public func getDischargeSummaryByAdmission(
      state       : ExtClinicalState,
      admissionId : Text
  ) : ?DischargeSummary {
    state.dischargeSummaries.values().find(
      func(s : DischargeSummary) { s.admissionId == admissionId }
    )
  };

  public func approveDischargeSummary(
      state      : ExtClinicalState,
      id         : Text,
      approvedBy : CommonTypes.UserId
  ) : ?DischargeSummary {
    switch (state.dischargeSummaries.get(id)) {
      case null { null };
      case (?summary) {
        let updated = { summary with
          status     = "Approved";
          approvedBy = ?approvedBy;
          approvedAt = ?Time.now();
        };
        state.dischargeSummaries.add(id, updated);
        ?updated
      };
    }
  };

  // ─── Consent Form ─────────────────────────────────────────────────────────

  public func createConsentForm(
      state : ExtClinicalState,
      form  : ConsentForm
  ) : ConsentForm {
    state.consentForms.add(form.id, form);
    form
  };

  public func getConsentForm(state : ExtClinicalState, id : Text) : ?ConsentForm {
    state.consentForms.get(id)
  };

  public func signConsentForm(
      state        : ExtClinicalState,
      id           : Text,
      signatureUrl : Text
  ) : ?ConsentForm {
    switch (state.consentForms.get(id)) {
      case null { null };
      case (?form) {
        let updated = { form with
          signedByPatient  = true;
          patientSignature = ?signatureUrl;
          signedAt         = ?Time.now();
        };
        state.consentForms.add(id, updated);
        ?updated
      };
    }
  };

  public func getConsentFormsByPatient(
      state : ExtClinicalState, patientId : CommonTypes.PatientId
  ) : [ConsentForm] {
    state.consentForms.values().toArray().filter(
      func(f : ConsentForm) { f.patientId == patientId }
    )
  };

  // ─── Discharge Checklist ──────────────────────────────────────────────────

  public func createDischargeChecklist(
      state     : ExtClinicalState,
      checklist : DischargeChecklist
  ) : DischargeChecklist {
    state.dischargeChecklists.add(checklist.admissionId, checklist);
    checklist
  };

  public func updateDischargeChecklist(
      state     : ExtClinicalState,
      checklist : DischargeChecklist
  ) : DischargeChecklist {
    state.dischargeChecklists.add(checklist.admissionId, checklist);
    checklist
  };

  public func getDischargeChecklist(
      state       : ExtClinicalState,
      admissionId : Text
  ) : ?DischargeChecklist {
    state.dischargeChecklists.get(admissionId)
  };

  public func isDischargeChecklistComplete(
      state       : ExtClinicalState,
      admissionId : Text
  ) : Bool {
    switch (state.dischargeChecklists.get(admissionId)) {
      case null { false };
      case (?cl) {
        cl.ivLineRemoved and cl.medicationsStopped and
        cl.dischargeSummarySigned and cl.belongingsCollected
      };
    }
  };

};
