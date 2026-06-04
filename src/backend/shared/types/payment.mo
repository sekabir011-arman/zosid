import CommonTypes "common";

module {

  // ─── Payment Method ───────────────────────────────────────────────────────

  public type PaymentMethod = { #Cash; #BKash; #Nagad; #Card; #Other };

  // ─── Payment Type ─────────────────────────────────────────────────────────

  public type PaymentType = {
    #Appointment;
    #Investigation;
    #Procedure;
    #Advance;
    #Other;
  };

  // ─── Payment Status ───────────────────────────────────────────────────────

  public type PaymentStatus = {
    #Invoice;
    #PartiallyPaid;
    #Paid;
    #Refunded;
  };

  // ─── Payment Item ─────────────────────────────────────────────────────────

  public type PaymentItem = {
    description : Text;
    rate        : Float;
    quantity    : Nat;
    total       : Float;
    discount    : Float;
  };

  // ─── Payment Record ───────────────────────────────────────────────────────

  public type Payment = {
    id            : Text;
    receiptNumber : Text;   // APT-0001 / INV-0001 / PRO-0001
    patientId     : ?CommonTypes.PatientId;
    patientName   : Text;
    patientAge    : ?Nat;
    patientSex    : ?Text;
    paymentType   : PaymentType;
    items         : [PaymentItem];
    subtotal      : Float;
    discount      : Float;
    finalAmount   : Float;
    paidAmount    : Float;
    dueAmount     : Float;
    advanceAmount : Float;
    method        : PaymentMethod;
    status        : PaymentStatus;
    refundAmount  : ?Float;
    refundReason  : ?Text;
    reportDate    : ?CommonTypes.Timestamp;  // for investigation receipts
    reportDelivery : ?CommonTypes.Timestamp;
    withHeader    : Bool;
    paperSize     : Text;  // "A4" | "A5" | "A3"
    createdBy     : CommonTypes.UserId;
    createdAt     : CommonTypes.Timestamp;
    whatsappSent  : Bool;
  };

  // ─── Rate List Entry ──────────────────────────────────────────────────────

  public type InvestigationRate = {
    id          : Text;
    testName    : Text;
    testCode    : ?Text;
    rate        : Float;
    department  : ?Text;
    isActive    : Bool;
  };

};
