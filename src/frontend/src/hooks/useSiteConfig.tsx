import { useCallback, useState, useEffect } from "react";
import { supabase, getSupabaseSessionToken } from "../lib/supabase";
import { saveFrontPageContentWithSync } from "../lib/hybridStorage";

export interface SocialLink {
  label: string;
  url: string;
  icon: string;
}

export interface EmergencyContact {
  doctorName: string;
  whatsappNumber: string;
  prefilledMessage: string;
}

export interface HeroSection {
  taglineEn: string;
  taglineBn: string;
  subheadingEn: string;
  subheadingBn: string;
  heroTaglineEn?: string;
  heroTaglineBn?: string;
  heroDescriptionEn?: string;
  heroDescriptionBn?: string;
  cta1Label: string;
  cta2Label: string;
}

export interface AboutSection {
  visible: boolean;
  clinicNameEn: string;
  clinicNameBn: string;
  descriptionEn: string;
  descriptionBn: string;
  yearsExperience: number;
  patientCount: string;
  doctorCount: number;
  specialties: string[];
  affiliations: string[];
}

export interface FooterSection {
  addressEn: string;
  addressBn: string;
  phone: string;
  email: string;
  openingHours: string;
  copyrightText: string;
  socialLinks: SocialLink[];
}

export interface SiteConfig {
  heroSection: HeroSection;
  aboutSection: AboutSection;
  footerSection: FooterSection;
  emergencyContacts: EmergencyContact[];
}

export const DEFAULT_SITE_CONFIG: SiteConfig = {
  heroSection: {
    taglineEn: "Dr. Arman Kabir's Care",
    taglineBn: "ডা. আরমান কবিরের চেম্বার",
    subheadingEn: "Advanced Healthcare With a Human Touch",
    subheadingBn: "মানবিক স্পর্শে উন্নত স্বাস্থ্যসেবা",
    heroTaglineEn: "Healing with Trust and Compassion",
    heroTaglineBn: "বিশ্বাস ও সহানুভূতির সাথে নিরাময়",
    heroDescriptionEn:
      "Expert diagnosis, compassionate treatment, and trusted care for every stage of life.",
    heroDescriptionBn:
      "জীবনের প্রতিটি পর্যায়ে বিশেষজ্ঞ রোগ নির্ণয়, সহানুভূতিশীল চিকিৎসা ও বিশ্বস্ত যত্ন।",
    cta1Label: "Book Appointment",
    cta2Label: "Emergency",
  },
  aboutSection: {
    visible: true,
    clinicNameEn: "Dr. Arman Kabir's Care",
    clinicNameBn: "ডা. আরমান কবিরের চেম্বার",
    descriptionEn:
      "Comprehensive patient management and medical education serving patients and students across Bangladesh.",
    descriptionBn:
      "বাংলাদেশ জুড়ে রোগী ও শিক্ষার্থীদের জন্য পূর্ণাঙ্গ রোগী ব্যবস্থাপনা ও মেডিকেল শিক্ষা।",
    yearsExperience: 10,
    patientCount: "500+",
    doctorCount: 2,
    specialties: [
      "Internal Medicine",
      "Respiratory Medicine",
      "Diabetes & Endocrinology",
      "General Practice",
    ],
    affiliations: [
      "BSMMU",
      "DMCH",
      "Dhaka Medical College",
      "National Institute of Diseases of Chest & Hospital",
    ],
  },
  footerSection: {
    addressEn: "Dhaka, Bangladesh",
    addressBn: "ঢাকা, বাংলাদেশ",
    phone: "+880-1751-959262",
    email: "dr.armankabir011@gmail.com",
    openingHours: "Sat–Thu: 9 AM – 8 PM",
    copyrightText: "Dr. Arman Kabir's Care. All rights reserved.",
    socialLinks: [],
  },
  emergencyContacts: [
    {
      doctorName: "Dr. Arman Kabir",
      whatsappNumber: "8801751959262",
      prefilledMessage: "Hello Dr. Arman, I need an emergency consultation.",
    },
    {
      doctorName: "Dr. Samia Shikder",
      whatsappNumber: "8801957212210",
      prefilledMessage: "Hello Dr. Samia, I need an emergency consultation.",
    },
  ],
};

function deepMerge<T extends object>(base: T, overrides: Partial<T>): T {
  const result = { ...base } as T;
  for (const key of Object.keys(overrides) as (keyof T)[]) {
    const val = overrides[key];
    if (Array.isArray(val)) {
      (result as Record<string, unknown>)[key as string] = val;
    } else if (
      val !== null &&
      val !== undefined &&
      typeof val === "object" &&
      typeof result[key] === "object" &&
      result[key] !== null &&
      !Array.isArray(result[key])
    ) {
      (result as Record<string, unknown>)[key as string] = deepMerge(
        result[key] as object,
        val as object,
      );
    } else if (val !== undefined) {
      (result as Record<string, unknown>)[key as string] = val;
    }
  }
  return result;
}

