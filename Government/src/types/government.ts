export type RiskLevel = 'Low' | 'Moderate' | 'High' | 'Critical';

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

export interface DistrictData {
  id: string;
  name: string;
  marathiName?: string;
  division: 'Pune' | 'Konkan' | 'Nashik' | 'Chhatrapati Sambhajinagar' | 'Amravati' | 'Nagpur';
  riskScore: number; // 0–100
  riskLevel: RiskLevel;
  suspectedDisease: string;
  activeCases: number;
  mortality: number;
  vaccinationCoverage: number; // percentage e.g. 64.2
  affectedVillages: number;
  totalLivestock: number;
  trend: string; // e.g. '+16%', '-4%'
  riskSummary: string;
  whyAtRisk: string[];
  recommendedAction: string;
  vaccinationGap: string;
  assignedTeams: AssignedVetTeam[];
  recentReports: SyndromicReport[];
  // SVG Map Geometry
  cx: number;
  cy: number;
  svgPath: string;
}

export interface DiseaseOutbreak {
  id: string;
  diseaseName: string;
  affectedDistrict: string;
  riskLevel: RiskLevel;
  cases: number;
  trendPercentage: number;
  detectionDate: string;
  recommendedNextAction: string;
  pathogenType: 'Viral' | 'Bacterial' | 'Parasitic';
}

export interface VillageCampaignItem {
  name: string;
  target: number;
  vaccinated: number;
  status: 'Completed' | 'In Progress' | 'Low Coverage';
  assignedTeam: string | null;
}

export interface VaccinationCampaign {
  id: string;
  name: string;
  disease: string;
  targetDistrict: string;
  blocks: string[];
  targetVillages: string;
  animalSpecies: string;
  startDate: string;
  endDate: string;
  targetAnimals: number;
  vaccinatedAnimals: number;
  coveragePercentage: number;
  status: 'Active' | 'Scheduled' | 'Review' | 'Completed';
  priority: 'Critical' | 'High' | 'Medium';
  targetVillagesCount: number;
  completedVillagesCount: number;
  pendingVillagesCount: number;
  villages?: VillageCampaignItem[];
}

export type ResponseStatus =
  | 'New'
  | 'Assigned'
  | 'In Progress'
  | 'Awaiting Lab Result'
  | 'Completed';

export interface ResponseTask {
  id: string;
  title: string;
  district: string;
  village: string;
  diseaseConcern: string;
  priority: 'Critical' | 'High' | 'Medium' | 'Monitoring';
  assignedTeam: string;
  dueDate: string;
  status: ResponseStatus;
  notes?: string;
  reportedDate: string;
}

export interface GovtAlert {
  id: string;
  type: 'Outbreak' | 'Risk Escalation' | 'Campaign Due' | 'Lab Confirmation' | 'Advisory';
  title: string;
  district: string;
  time: string;
  priority: 'Critical' | 'High' | 'Medium';
  isRead: boolean;
  resolved: boolean;
  actionText: string;
  description: string;
}

export interface ReportSummary {
  id: string;
  title: string;
  category: 'Disease Trends' | 'District Risk Summary' | 'Vaccination Coverage' | 'Mortality Reports' | 'Response Performance' | 'Campaign Performance';
  generatedDate: string;
  recordsCount: number;
  status: 'Ready' | 'Generating';
  fileSize: string;
  period: string;
}

export interface OutbreakTrendPoint {
  date: string;
  FMD: number;
  LSD: number;
  Brucellosis: number;
  Anthrax: number;
  PPR: number;
}
