export type RiskLevel = 'Low' | 'Moderate' | 'High' | 'Critical';

export type MapMode = 'risk' | 'vaccination';

export interface AssignedVetTeam {
  id: string;
  leadVet: string;
  mobileUnit: string;
  contact: string;
  status: 'Field Deployed' | 'On Standby' | 'En Route';
}

export interface SyndromicReport {
  date: string;
  village: string;
  syndrome: string;
  cattleAffected: number;
}

export interface DistrictRiskData {
  id: string;
  districtName: string;
  marathiName?: string;
  division: string;
  riskPercentage: number; // 0-100
  riskLevel: RiskLevel;
  primaryDisease: string;
  activeCases: number;
  mortalityReports: number;
  vaccinationCoverage: number; // percentage e.g. 61.2
  affectedVillages: number;
  totalLivestock?: number;
  trend: string; // e.g. '+16%', '-8%'
  riskExplanation: string;
  recommendedAction: string;
  vaccinationGap: string;
  whyAtRisk: string[];
  assignedTeams: AssignedVetTeam[];
  recentReports: SyndromicReport[];
  coordinates: [number, number]; // [lat, lng]
}

export interface MapFilterState {
  searchQuery: string;
  selectedDisease: string;
  selectedRiskLevel: string;
  selectedTimeframe: string;
  mapMode: MapMode;
}
