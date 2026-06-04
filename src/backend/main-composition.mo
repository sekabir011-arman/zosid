// Composition root — imports all domain mixins, owns all state slices.
// No public function implementations here; only state declarations and mixin includes.
import Debug "mo:core/Debug";

// Shared type bridges
import CommonTypes "shared/types/common";
import PatientTypes "shared/types/patient";
import AuthTypes "shared/types/auth";
import ApptTypes "shared/types/appointment";
import SyncTypes "shared/types/sync";
import ClinicalTypes "shared/types/clinical";
import AlertTypes "shared/types/alert";
import HospitalTypes "shared/types/hospital";
import PaymentTypes "shared/types/payment";

// Lib modules
import PatientLib "lib/patient";
import AuthLib "lib/auth";
import AppointmentLib "lib/appointment";
import SyncLib "lib/sync";
import ClinicalExt "lib/clinical-extended";
import AdmExt "lib/admission-extended";
import PaymentLib "lib/payment";

// Domain mixin API handlers
import PatientMixin "mixins/patient-api";
import AuthMixin "mixins/auth-api";
import AppointmentMixin "mixins/appointment-api";
import SyncMixin "mixins/sync-api";
import ClinicalExtMixin "mixins/clinical-extended-api";
import AdmExtMixin "mixins/admission-extended-api";
import PaymentMixin "mixins/payment-api";

// Legacy mixins (existing domain handlers)
import ClinicalMixin "mixins/clinical-data-engine-api";

actor {

  // ─── Patient domain state ─────────────────────────────────────────────────
  let patientState = PatientLib.emptyState();

  // ─── Auth domain state ────────────────────────────────────────────────────
  let authState = AuthLib.emptyState();

  // ─── Appointment domain state ─────────────────────────────────────────────
  let appointmentState = AppointmentLib.emptyState();

  // ─── Sync domain state ───────────────────────────────────────────────────
  let syncState = SyncLib.emptyState();

  // ─── Extended clinical state (results / referrals / discharge / consent) ─
  let clinicalExtState = ClinicalExt.emptyExtState();

  // ─── Extended admission state (expected admissions panel) ────────────────
  let admExtState = AdmExt.emptyAdmExtState();

  // ─── Payment state ────────────────────────────────────────────────────────
  let paymentState = PaymentLib.emptyState();

  // ─── Include patient domain API ───────────────────────────────────────────
  include PatientMixin(patientState);

  // ─── Include auth domain API ──────────────────────────────────────────────
  include AuthMixin(authState);

  // ─── Include appointment + chamber API ───────────────────────────────────
  include AppointmentMixin(appointmentState);

  // ─── Include sync API ─────────────────────────────────────────────────────
  include SyncMixin(syncState);

  // ─── Include extended clinical API (results / referrals / discharge / consent / checklist)
  include ClinicalExtMixin(clinicalExtState);

  // ─── Include extended admission API (expected admissions panel) ──────────
  include AdmExtMixin(admExtState);

  // ─── Include payment API ──────────────────────────────────────────────────
  include PaymentMixin(paymentState);

  // ─── Legacy clinical data engine API (visits / notes / beds / orders / etc.)
  // State for this is owned by the legacy mixin itself (passed inline).
  // TODO(develop): wire ClinicalMixin with explicit state slices from lib modules.

};
