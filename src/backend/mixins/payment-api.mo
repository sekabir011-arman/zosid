import T "../shared/types/payment";
import PaymentLib "../lib/payment";
import CommonTypes "../shared/types/common";

// Exposes the public API of the payment domain.
mixin (state : PaymentLib.PaymentState) {

  // ─── Payments ─────────────────────────────────────────────────────────────

  public shared ({ caller }) func createPayment(payment : T.Payment) : async T.Payment {
    ignore caller;
    PaymentLib.createPayment(state, payment)
  };

  public query func getPayment(id : Text) : async ?T.Payment {
    PaymentLib.getPayment(state, id)
  };

  public shared ({ caller }) func updatePayment(payment : T.Payment) : async T.Payment {
    ignore caller;
    PaymentLib.updatePayment(state, payment)
  };

  public query func getPaymentsByPatient(
      patientId : CommonTypes.PatientId
  ) : async [T.Payment] {
    PaymentLib.getPaymentsByPatient(state, patientId)
  };

  public query func getOutstandingBalances() : async [T.Payment] {
    PaymentLib.getOutstandingBalances(state)
  };

  public query func getPaymentsSince(since : CommonTypes.Timestamp) : async [T.Payment] {
    PaymentLib.getPaymentsSince(state, since)
  };

  // ─── Investigation Rates ──────────────────────────────────────────────────

  public shared ({ caller }) func upsertInvestigationRate(
      rate : T.InvestigationRate
  ) : async () {
    ignore caller;
    PaymentLib.upsertInvestigationRate(state, rate)
  };

  public shared ({ caller }) func bulkUpsertRates(
      rates : [T.InvestigationRate]
  ) : async () {
    ignore caller;
    PaymentLib.bulkUpsertRates(state, rates)
  };

  public query func getInvestigationRates() : async [T.InvestigationRate] {
    PaymentLib.getInvestigationRates(state)
  };

  public query func searchInvestigationRates(searchQuery : Text) : async [T.InvestigationRate] {
    PaymentLib.searchInvestigationRates(state, searchQuery)
  };

};
