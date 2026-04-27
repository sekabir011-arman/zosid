import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
import { differenceInDays, format } from "date-fns";
import {
  ArrowLeftRight,
  Bed,
  Building2,
  CheckCircle2,
  Layers,
  LogOut,
  Plus,
  Search,
  Sparkles,
  Users,
} from "lucide-react";
import { useMemo, useState } from "react";
import { toast } from "sonner";
import {
  loadFromAllDoctorKeys,
  useAssignBed,
  useCreateBedRecord,
  useGetAllBeds,
} from "../hooks/useQueries";
import { getClinicalStore, saveClinicalStore } from "../lib/clinicalStore";
import type { BedRecord, Patient } from "../types";

// ── Seed demo beds if none exist ──────────────────────────────────────────────
function seedBedsIfEmpty() {
  const store = getClinicalStore();
  if ((store.beds as BedRecord[] | undefined)?.length) return;
  const seeds: BedRecord[] = [
    {
      id: 1n,
      bedNumber: "G-01",
      ward: "General",
      floor: "Ground Floor",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Empty",
      transferHistory: [],
    },
    {
      id: 2n,
      bedNumber: "G-02",
      ward: "General",
      floor: "Ground Floor",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Occupied",
      patientName: "Rahim Uddin",
      admissionDate: BigInt(Date.now() - 86400000 * 2) * 1_000_000n,
      transferHistory: [],
    },
    {
      id: 3n,
      bedNumber: "M-01",
      ward: "Medical",
      floor: "Floor 1",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Empty",
      transferHistory: [],
    },
    {
      id: 4n,
      bedNumber: "M-02",
      ward: "Medical",
      floor: "Floor 1",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Maintenance",
      transferHistory: [],
    },
    {
      id: 5n,
      bedNumber: "ICU-01",
      ward: "ICU",
      floor: "Floor 2",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Occupied",
      patientName: "Karim Hossain",
      admissionDate: BigInt(Date.now() - 86400000) * 1_000_000n,
      transferHistory: [],
    },
    {
      id: 6n,
      bedNumber: "ICU-02",
      ward: "ICU",
      floor: "Floor 2",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Cleaning",
      transferHistory: [],
    },
    {
      id: 7n,
      bedNumber: "ICU-03",
      ward: "ICU",
      floor: "Floor 2",
      hospitalName: "Dhaka Medical College Hospital",
      status: "Reserved",
      transferHistory: [],
    },
    {
      id: 8n,
      bedNumber: "C-01",
      ward: "Chamber",
      floor: "Ground Floor",
      hospitalName: "Dr. Arman Kabir Chamber",
      status: "Empty",
      transferHistory: [],
    },
    {
      id: 9n,
      bedNumber: "C-02",
      ward: "Chamber",
      floor: "Ground Floor",
      hospitalName: "Dr. Arman Kabir Chamber",
      status: "Occupied",
      patientName: "Sumaiya Begum",
      admissionDate: BigInt(Date.now() - 3600000) * 1_000_000n,
      transferHistory: [],
    },
    {
      id: 10n,
      bedNumber: "OBS-01",
      ward: "Observation",
      floor: "Floor 1",
      hospitalName: "Dr. Arman Kabir Chamber",
      status: "Empty",
      transferHistory: [],
    },
  ];
  store.beds = seeds as unknown[];
  saveClinicalStore(store);
}

// ── Status helpers ─────────────────────────────────────────────────────────────
type BedStatus = BedRecord["status"];

const STATUS_CONFIG: Record<
  BedStatus,
  { card: string; dot: string; badge: string; label: string }
> = {
  Empty: {
    card: "bg-emerald-50 border-emerald-300 text-emerald-900",
    dot: "bg-emerald-500",
    badge: "bg-emerald-100 text-emerald-700",
    label: "Available",
  },
  Occupied: {
    card: "bg-red-50 border-red-300 text-red-900",
    dot: "bg-red-500",
    badge: "bg-red-100 text-red-700",
    label: "Occupied",
  },
  Maintenance: {
    card: "bg-amber-50 border-amber-300 text-amber-900",
    dot: "bg-amber-500",
    badge: "bg-amber-100 text-amber-700",
    label: "Maintenance",
  },
  Reserved: {
    card: "bg-yellow-50 border-yellow-300 text-yellow-900",
    dot: "bg-yellow-500",
    badge: "bg-yellow-100 text-yellow-700",
    label: "Reserved",
  },
  Cleaning: {
    card: "bg-slate-100 border-slate-300 text-slate-700",
    dot: "bg-slate-400",
    badge: "bg-slate-200 text-slate-600",
    label: "Cleaning",
  },
};

function statusCfg(status: BedStatus) {
  return STATUS_CONFIG[status] ?? STATUS_CONFIG.Empty;
}