async function fetchConfigFromSupabase(): Promise<Partial<SiteConfig> | null> {
  try {
    const { data, error } = await supabase
      .from("site_config")
      .select("*")
      .single();

    if (error) {
      console.warn("[sync] Failed to fetch config from Supabase:", error);
      return null;
    }

    if (!data) return null;

    // Transform Supabase response to SiteConfig format
    return {
      heroSection: data.hero_section || undefined,
      aboutSection: data.about_section || undefined,
      footerSection: data.footer_section || undefined,
      emergencyContacts: data.emergency_contacts || undefined,
    } as Partial<SiteConfig>;
  } catch (err) {
    console.warn("[sync] Failed to fetch config from Supabase:", err);
    return null;
  }
}

async function syncConfigToSupabase(cfg: SiteConfig): Promise<void> {
  try {
    const token = await getSupabaseSessionToken();
    if (!token) {
      console.warn(
        "[sync] No auth token available; Supabase sync is skipped until login.",
      );
      return;
    }

    const { error } = await supabase
      .from("site_config")
      .upsert(
        {
          id: 1, // assuming single config record
          hero_section: cfg.heroSection,
          about_section: cfg.aboutSection,
          footer_section: cfg.footerSection,
          emergency_contacts: cfg.emergencyContacts,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "id" },
      );

    if (error) {
      throw error;
    }
  } catch (err) {
    console.warn("[sync] Failed to sync config to Supabase:", err);
  }
}

// Helper: resolve canister actor at call time (avoids import cycle)
function resolveActor(): unknown | null {
  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const mod = require("../hooks/useQueries") as {
      getCanisterActor?: () => unknown;
    };
    return mod.getCanisterActor?.() ?? null;
  } catch {
    return null;
  }
}

export function useSiteConfig() {
  const [config, setConfig] = useState<SiteConfig>(DEFAULT_SITE_CONFIG);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // On mount, fetch from Supabase
  useEffect(() => {
    const syncFromSupabase = async () => {
      try {
        setIsLoading(true);
        setError(null);

        const supabaseConfig = await fetchConfigFromSupabase();

        if (supabaseConfig) {
          const merged = deepMerge(DEFAULT_SITE_CONFIG, supabaseConfig);
          setConfig(merged);
        } else {
          setConfig(DEFAULT_SITE_CONFIG);
        }
      } catch (err) {
        console.error("[sync] Error loading config from Supabase:", err);
        setError(err instanceof Error ? err : new Error("Unknown error"));
        setConfig(DEFAULT_SITE_CONFIG);
      } finally {
        setIsLoading(false);
      }
    };

    syncFromSupabase();
  }, []);

  const updateHero = useCallback((hero: Partial<HeroSection>) => {
    setConfig((prev) => {
      const next = { ...prev, heroSection: { ...prev.heroSection, ...hero } };
      void syncConfigToSupabase(next);
      void saveFrontPageContentWithSync(resolveActor());
      return next;
    });
  }, []);

  const updateAbout = useCallback((about: Partial<AboutSection>) => {
    setConfig((prev) => {
      const next = {
        ...prev,
        aboutSection: { ...prev.aboutSection, ...about },
      };
      void syncConfigToSupabase(next);
      void saveFrontPageContentWithSync(resolveActor());
      return next;
    });
  }, []);

  const updateFooter = useCallback((footer: Partial<FooterSection>) => {
    setConfig((prev) => {
      const next = {
        ...prev,
        footerSection: { ...prev.footerSection, ...footer },
      };
      void syncConfigToSupabase(next);
      void saveFrontPageContentWithSync(resolveActor());
      return next;
    });
  }, []);

  const updateEmergencyContacts = useCallback(
    (contacts: EmergencyContact[]) => {
      setConfig((prev) => {
        const next = { ...prev, emergencyContacts: contacts };
        void syncConfigToSupabase(next);
        void saveFrontPageContentWithSync(resolveActor());
        return next;
      });
    },
    [],
  );

  const resetSection = useCallback((section: keyof SiteConfig) => {
    setConfig((prev) => {
      const next = {
        ...prev,
        [section]: DEFAULT_SITE_CONFIG[section],
      };
      void syncConfigToSupabase(next);
      void saveFrontPageContentWithSync(resolveActor());
      return next;
    });
  }, []);

  return {
    config,
    isLoading,
    error,
    updateHero,
    updateAbout,
    updateFooter,
    updateEmergencyContacts,
    resetSection,
  };
}
