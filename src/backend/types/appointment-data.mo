import ApptTypes "../shared/types/appointment";
import CommonTypes "../shared/types/common";

module {
  public type Appointment       = ApptTypes.Appointment;
  public type AppointmentType   = ApptTypes.AppointmentType;
  public type AppointmentStatus = ApptTypes.AppointmentStatus;
  public type Chamber           = ApptTypes.Chamber;
  public type SlotStatus        = ApptTypes.SlotStatus;
  public type TimeSlot          = ApptTypes.TimeSlot;
  public type AppointmentId     = CommonTypes.AppointmentId;
  public type UserId            = CommonTypes.UserId;
  public type Timestamp         = CommonTypes.Timestamp;
};
