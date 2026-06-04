import List "mo:core/List";
import Map "mo:core/Map";
import Time "mo:core/Time";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Runtime "mo:core/Runtime";
import T "../types/appointment-data";

module {

  public type AppointmentState = {
    appointments   : Map.Map<T.AppointmentId, T.Appointment>;
    chambers       : Map.Map<Text, T.Chamber>;
    counter        : { var nextSerial : Nat };
  };

  // One nanosecond day
  let dayNs : Int = 86_400_000_000_000;

  public func emptyState() : AppointmentState {
    {
      appointments = Map.empty<T.AppointmentId, T.Appointment>();
      chambers     = Map.empty<Text, T.Chamber>();
      counter      = { var nextSerial = 0 };
    }
  };

  // ─── Appointment ──────────────────────────────────────────────────────────

  // Auto-assign serial number: count existing appts for same date+chamber+doctor, +1
  func nextSerialForDay(
      state        : AppointmentState,
      chamberId    : Text,
      date         : T.Timestamp,
      consultantId : T.UserId
  ) : Nat {
    let dayStart = (date / dayNs) * dayNs;
    let dayEnd   = dayStart + dayNs;
    let count = state.appointments.values().toArray().filter(
      func(a : T.Appointment) {
        a.chamberId == chamberId and a.consultantId == consultantId and
        a.date >= dayStart and a.date < dayEnd and a.status != #Cancelled
      }
    ).size();
    count + 1
  };

  public func createAppointment(state : AppointmentState, apt : T.Appointment) : T.Appointment {
    let serial = nextSerialForDay(state, apt.chamberId, apt.date, apt.consultantId);
    let finalApt = { apt with serialNumber = serial };
    state.appointments.add(apt.id, finalApt);
    finalApt
  };

  public func getAppointment(state : AppointmentState, id : T.AppointmentId) : ?T.Appointment {
    state.appointments.get(id)
  };

  public func updateAppointment(state : AppointmentState, apt : T.Appointment) : T.Appointment {
    state.appointments.add(apt.id, apt);
    apt
  };

  public func updateAppointmentStatus(
      state : AppointmentState, id : T.AppointmentId, status : T.AppointmentStatus
  ) : ?T.Appointment {
    switch (state.appointments.get(id)) {
      case null { null };
      case (?apt) {
        let updated = { apt with status };
        state.appointments.add(id, updated);
        ?updated
      };
    }
  };

  public func getAppointmentsByDoctor(
      state : AppointmentState, consultantId : T.UserId
  ) : [T.Appointment] {
    state.appointments.values().toArray().filter(
      func(a : T.Appointment) { a.consultantId == consultantId }
    )
  };

  public func getAppointmentsByDate(
      state : AppointmentState, date : T.Timestamp
  ) : [T.Appointment] {
    let dayStart = (date / dayNs) * dayNs;
    let dayEnd   = dayStart + dayNs;
    state.appointments.values().toArray().filter(
      func(a : T.Appointment) { a.date >= dayStart and a.date < dayEnd }
    )
  };

  public func getAppointmentsSince(
      state : AppointmentState, since : T.Timestamp
  ) : [T.Appointment] {
    state.appointments.values().toArray().filter(
      func(a : T.Appointment) { a.bookedAt >= since }
    )
  };

  public func checkSlotConflict(
      state : AppointmentState,
      chamberId    : Text,
      date         : T.Timestamp,
      timeSlot     : Text,
      consultantId : T.UserId
  ) : Bool {
    let dayStart = (date / dayNs) * dayNs;
    let dayEnd   = dayStart + dayNs;
    let conflicts = state.appointments.values().toArray().filter(
      func(a : T.Appointment) {
        a.chamberId == chamberId and
        a.consultantId == consultantId and
        a.timeSlot == timeSlot and
        a.date >= dayStart and a.date < dayEnd and
        a.status != #Cancelled
      }
    );
    conflicts.size() > 0
  };

  // Generate 30-min slots 9am–5pm; mark each as Booked if conflict exists
  public func getAvailableSlots(
      state        : AppointmentState,
      chamberId    : Text,
      date         : T.Timestamp,
      consultantId : T.UserId
  ) : [T.TimeSlot] {
    // Slot labels: 09:00 .. 16:30 (step 30 min)
    let slotLabels : [Text] = [
      "09:00","09:30","10:00","10:30","11:00","11:30",
      "12:00","12:30","13:00","13:30","14:00","14:30",
      "15:00","15:30","16:00","16:30"
    ];
    slotLabels.map<Text, T.TimeSlot>(func(slot) {
      let booked = checkSlotConflict(state, chamberId, date, slot, consultantId);
      { time = slot; status = if (booked) #Booked else #Available }
    })
  };

  // ─── Chamber ──────────────────────────────────────────────────────────────

  public func createChamber(state : AppointmentState, chamber : T.Chamber) : T.Chamber {
    state.chambers.add(chamber.id, chamber);
    chamber
  };

  public func getChamber(state : AppointmentState, id : Text) : ?T.Chamber {
    state.chambers.get(id)
  };

  public func updateChamber(state : AppointmentState, chamber : T.Chamber) : T.Chamber {
    state.chambers.add(chamber.id, chamber);
    chamber
  };

  public func listChambers(state : AppointmentState) : [T.Chamber] {
    state.chambers.values().toArray()
  };

  public func listChambersByConsultant(
      state : AppointmentState, consultantId : T.UserId
  ) : [T.Chamber] {
    state.chambers.values().toArray().filter(
      func(c : T.Chamber) { c.consultantId == consultantId }
    )
  };

};
