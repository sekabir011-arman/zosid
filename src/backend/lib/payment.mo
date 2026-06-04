import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import T "../shared/types/payment";
import CommonTypes "../shared/types/common";

module {

  public type PaymentState = {
    payments           : Map.Map<Text, T.Payment>;
    investigationRates : Map.Map<Text, T.InvestigationRate>;
    counter            : {
      var aptSeq : Nat;
      var invSeq : Nat;
      var proSeq : Nat;
      var othSeq : Nat;
    };
  };

  public func emptyState() : PaymentState {
    {
      payments           = Map.empty<Text, T.Payment>();
      investigationRates = Map.empty<Text, T.InvestigationRate>();
      counter            = { var aptSeq = 0; var invSeq = 0; var proSeq = 0; var othSeq = 0 };
    }
  };

  // Format: APT-0001 / INV-0001 / PRO-0001 / OTH-0001
  func padSeq(n : Nat) : Text {
    let s = Nat.toText(n);
    if (s.size() >= 4) { s } else {
      let pad = 4 - s.size();
      let zeros = if (pad == 3) { "000" } else if (pad == 2) { "00" } else { "0" };
      zeros # s
    }
  };

  public func generateReceiptNumber(
      state : PaymentState, paymentType : T.PaymentType
  ) : Text {
    switch (paymentType) {
      case (#Appointment) {
        state.counter.aptSeq := state.counter.aptSeq + 1;
        "APT-" # padSeq(state.counter.aptSeq)
      };
      case (#Investigation) {
        state.counter.invSeq := state.counter.invSeq + 1;
        "INV-" # padSeq(state.counter.invSeq)
      };
      case (#Procedure) {
        state.counter.proSeq := state.counter.proSeq + 1;
        "PRO-" # padSeq(state.counter.proSeq)
      };
      case (#Advance or #Other) {
        state.counter.othSeq := state.counter.othSeq + 1;
        "OTH-" # padSeq(state.counter.othSeq)
      };
    }
  };

  public func createPayment(state : PaymentState, payment : T.Payment) : T.Payment {
    let receiptNumber = generateReceiptNumber(state, payment.paymentType);
    let final = { payment with receiptNumber };
    state.payments.add(final.id, final);
    final
  };

  public func getPayment(state : PaymentState, id : Text) : ?T.Payment {
    state.payments.get(id)
  };

  public func updatePayment(state : PaymentState, payment : T.Payment) : T.Payment {
    let dueAmount = payment.finalAmount - payment.paidAmount;
    let updated = { payment with dueAmount };
    state.payments.add(updated.id, updated);
    updated
  };

  public func getPaymentsByPatient(
      state : PaymentState, patientId : CommonTypes.PatientId
  ) : [T.Payment] {
    state.payments.values().toArray().filter(
      func(p : T.Payment) {
        switch (p.patientId) {
          case (?pid) { pid == patientId };
          case null   { false };
        }
      }
    )
  };

  public func getOutstandingBalances(state : PaymentState) : [T.Payment] {
    state.payments.values().toArray().filter(
      func(p : T.Payment) { p.dueAmount > 0.0 }
    )
  };

  public func getPaymentsSince(
      state : PaymentState, since : CommonTypes.Timestamp
  ) : [T.Payment] {
    state.payments.values().toArray().filter(
      func(p : T.Payment) { p.createdAt >= since }
    )
  };

  // ─── Investigation Rates ──────────────────────────────────────────────────

  public func upsertInvestigationRate(
      state : PaymentState, rate : T.InvestigationRate
  ) : () {
    let key = rate.testName.toLower();
    state.investigationRates.add(key, rate)
  };

  public func bulkUpsertRates(
      state : PaymentState, rates : [T.InvestigationRate]
  ) : () {
    for (rate in rates.values()) {
      upsertInvestigationRate(state, rate)
    }
  };

  public func getInvestigationRates(state : PaymentState) : [T.InvestigationRate] {
    state.investigationRates.values().toArray().filter(
      func(r : T.InvestigationRate) { r.isActive }
    )
  };

  public func searchInvestigationRates(
      state : PaymentState, searchQuery : Text
  ) : [T.InvestigationRate] {
    let q = searchQuery.toLower();
    state.investigationRates.values().toArray().filter(
      func(r : T.InvestigationRate) {
        r.isActive and Text.contains(r.testName.toLower(), #text q)
      }
    )
  };

};
