import ClinicalExt "../lib/clinical-extended";
import CommonTypes "../shared/types/common";

// Exposes extended clinical API: InvestigationResults, ReferralLetters,
// DischargeSummaries, ConsentForms, DischargeChecklists.
mixin (state : ClinicalExt.ExtClinicalState) {

  // ─── Investigation Results ────────────────────────────────────────────────

  public shared ({ caller }) func createInvestigationResult(
      result : ClinicalExt.InvestigationResult
  ) : async ClinicalExt.InvestigationResult {
    ignore caller;
    ClinicalExt.createInvestigationResult(state, result)
  };

  public query func getInvestigationResult(id : Text) : async ?ClinicalExt.InvestigationResult {
    ClinicalExt.getInvestigationResult(state, id)
  };

  public query func getResultsByPatient(
      patientId : CommonTypes.PatientId
  ) : async [ClinicalExt.InvestigationResult] {
    ClinicalExt.getResultsByPatient(state, patientId)
  };

  public query func getResultsByOrder(
      orderId : Text
  ) : async [ClinicalExt.InvestigationResult] {
    ClinicalExt.getResultsByOrder(state, orderId)
  };

  // ─── Referral Letters ─────────────────────────────────────────────────────

  public shared ({ caller }) func createReferralLetter(
      letter : ClinicalExt.ReferralLetter
  ) : async ClinicalExt.ReferralLetter {
    ignore caller;
    ClinicalExt.createReferralLetter(state, letter)
  };

  public query func getReferralLetter(id : Text) : async ?ClinicalExt.ReferralLetter {
    ClinicalExt.getReferralLetter(state, id)
  };

  public query func getReferralsByPatient(
      patientId : CommonTypes.PatientId
  ) : async [ClinicalExt.ReferralLetter] {
    ClinicalExt.getReferralsByPatient(state, patientId)
  };

  public shared ({ caller }) func updateReferralStatus(
      id     : Text,
      status : Text
  ) : async ?ClinicalExt.ReferralLetter {
    ignore caller;
    ClinicalExt.updateReferralStatus(state, id, status)
  };

  // ─── Discharge Summary ────────────────────────────────────────────────────

  public shared ({ caller }) func createDischargeSummary(
      summary : ClinicalExt.DischargeSummary
  ) : async ClinicalExt.DischargeSummary {
    ignore caller;
    ClinicalExt.createDischargeSummary(state, summary)
  };

  public query func getDischargeSummary(id : Text) : async ?ClinicalExt.DischargeSummary {
    ClinicalExt.getDischargeSummary(state, id)
  };

  public query func getDischargeSummaryByAdmission(
      admissionId : Text
  ) : async ?ClinicalExt.DischargeSummary {
    ClinicalExt.getDischargeSummaryByAdmission(state, admissionId)
  };

  public shared ({ caller }) func approveDischargeSummary(
      id : Text
  ) : async ?ClinicalExt.DischargeSummary {
    ignore caller;
    ClinicalExt.approveDischargeSummary(state, id, 0)
  };

  // ─── Consent Form ─────────────────────────────────────────────────────────

  public shared ({ caller }) func createConsentForm(
      form : ClinicalExt.ConsentForm
  ) : async ClinicalExt.ConsentForm {
    ignore caller;
    ClinicalExt.createConsentForm(state, form)
  };

  public query func getConsentForm(id : Text) : async ?ClinicalExt.ConsentForm {
    ClinicalExt.getConsentForm(state, id)
  };

  public shared ({ caller }) func signConsentForm(
      id           : Text,
      signatureUrl : Text
  ) : async ?ClinicalExt.ConsentForm {
    ignore caller;
    ClinicalExt.signConsentForm(state, id, signatureUrl)
  };

  public query func getConsentFormsByPatient(
      patientId : CommonTypes.PatientId
  ) : async [ClinicalExt.ConsentForm] {
    ClinicalExt.getConsentFormsByPatient(state, patientId)
  };

  // ─── Discharge Checklist ──────────────────────────────────────────────────

  public shared ({ caller }) func createDischargeChecklist(
      checklist : ClinicalExt.DischargeChecklist
  ) : async ClinicalExt.DischargeChecklist {
    ignore caller;
    ClinicalExt.createDischargeChecklist(state, checklist)
  };

  public shared ({ caller }) func updateDischargeChecklist(
      checklist : ClinicalExt.DischargeChecklist
  ) : async ClinicalExt.DischargeChecklist {
    ignore caller;
    ClinicalExt.updateDischargeChecklist(state, checklist)
  };

  public query func getDischargeChecklist(
      admissionId : Text
  ) : async ?ClinicalExt.DischargeChecklist {
    ClinicalExt.getDischargeChecklist(state, admissionId)
  };

  public query func isDischargeChecklistComplete(admissionId : Text) : async Bool {
    ClinicalExt.isDischargeChecklistComplete(state, admissionId)
  };

};
