import PaymentShared "../shared/types/payment";
import CommonTypes "../shared/types/common";

module {
  public type Payment          = PaymentShared.Payment;
  public type PaymentType      = PaymentShared.PaymentType;
  public type PaymentMethod    = PaymentShared.PaymentMethod;
  public type PaymentStatus    = PaymentShared.PaymentStatus;
  public type PaymentItem      = PaymentShared.PaymentItem;
  public type InvestigationRate = PaymentShared.InvestigationRate;
  public type Timestamp        = CommonTypes.Timestamp;
  public type PatientId        = CommonTypes.PatientId;
  public type UserId           = CommonTypes.UserId;
};
