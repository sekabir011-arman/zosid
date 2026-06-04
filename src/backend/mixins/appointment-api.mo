import Time "mo:core/Time";
import T "../types/appointment-data";
import AppointmentLib "../lib/appointment";

// Exposes the public API of the appointment-data domain.
// Public booking endpoints require NO auth check (any visitor can book).
mixin (state : AppointmentLib.AppointmentState) {

  // ─── Appointment CRUD ─────────────────────────────────────────────────────

  // Public endpoint — no caller auth required
  public shared ({ caller }) func createAppointment(
      patientId     : ?T.UserId,
      patientName   : Text,
      patientPhone  : Text,
      consultantId  : T.UserId,
      chamberId     : Text,
      date          : T.Timestamp,
      timeSlot      : Text,
      appointmentType : T.AppointmentType,
      notes         : ?Text
  ) : async T.Appointment {
    ignore caller;
    let apt : T.Appointment = {
      id             = debug_show(Time.now());
      patientId;
      patientName;
      patientPhone;
      consultantId;
      chamberId;
      date;
      timeSlot;
      appointmentType;
      notes;
      serialNumber   = 0; // auto-assigned by lib
      status         = #Booked;
      bookedBy       = caller;
      bookedAt       = Time.now();
      whatsappSent   = false;
      paymentId      = null;
    };
    AppointmentLib.createAppointment(state, apt)
  };

  public query func getAppointment(id : T.AppointmentId) : async ?T.Appointment {
    AppointmentLib.getAppointment(state, id)
  };

  public shared ({ caller }) func updateAppointmentStatus(
      id     : T.AppointmentId,
      status : T.AppointmentStatus
  ) : async ?T.Appointment {
    ignore caller;
    AppointmentLib.updateAppointmentStatus(state, id, status)
  };

  public shared ({ caller }) func cancelAppointment(id : T.AppointmentId) : async Bool {
    ignore caller;
    switch (AppointmentLib.updateAppointmentStatus(state, id, #Cancelled)) {
      case (?_) { true };
      case null  { false };
    }
  };

  public query func getAppointmentsByDoctor(consultantId : T.UserId) : async [T.Appointment] {
    AppointmentLib.getAppointmentsByDoctor(state, consultantId)
  };

  public query func getAppointmentsByDate(date : T.Timestamp) : async [T.Appointment] {
    AppointmentLib.getAppointmentsByDate(state, date)
  };

  public query func getAppointmentsSince(since : T.Timestamp) : async [T.Appointment] {
    AppointmentLib.getAppointmentsSince(state, since)
  };

  // Public endpoint — no auth required
  public query func getAvailableSlots(
      chamberId    : Text,
      date         : T.Timestamp,
      consultantId : T.UserId
  ) : async [T.TimeSlot] {
    AppointmentLib.getAvailableSlots(state, chamberId, date, consultantId)
  };

  // ─── Chamber CRUD ─────────────────────────────────────────────────────────

  public shared ({ caller }) func createChamber(chamber : T.Chamber) : async T.Chamber {
    ignore caller;
    AppointmentLib.createChamber(state, chamber)
  };

  public query func getChamber(id : Text) : async ?T.Chamber {
    AppointmentLib.getChamber(state, id)
  };

  public shared ({ caller }) func updateChamber(chamber : T.Chamber) : async T.Chamber {
    ignore caller;
    AppointmentLib.updateChamber(state, chamber)
  };

  // Public endpoint — visible on front page without login
  public query func listChambers() : async [T.Chamber] {
    AppointmentLib.listChambers(state)
  };

  public query func listChambersByConsultant(consultantId : T.UserId) : async [T.Chamber] {
    AppointmentLib.listChambersByConsultant(state, consultantId)
  };

};