function formatTs(ts?: bigint) {
  if (!ts) return "—";
  return format(new Date(Number(ts / 1_000_000n)), "d MMM yyyy");
}

function daysAdmitted(admissionDate?: bigint): number {
  if (!admissionDate) return 0;
  return differenceInDays(
    new Date(),
    new Date(Number(admissionDate / 1_000_000n)),
  );
}

function isCurrentMonth(ts?: bigint): boolean {
  if (!ts) return false;
  const d = new Date(Number(ts / 1_000_000n));
  const now = new Date();
  return (
    d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear()
  );
}

const WARDS = [
  "General",
  "Medical",
  "Surgical",
  "ICU",
  "Pediatric",
  "Gynae",
  "Ortho",
  "Chamber",
  "Observation",
  "Other",
];

// ── Stats Panel ───────────────────────────────────────────────────────────────
function StatsPanel({ beds }: { beds: BedRecord[] }) {
  const total = beds.length;
  const occupied = beds.filter((b) => b.status === "Occupied").length;
  const available = beds.filter((b) => b.status === "Empty").length;
  const cleaning = beds.filter((b) => b.status === "Cleaning").length;
  const reserved = beds.filter((b) => b.status === "Reserved").length;
  const occupancyPct = total > 0 ? Math.round((occupied / total) * 100) : 0;
  const occupiedBeds = beds.filter((b) => b.status === "Occupied");
  const avgDays =
    occupiedBeds.length > 0
      ? Math.round(
          occupiedBeds.reduce(
            (sum, b) => sum + daysAdmitted(b.admissionDate),
            0,
          ) / occupiedBeds.length,
        )
      : 0;
  const thisMonthAdmissions = beds.filter((b) =>
    isCurrentMonth(b.admissionDate),
  ).length;

  const stats = [
    {
      label: "Occupancy",
      value: `${occupancyPct}%`,
      sub: `${occupied}/${total} beds`,
      color: "bg-red-50 border-red-200 text-red-800",
    },
    {
      label: "Available",
      value: available,
      sub: "ready to assign",
      color: "bg-emerald-50 border-emerald-200 text-emerald-800",
    },
    {
      label: "Cleaning",
      value: cleaning,
      sub: "needs ready mark",
      color: "bg-slate-100 border-slate-300 text-slate-700",
    },
    {
      label: "Reserved",
      value: reserved,
      sub: "pre-assigned",
      color: "bg-yellow-50 border-yellow-200 text-yellow-800",
    },
    {
      label: "Avg Stay",
      value: avgDays === 0 ? "—" : `${avgDays}d`,
      sub: "current patients",
      color: "bg-blue-50 border-blue-200 text-blue-800",
    },
    {
      label: "This Month",
      value: thisMonthAdmissions,
      sub: "new admissions",
      color: "bg-purple-50 border-purple-200 text-purple-800",
    },
  ];

  return (
    <div
      className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3"
      data-ocid="bed_management.stats.panel"
    >
      {stats.map((s) => (
        <div
          key={s.label}
          className={`rounded-xl border px-3 py-3 ${s.color}`}
          data-ocid="bed_management.card"
        >
          <p className="text-xl font-bold leading-tight">{s.value}</p>
          <p className="text-xs font-semibold mt-0.5">{s.label}</p>
          <p className="text-[10px] opacity-60 mt-0.5">{s.sub}</p>
        </div>
      ))}
    </div>
  );
}

// ── Status legend ─────────────────────────────────────────────────────────────
function StatusLegend() {
  return (
    <div className="flex flex-wrap gap-x-4 gap-y-1.5 text-xs">
      {(Object.keys(STATUS_CONFIG) as BedStatus[]).map((s) => (
        <span key={s} className="flex items-center gap-1.5">
          <span className={`w-2.5 h-2.5 rounded-full ${statusCfg(s).dot}`} />
          <span className="text-muted-foreground">{statusCfg(s).label}</span>
        </span>
      ))}
    </div>
  );
}

