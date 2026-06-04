import CommonTypes "common";

module {

  // ─── Appointment ──────────────────────────────────────────────────────────

  public type AppointmentType = { #New; #Followup; #Emergency };

  public type AppointmentStatus = {
    #Booked;
    #Confirmed;
    #Completed;
    #Cancelled;
    #NoShow;
  };

  public type Appointment = {
    id            : CommonTypes.AppointmentId;
    patientId     : ?CommonTypes.PatientId;   // null = walk-in
    patientName   : Text;
    patientPhone  : Text;
    consultantId  : CommonTypes.UserId;
    chamberId     : Text;
    date          : CommonTypes.Timestamp;
    timeSlot      : Text;
    serialNumber  : Nat;
    appointmentType : AppointmentType;
    status        : AppointmentStatus;
    paymentId     : ?Text;
    bookedByUser  : ?CommonTypes.UserId;       // null = public booking
    bookedAt      : CommonTypes.Timestamp;
    whatsappSent  : Bool;
    notes         : ?Text;
  };

  // ─── Chamber ──────────────────────────────────────────────────────────────

  public type Chamber = {
    id            : Text;
    name          : Text;
    address       : Text;
    lat           : Float;
    lng           : Float;
    phone         : Text;
    consultantId  : CommonTypes.UserId;
    consultantName : Text;
    days          : [Text];
    hours         : Text;
    isActive      : Bool;
    colorClass    : ?Text;  // UI accent for gradient card
    createdAt     : CommonTypes.Timestamp;
    updatedAt     : CommonTypes.Timestamp;
  };

  // ─── Slot Availability ────────────────────────────────────────────────────

  public type SlotStatus = { #Available; #Booked; #Blocked };

  public type TimeSlot = {
    time   : Text;
    status : SlotStatus;
  };

};