// ── Main Component ────────────────────────────────────────────────────────────
export default function BedManagement() {
  seedBedsIfEmpty();

  const { data: beds = [], refetch } = useGetAllBeds();
  const assignBed = useAssignBed();
  const createBed = useCreateBedRecord();

  const [searchQ, setSearchQ] = useState("");
  const [selectedHospital, setSelectedHospital] = useState<string>("All");
  const [selectedWard, setSelectedWard] = useState<string>("All");
  const [selectedFloor, setSelectedFloor] = useState<string>("All");
  const [selectedBed, setSelectedBed] = useState<BedRecord | null>(null);
  const [showAssignDialog, setShowAssignDialog] = useState(false);
  const [showTransferDialog, setShowTransferDialog] = useState(false);
  const [showAddBedDialog, setShowAddBedDialog] = useState(false);
  const [assignSearch, setAssignSearch] = useState("");
  const [transferBedId, setTransferBedId] = useState<string>("");
  const [transferReason, setTransferReason] = useState("");
  const [newBedNumber, setNewBedNumber] = useState("");
  const [newWard, setNewWard] = useState("General");
  const [newFloor, setNewFloor] = useState("");
  const [newHospitalName, setNewHospitalName] = useState("");

  const allPatients = useMemo(
    () => loadFromAllDoctorKeys<Patient>("patients"),
    [],
  );

  const hospitalNames = useMemo(() => {
    const names = new Set<string>();
    for (const b of beds) {
      if (b.hospitalName) names.add(b.hospitalName);
    }
    return Array.from(names).sort();
  }, [beds]);

  // Available wards for selected hospital
  const wardOptions = useMemo(() => {
    const src =
      selectedHospital === "All"
        ? beds
        : beds.filter((b) => b.hospitalName === selectedHospital);
    const wards = new Set<string>();
    for (const b of src) {
      if (b.ward) wards.add(b.ward);
    }
    return Array.from(wards).sort();
  }, [beds, selectedHospital]);

  // Available floors for selected hospital+ward
  const floorOptions = useMemo(() => {
    let src =
      selectedHospital === "All"
        ? beds
        : beds.filter((b) => b.hospitalName === selectedHospital);
    if (selectedWard !== "All")
      src = src.filter((b) => b.ward === selectedWard);
    const floors = new Set<string>();
    for (const b of src) {
      if (b.floor) floors.add(b.floor);
    }
    return Array.from(floors).sort();
  }, [beds, selectedHospital, selectedWard]);

  const filteredBeds = useMemo(() => {
    let result = beds;
    if (selectedHospital !== "All")
      result = result.filter((b) => b.hospitalName === selectedHospital);
    if (selectedWard !== "All")
      result = result.filter((b) => b.ward === selectedWard);
    if (selectedFloor !== "All")
      result = result.filter((b) => b.floor === selectedFloor);
    if (searchQ.trim()) {
      const q = searchQ.toLowerCase();
      result = result.filter(
        (b) =>
          b.bedNumber.toLowerCase().includes(q) ||
          b.ward.toLowerCase().includes(q) ||
          (b.hospitalName ?? "").toLowerCase().includes(q) ||
          (b.patientName ?? "").toLowerCase().includes(q) ||
          (b.floor ?? "").toLowerCase().includes(q),
      );
    }
    return result;
  }, [beds, selectedHospital, selectedWard, selectedFloor, searchQ]);

  // Group by hospital → ward
  const grouped = useMemo(() => {
    const byHospital: Record<string, Record<string, BedRecord[]>> = {};
    for (const b of filteredBeds) {
      const hn = b.hospitalName || "Unknown Hospital";
      const w = b.ward || "Other";
      if (!byHospital[hn]) byHospital[hn] = {};
      if (!byHospital[hn][w]) byHospital[hn][w] = [];
      byHospital[hn][w].push(b);
    }
    return byHospital;
  }, [filteredBeds]);

  // Available beds for transfer dialog (exclude Cleaning, Occupied, Maintenance)
  const transferableEmpty = useMemo(
    () => beds.filter((b) => b.status === "Empty" && b.id !== selectedBed?.id),
    [beds, selectedBed],
  );

  const matchedPatients = useMemo(() => {
    if (!assignSearch.trim()) return allPatients.slice(0, 8);
    const q = assignSearch.toLowerCase();
    return allPatients
      .filter(
        (p) =>
          p.fullName.toLowerCase().includes(q) ||
          ((p.registerNumber as string) ?? "").toLowerCase().includes(q),
      )
      .slice(0, 8);
  }, [assignSearch, allPatients]);

  // ── Actions ─────────────────────────────────────────────────────────────────

  function updateBedInStore(updater: (b: BedRecord) => BedRecord) {
    const store = getClinicalStore();
    const all = (store.beds as BedRecord[] | undefined) ?? [];
    store.beds = all.map(updater) as unknown[];
    saveClinicalStore(store);
    refetch();
  }

  function dischargeFromBed(bed: BedRecord) {
    updateBedInStore((b) =>
      b.id === bed.id
        ? {
            ...b,
            status: "Cleaning" as BedStatus,
            patientId: undefined,
            patientName: undefined,
            dischargeDate: BigInt(Date.now()) * 1_000_000n,
          }
        : b,
    );
    setSelectedBed(null);
    toast.success(`Patient discharged — Bed ${bed.bedNumber} set to Cleaning`);
  }

  function markBedReady(bed: BedRecord) {
    updateBedInStore((b) =>
      b.id === bed.id ? { ...b, status: "Empty" as BedStatus } : b,
    );
    setSelectedBed(null);
    toast.success(`Bed ${bed.bedNumber} is now Available`);
  }

  function markBedMaintenance(bed: BedRecord) {
    updateBedInStore((b) =>
      b.id === bed.id ? { ...b, status: "Maintenance" as BedStatus } : b,
    );
    setSelectedBed(null);
    toast.success("Bed marked for maintenance");
  }

  function markBedReserved(bed: BedRecord) {
    updateBedInStore((b) =>
      b.id === bed.id ? { ...b, status: "Reserved" as BedStatus } : b,
    );
    setSelectedBed(null);
    toast.success(`Bed ${bed.bedNumber} reserved`);
  }

  function transferPatient(
    fromBed: BedRecord,
    toBedId: bigint,
    reason: string,
  ) {
    const store = getClinicalStore();
    const all = (store.beds as BedRecord[] | undefined) ?? [];
    const toBed = all.find((b) => b.id === toBedId);
    if (!toBed || toBed.status !== "Empty") {
      toast.error("Target bed is not available");
      return;
    }
    const now = BigInt(Date.now()) * 1_000_000n;
    store.beds = all.map((b) => {
      if (b.id === fromBed.id)
        return {
          ...b,
          status: "Cleaning" as BedStatus,
          patientId: undefined,
          patientName: undefined,
          dischargeDate: now,
        };
      if (b.id === toBedId)
        return {
          ...b,
          status: "Occupied" as BedStatus,
          patientId: fromBed.patientId,
          patientName: fromBed.patientName,
          admissionDate: fromBed.admissionDate,
          transferHistory: [
            ...(b.transferHistory ?? []),
            {
              fromBed: fromBed.bedNumber,
              toBed: b.bedNumber,
              date: now,
              reason: reason || "Transfer",
            },
          ],
        };
      return b;
    }) as unknown[];
    saveClinicalStore(store);
    refetch();
    setShowTransferDialog(false);
    setTransferBedId("");
    setTransferReason("");
    setSelectedBed(null);
    toast.success(
      `Patient transferred to bed ${toBed.bedNumber}. Old bed set to Cleaning.`,
    );
  }

  // Reset ward/floor when hospital changes
  function handleHospitalChange(hn: string) {
    setSelectedHospital(hn);
    setSelectedWard("All");
    setSelectedFloor("All");
  }

  function handleWardChange(w: string) {
    setSelectedWard(w);
    setSelectedFloor("All");
  }

  return (
    <div
      className="p-4 sm:p-6 max-w-7xl mx-auto space-y-5"
      data-ocid="bed_management.page"
    >
      {/* ── Header ── */}
      <div className="flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
        <div>
          <h1 className="font-display text-2xl font-bold text-foreground flex items-center gap-2">
            <Bed className="w-6 h-6 text-teal-600" />
            Bed Management
          </h1>
          <p className="text-sm text-muted-foreground mt-0.5">
            Real-time occupancy, patient assignment, and transfer by
            hospital/ward/floor
          </p>
        </div>
        <Button
          onClick={() => setShowAddBedDialog(true)}
          className="gap-2 bg-teal-600 hover:bg-teal-700"
          data-ocid="bed_management.open_modal_button"
        >
          <Plus className="w-4 h-4" /> Add Bed
        </Button>
      </div>

      {/* ── Stats panel ── */}
      <StatsPanel
        beds={
          selectedHospital === "All"
            ? beds
            : beds.filter((b) => b.hospitalName === selectedHospital)
        }
      />

      {/* ── Legend ── */}
      <StatusLegend />

      {/* ── Filters ── */}
      <div className="flex flex-wrap gap-2 items-center">
        {/* Hospital filter */}
        <div
          className="flex flex-wrap gap-1.5"
          data-ocid="bed_management.hospital.tab"
        >
          {["All", ...hospitalNames].map((hn) => (
            <button
              key={hn}
              type="button"
              onClick={() => handleHospitalChange(hn)}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
                selectedHospital === hn
                  ? "bg-indigo-600 text-white border-indigo-600"
                  : "bg-card border-border text-muted-foreground hover:border-indigo-300 hover:text-indigo-700"
              }`}
              data-ocid={`bed_management.hospital_filter.${hn.toLowerCase().replace(/\s+/g, "_")}`}
            >
              {hn !== "All" && <Building2 className="w-3 h-3" />}
              {hn === "All" ? "All Hospitals" : hn}
            </button>
          ))}
        </div>

        {/* Ward filter (only if a hospital is selected) */}
        {wardOptions.length > 0 && (
          <div
            className="flex flex-wrap gap-1.5"
            data-ocid="bed_management.ward.tab"
          >
            <span className="flex items-center gap-1 text-xs text-muted-foreground px-1">
              <Layers className="w-3 h-3" /> Ward:
            </span>
            {["All", ...wardOptions].map((w) => (
              <button
                key={w}
                type="button"
                onClick={() => handleWardChange(w)}
                className={`px-2.5 py-1 rounded-full text-xs font-medium border transition-colors ${
                  selectedWard === w
                    ? "bg-teal-600 text-white border-teal-600"
                    : "bg-card border-border text-muted-foreground hover:border-teal-300 hover:text-teal-700"
                }`}
                data-ocid={`bed_management.ward_filter.${w.toLowerCase().replace(/\s+/g, "_")}`}
              >
                {w === "All" ? "All Wards" : w}
              </button>
            ))}
          </div>
        )}

        {/* Floor filter */}
        {floorOptions.length > 0 && (
          <div
            className="flex flex-wrap gap-1.5"
            data-ocid="bed_management.floor.tab"
          >
            <span className="flex items-center gap-1 text-xs text-muted-foreground px-1">
              <Sparkles className="w-3 h-3" /> Floor:
            </span>
            {["All", ...floorOptions].map((f) => (
              <button
                key={f}
                type="button"
                onClick={() => setSelectedFloor(f)}
                className={`px-2.5 py-1 rounded-full text-xs font-medium border transition-colors ${
                  selectedFloor === f
                    ? "bg-purple-600 text-white border-purple-600"
                    : "bg-card border-border text-muted-foreground hover:border-purple-300 hover:text-purple-700"
                }`}
                data-ocid={`bed_management.floor_filter.${f.toLowerCase().replace(/\s+/g, "_")}`}
              >
                {f === "All" ? "All Floors" : f}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* ── Search ── */}
      <div className="relative max-w-xs">
        <Search className="absolute left-3 top-2.5 w-4 h-4 text-muted-foreground" />
        <Input
          placeholder="Search bed, ward, floor, patient..."
          value={searchQ}
          onChange={(e) => setSearchQ(e.target.value)}
          className="pl-9"
          data-ocid="bed_management.search_input"
        />
      </div>

      {/* ── Bed grid grouped by Hospital → Ward ── */}
      {filteredBeds.length === 0 ? (
        <div
          className="text-center py-20"
          data-ocid="bed_management.empty_state"
        >
          <Bed className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
          <p className="text-muted-foreground">No beds found</p>
        </div>
      ) : (
        <div className="space-y-8">
          {Object.entries(grouped).map(([hospitalName, wardMap]) => (
            <section
              key={hospitalName}
              data-ocid={`bed_management.hospital.${hospitalName.toLowerCase().replace(/\s+/g, "_")}`}
            >
              {/* Hospital header */}
              <div className="flex items-center gap-2 mb-4">
                <Building2 className="w-4 h-4 text-indigo-600" />
                <h2 className="font-bold text-base text-indigo-700">
                  {hospitalName}
                </h2>
                <span className="text-xs text-muted-foreground">
                  ({Object.values(wardMap).flat().length} bed
                  {Object.values(wardMap).flat().length !== 1 ? "s" : ""})
                </span>
                <div className="flex-1 h-px bg-indigo-100 ml-1" />
              </div>

              {/* Wards within hospital */}
              <div className="space-y-5">
                {Object.entries(wardMap).map(([wardName, wardBeds]) => (
                  <div
                    key={wardName}
                    className="pl-1"
                    data-ocid={`bed_management.ward.${wardName.toLowerCase().replace(/\s+/g, "_")}`}
                  >
                    {/* Ward sub-header */}
                    <div className="flex items-center gap-2 mb-2.5">
                      <div className="w-1 h-5 bg-teal-400 rounded-full" />
                      <span className="text-sm font-semibold text-teal-700">
                        {wardName}
                      </span>
                      {wardBeds[0]?.floor && (
                        <span className="text-xs text-muted-foreground flex items-center gap-1">
                          <Layers className="w-3 h-3" /> {wardBeds[0].floor}
                        </span>
                      )}
                      <span className="text-xs text-muted-foreground">
                        ({wardBeds.length} bed{wardBeds.length !== 1 ? "s" : ""}
                        )
                      </span>
                    </div>

                    {/* Bed cards */}
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3">
                      {wardBeds.map((bed) => {
                        const cfg = statusCfg(bed.status);
                        return (
                          <button
                            key={bed.id.toString()}
                            type="button"
                            onClick={() => setSelectedBed(bed)}
                            className={`rounded-xl border-2 p-3 text-left transition-all hover:shadow-md hover:-translate-y-0.5 ${cfg.card}`}
                            data-ocid={`bed_management.item.${bed.bedNumber}`}
                          >
                            <div className="flex items-start justify-between mb-1.5">
                              <div className="flex items-center gap-1.5">
                                <span
                                  className={`w-2 h-2 rounded-full flex-shrink-0 ${cfg.dot}`}
                                />
                                <span className="font-bold text-sm">
                                  {bed.bedNumber}
                                </span>
                              </div>
                              {bed.status === "Occupied" && (
                                <Users className="w-3.5 h-3.5 opacity-60" />
                              )}
                            </div>
                            {bed.status === "Occupied" && bed.patientName && (
                              <p className="text-xs font-semibold truncate mb-1">
                                {bed.patientName}
                              </p>
                            )}
                            {bed.status === "Occupied" && bed.admissionDate && (
                              <p className="text-[10px] opacity-60">
                                {daysAdmitted(bed.admissionDate)}d ago
                              </p>
                            )}
                            <Badge
                              className={`text-[10px] mt-1 border-0 px-1.5 py-0 ${cfg.badge}`}
                            >
                              {cfg.label}
                            </Badge>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}

      {/* ── Bed Detail Dialog ── */}
      <Dialog
        open={!!selectedBed}
        onOpenChange={(open) => !open && setSelectedBed(null)}
      >
        <DialogContent className="max-w-md" data-ocid="bed_management.dialog">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Bed className="w-5 h-5 text-teal-600" />
              Bed {selectedBed?.bedNumber} — {selectedBed?.ward}
            </DialogTitle>
          </DialogHeader>
          {selectedBed &&
            (() => {
              const cfg = statusCfg(selectedBed.status);
              return (
                <div className="space-y-4">
                  {/* Hospital + floor */}
                  <div className="flex flex-wrap gap-2">
                    {selectedBed.hospitalName && (
                      <span className="flex items-center gap-1.5 text-xs text-indigo-700 bg-indigo-50 border border-indigo-100 rounded-lg px-3 py-1.5">
                        <Building2 className="w-3.5 h-3.5" />
                        {selectedBed.hospitalName}
                      </span>
                    )}
                    {selectedBed.floor && (
                      <span className="flex items-center gap-1.5 text-xs text-purple-700 bg-purple-50 border border-purple-100 rounded-lg px-3 py-1.5">
                        <Layers className="w-3.5 h-3.5" />
                        {selectedBed.floor}
                      </span>
                    )}
                  </div>

                  {/* Status card */}
                  <div className={`rounded-lg border px-4 py-3 ${cfg.card}`}>
                    <div className="flex items-center gap-2 mb-1">
                      <span className={`w-2.5 h-2.5 rounded-full ${cfg.dot}`} />
                      <span className="font-semibold">{cfg.label}</span>
                    </div>
                    {selectedBed.patientName && (
                      <p className="font-bold text-sm">
                        {selectedBed.patientName}
                      </p>
                    )}
                    {selectedBed.admissionDate && (
                      <p className="text-xs opacity-70 mt-0.5">
                        Admitted: {formatTs(selectedBed.admissionDate)}
                        {selectedBed.status === "Occupied" &&
                          ` (${daysAdmitted(selectedBed.admissionDate)} day${daysAdmitted(selectedBed.admissionDate) !== 1 ? "s" : ""})`}
                      </p>
                    )}
                  </div>

                  {/* Cleaning notice */}
                  {selectedBed.status === "Cleaning" && (
                    <div className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-xs text-slate-600 flex items-start gap-2">
                      <span className="mt-0.5">🧹</span>
                      <span>
                        This bed is being cleaned after a patient discharge or
                        transfer. Mark it as Ready when cleaning is complete to
                        make it Available again.
                      </span>
                    </div>
                  )}

                  {/* Transfer history */}
                  {selectedBed.transferHistory?.length > 0 && (
                    <div>
                      <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide mb-2">
                        Transfer History
                      </p>
                      <ScrollArea className="h-28">
                        <div className="space-y-1.5">
                          {selectedBed.transferHistory.map((t, i) => (
                            <div
                              key={`${t.fromBed}-${t.toBed}-${i}`}
                              className="bg-muted/40 rounded px-2.5 py-1.5 text-xs"
                            >
                              <span className="font-medium">
                                {t.fromBed} → {t.toBed}
                              </span>{" "}
                              <span className="text-muted-foreground">
                                on {formatTs(t.date)}
                              </span>
                              {t.reason && (
                                <p className="text-muted-foreground italic">
                                  {t.reason}
                                </p>
                              )}
                            </div>
                          ))}
                        </div>
                      </ScrollArea>
                    </div>
                  )}

                  {/* Action buttons */}
                  <div className="flex flex-wrap gap-2">
                    {/* Empty: assign patient or reserve or maintenance */}
                    {selectedBed.status === "Empty" && (
                      <>
                        <Button
                          size="sm"
                          className="gap-1.5 bg-teal-600 hover:bg-teal-700"
                          onClick={() => setShowAssignDialog(true)}
                          data-ocid="bed_management.assign_button"
                        >
                          <Plus className="w-3.5 h-3.5" /> Assign Patient
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="gap-1.5 border-yellow-300 text-yellow-700 hover:bg-yellow-50"
                          onClick={() => markBedReserved(selectedBed)}
                          data-ocid="bed_management.reserve_button"
                        >
                          Reserve
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="gap-1.5 border-amber-300 text-amber-700 hover:bg-amber-50"
                          onClick={() => markBedMaintenance(selectedBed)}
                          data-ocid="bed_management.maintenance_button"
                        >
                          Maintenance
                        </Button>
                      </>
                    )}

                    {/* Occupied: transfer or discharge */}
                    {selectedBed.status === "Occupied" && (
                      <>
                        <Button
                          size="sm"
                          variant="outline"
                          className="gap-1.5 border-blue-300 text-blue-700 hover:bg-blue-50"
                          onClick={() => setShowTransferDialog(true)}
                          data-ocid="bed_management.transfer_button"
                        >
                          <ArrowLeftRight className="w-3.5 h-3.5" /> Transfer
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="gap-1.5 border-red-300 text-red-700 hover:bg-red-50"
                          onClick={() => dischargeFromBed(selectedBed)}
                          data-ocid="bed_management.discharge_button"
                        >
                          <LogOut className="w-3.5 h-3.5" /> Discharge
                        </Button>
                      </>
                    )}

                    {/* Cleaning: mark ready */}
                    {selectedBed.status === "Cleaning" && (
                      <Button
                        size="sm"
                        className="gap-1.5 bg-emerald-600 hover:bg-emerald-700"
                        onClick={() => markBedReady(selectedBed)}
                        data-ocid="bed_management.mark_ready_button"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" /> Mark Ready
                        (Available)
                      </Button>
                    )}

                    {/* Maintenance: mark available */}
                    {selectedBed.status === "Maintenance" && (
                      <Button
                        size="sm"
                        variant="outline"
                        className="gap-1.5 border-emerald-300 text-emerald-700 hover:bg-emerald-50"
                        onClick={() => markBedReady(selectedBed)}
                        data-ocid="bed_management.mark_available_button"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" /> Mark Available
                      </Button>
                    )}

                    {/* Reserved: make available or assign */}
                    {selectedBed.status === "Reserved" && (
                      <>
                        <Button
                          size="sm"
                          className="gap-1.5 bg-teal-600 hover:bg-teal-700"
                          onClick={() => setShowAssignDialog(true)}
                          data-ocid="bed_management.assign_button"
                        >
                          <Plus className="w-3.5 h-3.5" /> Assign Patient
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="gap-1.5 border-emerald-300 text-emerald-700 hover:bg-emerald-50"
                          onClick={() => markBedReady(selectedBed)}
                          data-ocid="bed_management.unreserve_button"
                        >
                          <CheckCircle2 className="w-3.5 h-3.5" /> Unreserve
                        </Button>
                      </>
                    )}
                  </div>
                </div>
              );
            })()}
        </DialogContent>
      </Dialog>

      {/* ── Assign Patient Dialog ── */}
      <Dialog open={showAssignDialog} onOpenChange={setShowAssignDialog}>
        <DialogContent
          className="max-w-sm"
          data-ocid="bed_management.assign.dialog"
        >
          <DialogHeader>
            <DialogTitle>
              Assign Patient to Bed {selectedBed?.bedNumber}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            <Input
              placeholder="Search patient by name or reg no..."
              value={assignSearch}
              onChange={(e) => setAssignSearch(e.target.value)}
              data-ocid="bed_management.assign.search_input"
            />
            <ScrollArea className="h-48 border rounded-lg">
              <div className="p-2 space-y-1">
                {matchedPatients.length === 0 && (
                  <p className="text-sm text-muted-foreground p-3 text-center">
                    No patients found
                  </p>
                )}
                {matchedPatients.map((p) => (
                  <button
                    key={p.id.toString()}
                    type="button"
                    className="w-full text-left px-3 py-2 rounded-lg hover:bg-muted/50 transition-colors"
                    onClick={() => {
                      if (!selectedBed) return;
                      assignBed.mutate(
                        {
                          bedId: selectedBed.id,
                          patientId: p.id,
                          patientName: p.fullName,
                        },
                        {
                          onSuccess: () => {
                            toast.success(
                              `Assigned ${p.fullName} to ${selectedBed.bedNumber}`,
                            );
                            setShowAssignDialog(false);
                            setAssignSearch("");
                            setSelectedBed(null);
                          },
                        },
                      );
                    }}
                    data-ocid={`bed_management.assign.item.${p.registerNumber}`}
                  >
                    <p className="font-medium text-sm">{p.fullName}</p>
                    <p className="text-xs text-muted-foreground font-mono">
                      {(p.registerNumber as string) || String(p.id)}
                    </p>
                  </button>
                ))}
              </div>
            </ScrollArea>
          </div>
        </DialogContent>
      </Dialog>

      {/* ── Transfer Dialog ── */}
      <Dialog open={showTransferDialog} onOpenChange={setShowTransferDialog}>
        <DialogContent
          className="max-w-sm"
          data-ocid="bed_management.transfer.dialog"
        >
          <DialogHeader>
            <DialogTitle>
              Transfer Patient from {selectedBed?.bedNumber}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            <div className="bg-amber-50 border border-amber-200 rounded-lg px-3 py-2 text-xs text-amber-700">
              After transfer, bed <strong>{selectedBed?.bedNumber}</strong> will
              be set to <strong>Cleaning</strong> status.
            </div>
            <div className="space-y-1.5">
              <Label>Transfer to Bed</Label>
              <select
                className="w-full border border-input rounded-md px-3 py-2 text-sm bg-background"
                value={transferBedId}
                onChange={(e) => setTransferBedId(e.target.value)}
                data-ocid="bed_management.transfer.select"
              >
                <option value="">Select available bed...</option>
                {transferableEmpty.map((b) => (
                  <option key={b.id.toString()} value={b.id.toString()}>
                    {b.bedNumber} ({b.ward}
                    {b.floor ? `, ${b.floor}` : ""}) — {b.hospitalName}
                  </option>
                ))}
              </select>
              {transferableEmpty.length === 0 && (
                <p className="text-xs text-destructive">
                  No available beds. A bed must be in Available status to
                  receive a transfer.
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label>Reason for Transfer</Label>
              <Input
                placeholder="e.g. Bed maintenance, Transfer to ICU"
                value={transferReason}
                onChange={(e) => setTransferReason(e.target.value)}
                data-ocid="bed_management.transfer.input"
              />
            </div>
            <div className="flex gap-2 justify-end">
              <Button
                variant="outline"
                onClick={() => setShowTransferDialog(false)}
                data-ocid="bed_management.transfer.cancel_button"
              >
                Cancel
              </Button>
              <Button
                disabled={!transferBedId}
                onClick={() => {
                  if (!selectedBed || !transferBedId) return;
                  transferPatient(
                    selectedBed,
                    BigInt(transferBedId),
                    transferReason,
                  );
                }}
                data-ocid="bed_management.transfer.submit_button"
              >
                Transfer
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* ── Add Bed Dialog ── */}
      <Dialog open={showAddBedDialog} onOpenChange={setShowAddBedDialog}>
        <DialogContent
          className="max-w-sm"
          data-ocid="bed_management.add.dialog"
        >
          <DialogHeader>
            <DialogTitle>Add New Bed</DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            <div className="space-y-1.5">
              <Label>Hospital Name *</Label>
              <Input
                placeholder="e.g. Dhaka Medical College Hospital"
                value={newHospitalName}
                onChange={(e) => setNewHospitalName(e.target.value)}
                list="hospital-suggestions"
                data-ocid="bed_management.add.hospital_input"
              />
              <datalist id="hospital-suggestions">
                {hospitalNames.map((hn) => (
                  <option key={hn} value={hn} />
                ))}
              </datalist>
            </div>
            <div className="space-y-1.5">
              <Label>Bed Number *</Label>
              <Input
                placeholder="e.g. A-01, ICU-03"
                value={newBedNumber}
                onChange={(e) => setNewBedNumber(e.target.value)}
                data-ocid="bed_management.add.input"
              />
            </div>
            <div className="space-y-1.5">
              <Label>Ward *</Label>
              <select
                className="w-full border border-input rounded-md px-3 py-2 text-sm bg-background"
                value={newWard}
                onChange={(e) => setNewWard(e.target.value)}
                data-ocid="bed_management.add.select"
              >
                {WARDS.map((w) => (
                  <option key={w} value={w}>
                    {w}
                  </option>
                ))}
              </select>
            </div>
            <div className="space-y-1.5">
              <Label>Floor / Level</Label>
              <Input
                placeholder="e.g. Ground Floor, Floor 1, ICU Level"
                value={newFloor}
                onChange={(e) => setNewFloor(e.target.value)}
                data-ocid="bed_management.add.floor_input"
              />
            </div>
            <div className="flex gap-2 justify-end">
              <Button
                variant="outline"
                onClick={() => {
                  setShowAddBedDialog(false);
                  setNewBedNumber("");
                  setNewWard("General");
                  setNewHospitalName("");
                  setNewFloor("");
                }}
                data-ocid="bed_management.add.cancel_button"
              >
                Cancel
              </Button>
              <Button
                disabled={!newBedNumber.trim() || !newHospitalName.trim()}
                onClick={() => {
                  createBed.mutate(
                    {
                      bedNumber: newBedNumber.trim(),
                      ward: newWard,
                      hospitalName: newHospitalName.trim(),
                      floor: newFloor.trim() || undefined,
                    },
                    {
                      onSuccess: () => {
                        toast.success("Bed added");
                        setShowAddBedDialog(false);
                        setNewBedNumber("");
                        setNewWard("General");
                        setNewHospitalName("");
                        setNewFloor("");
                      },
                    },
                  );
                }}
                data-ocid="bed_management.add.submit_button"
              >
                Add Bed
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
