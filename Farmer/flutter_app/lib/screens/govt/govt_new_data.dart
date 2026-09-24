// Smart Livestock — New Government Module Data
// Ported from Government/src/data/* (React/TypeScript version)

// ─── Types ────────────────────────────────────────────────────────────────────

enum RiskLevel { low, moderate, high, critical }

String riskLevelLabel(RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return 'Low';
    case RiskLevel.moderate:
      return 'Moderate';
    case RiskLevel.high:
      return 'High';
    case RiskLevel.critical:
      return 'Critical';
  }
}

class AssignedVetTeam {
  final String id;
  final String leadVet;
  final String mobileUnit;
  final String contact;
  final String status;
  const AssignedVetTeam({
    required this.id,
    required this.leadVet,
    required this.mobileUnit,
    required this.contact,
    required this.status,
  });
}

class SyndromicReport {
  final String date;
  final String village;
  final String syndrome;
  final int cattleAffected;
  const SyndromicReport({
    required this.date,
    required this.village,
    required this.syndrome,
    required this.cattleAffected,
  });
}

class DistrictData {
  final String id;
  final String name;
  final String marathiName;
  final String division;
  final int riskScore;
  final RiskLevel riskLevel;
  final String suspectedDisease;
  final int activeCases;
  final int mortality;
  final double vaccinationCoverage;
  final int affectedVillages;
  final int totalLivestock;
  final String trend;
  final String riskSummary;
  final List<String> whyAtRisk;
  final String recommendedAction;
  final String vaccinationGap;
  final List<AssignedVetTeam> assignedTeams;
  final List<SyndromicReport> recentReports;

  const DistrictData({
    required this.id,
    required this.name,
    required this.marathiName,
    required this.division,
    required this.riskScore,
    required this.riskLevel,
    required this.suspectedDisease,
    required this.activeCases,
    required this.mortality,
    required this.vaccinationCoverage,
    required this.affectedVillages,
    required this.totalLivestock,
    required this.trend,
    required this.riskSummary,
    required this.whyAtRisk,
    required this.recommendedAction,
    required this.vaccinationGap,
    required this.assignedTeams,
    required this.recentReports,
  });
}

class GovtAlert {
  final String id;
  final String type;
  final String title;
  final String district;
  final String time;
  final String priority;
  bool isRead;
  bool resolved;
  final String actionText;
  final String description;

  GovtAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.district,
    required this.time,
    required this.priority,
    required this.isRead,
    required this.resolved,
    required this.actionText,
    required this.description,
  });
}

class VillageCampaignItem {
  final String name;
  final int target;
  final int vaccinated;
  final String status;
  final String? assignedTeam;
  const VillageCampaignItem({
    required this.name,
    required this.target,
    required this.vaccinated,
    required this.status,
    this.assignedTeam,
  });
}

class VaccinationCampaign {
  final String id;
  final String name;
  final String disease;
  final String targetDistrict;
  final List<String> blocks;
  final String animalSpecies;
  final String startDate;
  final String endDate;
  final int targetAnimals;
  final int vaccinatedAnimals;
  final double coveragePercentage;
  String status;
  final String priority;
  final int targetVillagesCount;
  final int completedVillagesCount;
  final int pendingVillagesCount;
  final List<VillageCampaignItem> villages;

  VaccinationCampaign({
    required this.id,
    required this.name,
    required this.disease,
    required this.targetDistrict,
    required this.blocks,
    required this.animalSpecies,
    required this.startDate,
    required this.endDate,
    required this.targetAnimals,
    required this.vaccinatedAnimals,
    required this.coveragePercentage,
    required this.status,
    required this.priority,
    required this.targetVillagesCount,
    required this.completedVillagesCount,
    required this.pendingVillagesCount,
    this.villages = const [],
  });
}

class DiseaseOutbreak {
  final String id;
  final String diseaseName;
  final String affectedDistrict;
  final RiskLevel riskLevel;
  final int cases;
  final int trendPercentage;
  final String detectionDate;
  final String recommendedNextAction;
  final String pathogenType;
  const DiseaseOutbreak({
    required this.id,
    required this.diseaseName,
    required this.affectedDistrict,
    required this.riskLevel,
    required this.cases,
    required this.trendPercentage,
    required this.detectionDate,
    required this.recommendedNextAction,
    required this.pathogenType,
  });
}

class ResponseTask {
  final String id;
  final String title;
  final String district;
  final String village;
  final String diseaseConcern;
  final String priority;
  final String assignedTeam;
  final String dueDate;
  String status;
  final String? notes;
  final String reportedDate;

  ResponseTask({
    required this.id,
    required this.title,
    required this.district,
    required this.village,
    required this.diseaseConcern,
    required this.priority,
    required this.assignedTeam,
    required this.dueDate,
    required this.status,
    this.notes,
    required this.reportedDate,
  });
}

class ReportSummary {
  final String id;
  final String title;
  final String category;
  final String generatedDate;
  final int recordsCount;
  final String status;
  final String fileSize;
  final String period;
  const ReportSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.generatedDate,
    required this.recordsCount,
    required this.status,
    required this.fileSize,
    required this.period,
  });
}

class DistrictRecord {
  final String id;
  final String district;
  final String primaryDisease;
  final int activeCases;
  final int mortality;
  final String coverage;
  final String riskLevel;
  final String responseUnit;
  final String auditStatus;
  const DistrictRecord({
    required this.id,
    required this.district,
    required this.primaryDisease,
    required this.activeCases,
    required this.mortality,
    required this.coverage,
    required this.riskLevel,
    required this.responseUnit,
    required this.auditStatus,
  });
}

class OutbreakTrendPoint {
  final String date;
  final int fmd;
  final int lsd;
  final int brucellosis;
  final int anthrax;
  final int ppr;
  const OutbreakTrendPoint({
    required this.date,
    required this.fmd,
    required this.lsd,
    required this.brucellosis,
    required this.anthrax,
    required this.ppr,
  });
}

// ─── Districts Data ───────────────────────────────────────────────────────────

final List<DistrictData> maharashtraDistricts = [
  DistrictData(
    id: 'pune', name: 'Pune', marathiName: 'पुणे', division: 'Pune',
    riskScore: 78, riskLevel: RiskLevel.critical,
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 62, mortality: 7, vaccinationCoverage: 61.2,
    affectedVillages: 18, totalLivestock: 1845000, trend: '+16%',
    riskSummary: 'Acute cluster of vesicular lesions and fever in crossbred dairy herds along Haveli and Shirur blocks.',
    whyAtRisk: ['Rapid spread of vesicular lesions across dairy clusters', 'Critical vaccination coverage gap (61.2% vs 85% state mandate)', 'High livestock mobility across peri-urban milk sheds', 'Delayed syndromic reporting in 7 peripheral villages'],
    recommendedAction: 'Deploy emergency ring vaccination in 10km radius and activate mobile veterinary containment units.',
    vaccinationGap: 'Critical gap: 23.8% deficit below threshold',
    assignedTeams: [
      AssignedVetTeam(id: 'tm-pun-1', leadVet: 'Dr. Deshmukh', mobileUnit: 'Mobile Vet Van 01', contact: '+91 94220 11022', status: 'Field Deployed'),
      AssignedVetTeam(id: 'tm-pun-2', leadVet: 'Dr. Kadam', mobileUnit: 'Mobile Vet Van 03', contact: '+91 98224 88190', status: 'Field Deployed'),
      AssignedVetTeam(id: 'tm-pun-3', leadVet: 'Dr. Ananya Joshi', mobileUnit: 'RRT Pune Core', contact: '+91 98812 34509', status: 'En Route'),
    ],
    recentReports: [
      SyndromicReport(date: '2026-09-12', village: 'Uruli Kanchan', syndrome: 'Salivation & Foot Lesions', cattleAffected: 14),
      SyndromicReport(date: '2026-09-11', village: 'Wagholi', syndrome: 'High Fever & Blisters', cattleAffected: 9),
      SyndromicReport(date: '2026-09-10', village: 'Loni Kalbhor', syndrome: 'Sudden Milk Drop & Lameness', cattleAffected: 12),
      SyndromicReport(date: '2026-09-08', village: 'Saswad', syndrome: 'Vesicular Eruptions', cattleAffected: 8),
    ],
  ),
  DistrictData(
    id: 'nagpur', name: 'Nagpur', marathiName: 'नागपूर', division: 'Nagpur',
    riskScore: 82, riskLevel: RiskLevel.critical,
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 64, mortality: 8, vaccinationCoverage: 60.8,
    affectedVillages: 16, totalLivestock: 1620000, trend: '+18%',
    riskSummary: 'Acute FMD cluster in Kamptee dairy belt with high herd mobility.',
    whyAtRisk: ['Confirmed Type O FMD pathogen in Kamptee', 'Low vaccination coverage (60.8%)', 'Active cattle market movement', 'Cross-border herd transit from MP'],
    recommendedAction: 'Establish 10km containment ring, freeze cattle markets, and deploy 3 mobile vaccination units.',
    vaccinationGap: 'Critical gap: 24.2% deficit below threshold',
    assignedTeams: [
      AssignedVetTeam(id: 'tm-nag-1', leadVet: 'Dr. Gajbhiye', mobileUnit: 'Nagpur RRT 01', contact: '+91 98223 77001', status: 'Field Deployed'),
    ],
    recentReports: [
      SyndromicReport(date: '2026-09-12', village: 'Kamptee Dairy Belt', syndrome: 'Vesicular Tongue Erosions', cattleAffected: 16),
      SyndromicReport(date: '2026-09-10', village: 'Hingna', syndrome: 'Foot Blisters & Salivation', cattleAffected: 11),
    ],
  ),
  DistrictData(
    id: 'amravati', name: 'Amravati', marathiName: 'अमरावती', division: 'Amravati',
    riskScore: 72, riskLevel: RiskLevel.high,
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 52, mortality: 5, vaccinationCoverage: 64.1,
    affectedVillages: 14, totalLivestock: 1430000, trend: '+14%',
    riskSummary: 'FMD spread in foothill hamlets near Melghat region with cattle migration risk.',
    whyAtRisk: ['Cattle migration from tiger reserve buffer', 'Coverage gap at 64.1%', 'Delayed reporting from remote areas'],
    recommendedAction: 'Deploy 5km radius ring vaccination and enforce checkpost disinfectant tyre dips.',
    vaccinationGap: 'High gap: 20.9% deficit',
    assignedTeams: [AssignedVetTeam(id: 'tm-amr-1', leadVet: 'Dr. Tayade', mobileUnit: 'Melghat 4x4 Van', contact: '+91 98221 44509', status: 'Field Deployed')],
    recentReports: [SyndromicReport(date: '2026-09-09', village: 'Achalpur', syndrome: 'Foot Lesions', cattleAffected: 8)],
  ),
  DistrictData(
    id: 'nashik', name: 'Nashik', marathiName: 'नाशिक', division: 'Nashik',
    riskScore: 65, riskLevel: RiskLevel.high,
    suspectedDisease: 'Brucellosis',
    activeCases: 48, mortality: 4, vaccinationCoverage: 54.5,
    affectedVillages: 11, totalLivestock: 1560000, trend: '+12%',
    riskSummary: 'Brucellosis spread through cooperative milk supply chain in Niphad and Sinnar blocks.',
    whyAtRisk: ['MRT positive tanks in 3 cooperatives', 'Low calfhood vaccination (54.5%)', 'Dense breeding bull population'],
    recommendedAction: 'Execute mandatory calfhood S19 vaccination drive and sero-screen all breeding bulls.',
    vaccinationGap: 'High gap: 30.5% deficit',
    assignedTeams: [AssignedVetTeam(id: 'tm-nas-1', leadVet: 'Dr. Sonawane', mobileUnit: 'Nashik RRT 01', contact: '+91 98220 55321', status: 'In Progress')],
    recentReports: [SyndromicReport(date: '2026-09-04', village: 'Niphad Chilling Centre', syndrome: 'Abortions & Weak Calves', cattleAffected: 6)],
  ),
  DistrictData(
    id: 'jalgaon', name: 'Jalgaon', marathiName: 'जळगाव', division: 'Nashik',
    riskScore: 60, riskLevel: RiskLevel.high,
    suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 39, mortality: 3, vaccinationCoverage: 67.0,
    affectedVillages: 9, totalLivestock: 1290000, trend: '+8%',
    riskSummary: 'HS respiratory distress in working bullocks in Tapi floodplain post-monsoon.',
    whyAtRisk: ['Post-monsoon moisture surge', 'Congested river-side villages', 'Unvaccinated draft cattle'],
    recommendedAction: 'Pre-position emergency antibiotics and dispatch mobile vet vaccination teams to Tapi river villages.',
    vaccinationGap: 'Moderate gap: 18% deficit',
    assignedTeams: [AssignedVetTeam(id: 'tm-jal-1', leadVet: 'Dr. Chaudhari', mobileUnit: 'Tapi Basin MVU', contact: '+91 94231 88102', status: 'Field Deployed')],
    recentReports: [SyndromicReport(date: '2026-09-06', village: 'Bhusawal Tapi', syndrome: 'Respiratory Distress', cattleAffected: 10)],
  ),
  DistrictData(
    id: 'yavatmal', name: 'Yavatmal', marathiName: 'यवतमाळ', division: 'Amravati',
    riskScore: 48, riskLevel: RiskLevel.moderate,
    suspectedDisease: 'Anthrax (Suspected)',
    activeCases: 32, mortality: 3, vaccinationCoverage: 69.0,
    affectedVillages: 7, totalLivestock: 1180000, trend: '+7%',
    riskSummary: 'Sudden bullock mortality in Wani scrubland border with suspected anthrax.',
    whyAtRisk: ['Forest edge livestock access', 'Historic spore-contaminated soil', 'Delay in lab confirmation'],
    recommendedAction: 'Enforce ring vaccination in forest fringe villages and supervise carcass burial protocols.',
    vaccinationGap: 'Moderate gap: 16% deficit',
    assignedTeams: [AssignedVetTeam(id: 'tm-yav-1', leadVet: 'Dr. Meshram', mobileUnit: 'Yavatmal RRT', contact: '+91 94220 33412', status: 'Field Deployed')],
    recentReports: [SyndromicReport(date: '2026-09-05', village: 'Wani Scrubland', syndrome: 'Sudden Mortality', cattleAffected: 2)],
  ),
  DistrictData(
    id: 'solapur', name: 'Solapur', marathiName: 'सोलापूर', division: 'Pune',
    riskScore: 52, riskLevel: RiskLevel.moderate,
    suspectedDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 29, mortality: 2, vaccinationCoverage: 73.8,
    affectedVillages: 9, totalLivestock: 1780000, trend: '+3%',
    riskSummary: 'Moderate PPR in migratory small ruminant flocks across Pandharpur belt.',
    whyAtRisk: ['Migratory sheep/goat flocks', 'Communal water sources', 'Delayed booster coverage'],
    recommendedAction: 'Initiate targeted PPR goat vaccination in migratory clusters and set up checkposts.',
    vaccinationGap: 'Moderate gap: 11.2% deficit',
    assignedTeams: [AssignedVetTeam(id: 'tm-sol-1', leadVet: 'Dr. Jagtap', mobileUnit: 'Solapur MVU-01', contact: '+91 98221 66734', status: 'Field Deployed')],
    recentReports: [SyndromicReport(date: '2026-09-03', village: 'Pandharpur South', syndrome: 'Respiratory Distress', cattleAffected: 5)],
  ),
  DistrictData(
    id: 'satara', name: 'Satara', marathiName: 'सातारा', division: 'Pune',
    riskScore: 28, riskLevel: RiskLevel.low,
    suspectedDisease: 'Routine Surveillance',
    activeCases: 11, mortality: 0, vaccinationCoverage: 88.4,
    affectedVillages: 4, totalLivestock: 1320000, trend: '-8%',
    riskSummary: 'Stable syndromic baseline with high vaccination saturation.',
    whyAtRisk: ['High vaccination saturation (88.4%)', 'Prompt para-vet reporting', 'Zero mortality in 60 days'],
    recommendedAction: 'Maintain baseline syndromic monitoring and sentinel milk testing.',
    vaccinationGap: 'Satisfactory: 3.4% above target',
    assignedTeams: [AssignedVetTeam(id: 'tm-sat-1', leadVet: 'Dr. S. Mane', mobileUnit: 'Satara MVU-02', contact: '+91 94231 44520', status: 'On Standby')],
    recentReports: [SyndromicReport(date: '2026-09-09', village: 'Karad Rural', syndrome: 'Mild Respiratory', cattleAffected: 3)],
  ),
  DistrictData(
    id: 'thane', name: 'Thane', marathiName: 'ठाणे', division: 'Konkan',
    riskScore: 22, riskLevel: RiskLevel.low,
    suspectedDisease: 'Routine Surveillance',
    activeCases: 9, mortality: 0, vaccinationCoverage: 91.0,
    affectedVillages: 3, totalLivestock: 980000, trend: '-5%',
    riskSummary: 'Interstate livestock transit checkpoint active. Stable baseline.',
    whyAtRisk: ['NH48 transit corridor inspection needed'],
    recommendedAction: 'Maintain highway checkpoint surveillance.',
    vaccinationGap: 'Excellent: 6% above target',
    assignedTeams: [AssignedVetTeam(id: 'tm-tha-1', leadVet: 'Dr. Bhoir', mobileUnit: 'Thane Regional MVU', contact: '+91 99208 11223', status: 'On Standby')],
    recentReports: [],
  ),
  DistrictData(
    id: 'nandurbar', name: 'Nandurbar', marathiName: 'नंदुरबार', division: 'Nashik',
    riskScore: 55, riskLevel: RiskLevel.moderate,
    suspectedDisease: 'Anthrax',
    activeCases: 18, mortality: 1, vaccinationCoverage: 62.0,
    affectedVillages: 6, totalLivestock: 890000, trend: '+5%',
    riskSummary: 'Tribal forest-fringe villages with anthrax soil reservoir risk in Satpura range.',
    whyAtRisk: ['Endemic anthrax soil zone', 'Tribal area reporting delays', 'Low coverage (62%)'],
    recommendedAction: 'Satpura Tribal Anthrax Buffer vaccination drive.',
    vaccinationGap: 'High gap: 23% deficit',
    assignedTeams: [AssignedVetTeam(id: 'tm-nan-1', leadVet: 'Dr. Valvi', mobileUnit: 'Satpura 4x4 Mobile Unit', contact: '+91 94231 55610', status: 'Field Deployed')],
    recentReports: [SyndromicReport(date: '2026-09-08', village: 'Dhadgaon Forest Edge', syndrome: 'Sudden Mortality', cattleAffected: 1)],
  ),
];

// ─── Alerts Data ──────────────────────────────────────────────────────────────

List<GovtAlert> getInitialAlerts() => [
  GovtAlert(id: 'ALT-001', type: 'Outbreak', title: 'Critical Outbreak Alert: FMD Cluster Confirmed in Nagpur', district: 'Nagpur', time: '12 min ago', priority: 'Critical', isRead: false, resolved: false, actionText: 'Review Outbreak Dossier', description: '14 acute vesicular cases confirmed in Kamptee dairy belt. Viral load tests confirm Type O FMD pathogen.'),
  GovtAlert(id: 'ALT-002', type: 'Risk Escalation', title: 'Risk Escalation: Pune District Surpasses Critical Risk Threshold (78%)', district: 'Pune', time: '42 min ago', priority: 'Critical', isRead: false, resolved: false, actionText: 'Open District Intelligence', description: 'Surge of 16% in reported clinical syndromes across Haveli taluka. Vaccination coverage gap sits at 23.8%.'),
  GovtAlert(id: 'ALT-003', type: 'Lab Confirmation', title: 'Lab Confirmation: Anthrax Suspicion Samples Dispatched to Pune Lab', district: 'Yavatmal', time: '2 hours ago', priority: 'Critical', isRead: false, resolved: false, actionText: 'View Response Task', description: 'Sudden mortality of 2 bullocks in Wani scrubland. Smears sent to State Animal Disease Diagnostic Laboratory.'),
  GovtAlert(id: 'ALT-004', type: 'Campaign Due', title: 'Campaign Milestone: FMD Ring Drive in Pune Reaches 78% Target', district: 'Pune', time: '3 hours ago', priority: 'High', isRead: true, resolved: false, actionText: 'Inspect Campaign Progress', description: '6,630 animals vaccinated across 11 villages. 7 remote villages remain pending in high-density dairy belt.'),
  GovtAlert(id: 'ALT-005', type: 'Risk Escalation', title: 'Epidemiological Signal: High HS Cluster Detected in Tapi Floodplain', district: 'Jalgaon', time: '5 hours ago', priority: 'High', isRead: true, resolved: false, actionText: 'View District Status', description: 'Respiratory distress reported in 39 working bullocks in low-lying river areas following unseasonal moisture.'),
  GovtAlert(id: 'ALT-006', type: 'Advisory', title: 'Advisory Issued: State-Wide Biosecurity Guidelines for Cattle Markets', district: 'Maharashtra State', time: 'Yesterday', priority: 'Medium', isRead: true, resolved: true, actionText: 'Download Advisory PDF', description: 'Mandatory sodium carbonate wash requirement published for all district weekly animal trade grounds.'),
];

// ─── Campaigns Data ───────────────────────────────────────────────────────────

List<VaccinationCampaign> getInitialCampaigns() => [
  VaccinationCampaign(
    id: 'CAMP-MH-001', name: 'FMD Emergency Ring Vaccination Drive', disease: 'Foot-and-Mouth Disease (FMD)',
    targetDistrict: 'Pune', blocks: ['Haveli', 'Shirur', 'Baramati', 'Khed'],
    animalSpecies: 'Cattle, Buffalo', startDate: '2026-08-28', endDate: '2026-09-28',
    targetAnimals: 8500, vaccinatedAnimals: 6630, coveragePercentage: 78.0,
    status: 'Active', priority: 'Critical',
    targetVillagesCount: 18, completedVillagesCount: 11, pendingVillagesCount: 7,
    villages: [
      VillageCampaignItem(name: 'Uruli Kanchan', target: 500, vaccinated: 500, status: 'Completed', assignedTeam: 'Team Alpha (Dr. Deshmukh)'),
      VillageCampaignItem(name: 'Wagholi Dairy Belt', target: 600, vaccinated: 580, status: 'Completed', assignedTeam: 'Team Alpha (Dr. Deshmukh)'),
      VillageCampaignItem(name: 'Saswad Rural', target: 480, vaccinated: 480, status: 'Completed', assignedTeam: 'Team Beta (Dr. Kadam)'),
      VillageCampaignItem(name: 'Manchar Valley', target: 420, vaccinated: 260, status: 'In Progress', assignedTeam: 'Mobile Vet Van 03'),
      VillageCampaignItem(name: 'Jejuri Plateau', target: 550, vaccinated: 180, status: 'Low Coverage', assignedTeam: 'RRT Pune Core'),
      VillageCampaignItem(name: 'Rajgurunagar East', target: 440, vaccinated: 100, status: 'Low Coverage', assignedTeam: null),
    ],
  ),
  VaccinationCampaign(
    id: 'CAMP-MH-002', name: 'Vidarbha FMD Buffer Containment', disease: 'Foot-and-Mouth Disease (FMD)',
    targetDistrict: 'Nagpur', blocks: ['Kamptee', 'Hingna', 'Umred', 'Katol'],
    animalSpecies: 'Cattle, Buffalo', startDate: '2026-09-02', endDate: '2026-10-02',
    targetAnimals: 11200, vaccinatedAnimals: 6832, coveragePercentage: 61.0,
    status: 'Active', priority: 'Critical',
    targetVillagesCount: 19, completedVillagesCount: 8, pendingVillagesCount: 11,
  ),
  VaccinationCampaign(
    id: 'CAMP-MH-003', name: 'Brucellosis Prevention & S19 Drive', disease: 'Brucellosis',
    targetDistrict: 'Nashik', blocks: ['Niphad', 'Sinnar', 'Dindori'],
    animalSpecies: 'Female Calves (4-8 months)', startDate: '2026-08-20', endDate: '2026-09-25',
    targetAnimals: 6200, vaccinatedAnimals: 4340, coveragePercentage: 70.0,
    status: 'Active', priority: 'High',
    targetVillagesCount: 14, completedVillagesCount: 9, pendingVillagesCount: 5,
  ),
  VaccinationCampaign(
    id: 'CAMP-MH-004', name: 'HS Pre-Winter Ring Immunization', disease: 'Haemorrhagic Septicaemia (HS)',
    targetDistrict: 'Jalgaon', blocks: ['Bhusawal', 'Raver', 'Yawal'],
    animalSpecies: 'Draft Cattle, Buffalo', startDate: '2026-09-01', endDate: '2026-09-20',
    targetAnimals: 5400, vaccinatedAnimals: 4104, coveragePercentage: 76.0,
    status: 'Active', priority: 'High',
    targetVillagesCount: 11, completedVillagesCount: 8, pendingVillagesCount: 3,
  ),
  VaccinationCampaign(
    id: 'CAMP-MH-005', name: 'Migratory Small Ruminant PPR Shield', disease: 'Peste des Petits Ruminants (PPR)',
    targetDistrict: 'Solapur', blocks: ['Pandharpur', 'Sangola', 'Mangalwedha'],
    animalSpecies: 'Sheep, Goat', startDate: '2026-08-15', endDate: '2026-09-18',
    targetAnimals: 7800, vaccinatedAnimals: 6396, coveragePercentage: 82.0,
    status: 'Active', priority: 'Medium',
    targetVillagesCount: 9, completedVillagesCount: 7, pendingVillagesCount: 2,
  ),
  VaccinationCampaign(
    id: 'CAMP-MH-006', name: 'Satpura Tribal Anthrax Buffer', disease: 'Anthrax',
    targetDistrict: 'Nandurbar', blocks: ['Dhadgaon', 'Akrani', 'Shahada'],
    animalSpecies: 'Cattle, Buffalo, Sheep', startDate: '2026-09-10', endDate: '2026-10-10',
    targetAnimals: 3600, vaccinatedAnimals: 1440, coveragePercentage: 40.0,
    status: 'Active', priority: 'High',
    targetVillagesCount: 8, completedVillagesCount: 2, pendingVillagesCount: 6,
  ),
];

// ─── Outbreak Data ────────────────────────────────────────────────────────────

const List<DiseaseOutbreak> outbreakSignals = [
  DiseaseOutbreak(id: 'out-001', diseaseName: 'Foot-and-Mouth Disease (FMD)', affectedDistrict: 'Nagpur', riskLevel: RiskLevel.critical, cases: 64, trendPercentage: 18, detectionDate: '2026-09-08', recommendedNextAction: 'Establish 10km containment ring, freeze cattle markets, and deploy 3 mobile vaccination units.', pathogenType: 'Viral'),
  DiseaseOutbreak(id: 'out-002', diseaseName: 'Foot-and-Mouth Disease (FMD)', affectedDistrict: 'Pune', riskLevel: RiskLevel.critical, cases: 62, trendPercentage: 16, detectionDate: '2026-09-07', recommendedNextAction: 'Initiate emergency booster campaign across Haveli and Shirur blocks; screen cooperative milk tankers.', pathogenType: 'Viral'),
  DiseaseOutbreak(id: 'out-003', diseaseName: 'Foot-and-Mouth Disease (FMD)', affectedDistrict: 'Amravati', riskLevel: RiskLevel.high, cases: 52, trendPercentage: 14, detectionDate: '2026-09-09', recommendedNextAction: 'Deploy 5km radius ring vaccination and enforce checkpost disinfectant tyre dips.', pathogenType: 'Viral'),
  DiseaseOutbreak(id: 'out-004', diseaseName: 'Brucellosis', affectedDistrict: 'Nashik', riskLevel: RiskLevel.high, cases: 48, trendPercentage: 12, detectionDate: '2026-09-04', recommendedNextAction: 'Execute mandatory calfhood S19 vaccination drive and sero-screen all breeding bulls.', pathogenType: 'Bacterial'),
  DiseaseOutbreak(id: 'out-005', diseaseName: 'Haemorrhagic Septicaemia (HS)', affectedDistrict: 'Jalgaon', riskLevel: RiskLevel.high, cases: 39, trendPercentage: 8, detectionDate: '2026-09-06', recommendedNextAction: 'Pre-position emergency antibiotics and dispatch mobile vet vaccination teams to Tapi river villages.', pathogenType: 'Bacterial'),
  DiseaseOutbreak(id: 'out-006', diseaseName: 'Anthrax', affectedDistrict: 'Yavatmal', riskLevel: RiskLevel.moderate, cases: 32, trendPercentage: 7, detectionDate: '2026-09-05', recommendedNextAction: 'Enforce ring vaccination in forest fringe villages and supervise carcass burial protocols.', pathogenType: 'Bacterial'),
  DiseaseOutbreak(id: 'out-007', diseaseName: 'Peste des Petits Ruminants (PPR)', affectedDistrict: 'Solapur', riskLevel: RiskLevel.moderate, cases: 29, trendPercentage: 3, detectionDate: '2026-09-03', recommendedNextAction: 'Prioritize targeted PPR goat vaccination in migratory herds and pastoral checkposts.', pathogenType: 'Viral'),
];

const List<OutbreakTrendPoint> outbreakTrendData = [
  OutbreakTrendPoint(date: 'Aug 15', fmd: 18, lsd: 12, brucellosis: 14, anthrax: 3, ppr: 10),
  OutbreakTrendPoint(date: 'Aug 18', fmd: 22, lsd: 11, brucellosis: 15, anthrax: 4, ppr: 12),
  OutbreakTrendPoint(date: 'Aug 21', fmd: 27, lsd: 14, brucellosis: 16, anthrax: 3, ppr: 13),
  OutbreakTrendPoint(date: 'Aug 24', fmd: 31, lsd: 13, brucellosis: 19, anthrax: 5, ppr: 14),
  OutbreakTrendPoint(date: 'Aug 27', fmd: 38, lsd: 15, brucellosis: 22, anthrax: 4, ppr: 15),
  OutbreakTrendPoint(date: 'Aug 30', fmd: 46, lsd: 17, brucellosis: 26, anthrax: 6, ppr: 18),
  OutbreakTrendPoint(date: 'Sep 02', fmd: 55, lsd: 16, brucellosis: 29, anthrax: 5, ppr: 20),
  OutbreakTrendPoint(date: 'Sep 05', fmd: 68, lsd: 18, brucellosis: 34, anthrax: 7, ppr: 22),
  OutbreakTrendPoint(date: 'Sep 08', fmd: 84, lsd: 19, brucellosis: 39, anthrax: 8, ppr: 25),
  OutbreakTrendPoint(date: 'Sep 11', fmd: 102, lsd: 21, brucellosis: 44, anthrax: 9, ppr: 27),
  OutbreakTrendPoint(date: 'Sep 13', fmd: 118, lsd: 22, brucellosis: 48, anthrax: 8, ppr: 29),
];

// ─── Response Tasks ───────────────────────────────────────────────────────────

List<ResponseTask> getInitialResponseTasks() => [
  ResponseTask(id: 'TASK-001', title: 'Emergency 10km Ring Vaccination & Quarantining', district: 'Nagpur', village: 'Kamptee Dairy Belt (Cluster 4)', diseaseConcern: 'Foot-and-Mouth Disease (FMD)', priority: 'Critical', assignedTeam: 'Nagpur Rapid Response 01 (Dr. Gajbhiye)', dueDate: '2026-09-14', status: 'In Progress', notes: '16 cattle presenting vesicular tongue erosions. Ring vaccination active in 5km inner perimeter.', reportedDate: '2026-09-12'),
  ResponseTask(id: 'TASK-002', title: 'Emergency Containment & Milk Tanker Disinfection', district: 'Pune', village: 'Uruli Kanchan Dairy Route', diseaseConcern: 'Foot-and-Mouth Disease (FMD)', priority: 'Critical', assignedTeam: 'Team Alpha (Dr. Deshmukh)', dueDate: '2026-09-14', status: 'In Progress', notes: 'Sodium carbonate foot dips installed at primary co-operative chilling station gates.', reportedDate: '2026-09-12'),
  ResponseTask(id: 'TASK-003', title: 'Investigate Sudden Bull Mortality & Spore Swabbing', district: 'Yavatmal', village: 'Wani Scrubland Border', diseaseConcern: 'Anthrax (Suspected)', priority: 'Critical', assignedTeam: 'Yavatmal RRT (Dr. Meshram)', dueDate: '2026-09-13', status: 'Awaiting Lab Result', notes: 'Blood smear shipped via cold chain to State Animal Disease Diagnostic Lab, Pune.', reportedDate: '2026-09-11'),
  ResponseTask(id: 'TASK-004', title: 'Melghat Foothills Barrier Checkpost & Serum Collection', district: 'Amravati', village: 'Achalpur Foothill Hamlet', diseaseConcern: 'Foot-and-Mouth Disease (FMD)', priority: 'High', assignedTeam: 'Melghat 4x4 Van (Dr. Tayade)', dueDate: '2026-09-15', status: 'Assigned', notes: 'Prevent cattle from migrating into tiger reserve buffer areas during active outbreak.', reportedDate: '2026-09-11'),
  ResponseTask(id: 'TASK-005', title: 'Serological Screening of Bulk Milk Tanks & Bull Ring Tests', district: 'Nashik', village: 'Niphad Chilling Centre', diseaseConcern: 'Brucellosis', priority: 'High', assignedTeam: 'Nashik RRT 01 (Dr. Sonawane)', dueDate: '2026-09-16', status: 'In Progress', notes: 'MRT positive reactions recorded in 3 cooperative route collection tanks.', reportedDate: '2026-09-10'),
  ResponseTask(id: 'TASK-006', title: 'Floodplain Prophylactic Antibiotic & Vaccine Mobilization', district: 'Jalgaon', village: 'Bhusawal Tapi Floodplain', diseaseConcern: 'Haemorrhagic Septicaemia (HS)', priority: 'High', assignedTeam: 'Tapi Basin MVU (Dr. Chaudhari)', dueDate: '2026-09-16', status: 'Assigned', notes: 'Draft bullocks in 4 low-lying villages scheduled for immediate treatment.', reportedDate: '2026-09-10'),
  ResponseTask(id: 'TASK-007', title: 'Livestock Fair Sanitation & Inspection Checkpoints', district: 'Chhatrapati Sambhajinagar', village: 'Gangapur Weekly Mandi', diseaseConcern: 'Foot-and-Mouth Disease (FMD)', priority: 'High', assignedTeam: 'Sambhajinagar RRT (Dr. Kale)', dueDate: '2026-09-15', status: 'New', notes: 'Enforce entry permits and visual mouth/hoof inspections before auction entry.', reportedDate: '2026-09-12'),
  ResponseTask(id: 'TASK-008', title: 'Migratory Sheep Flock Health Audit & Deworming', district: 'Solapur', village: 'Pandharpur South Pastures', diseaseConcern: 'Peste des Petits Ruminants (PPR)', priority: 'Medium', assignedTeam: 'Solapur MVU-01 (Dr. Jagtap)', dueDate: '2026-09-18', status: 'In Progress', notes: 'Targeting 8 nomadic dhangar shepherd encampments in dryland belt.', reportedDate: '2026-09-09'),
  ResponseTask(id: 'TASK-009', title: 'Soil Spore Neutralization & Deep Burial Supervision', district: 'Nandurbar', village: 'Dhadgaon Forest Edge', diseaseConcern: 'Anthrax', priority: 'Medium', assignedTeam: 'Satpura 4x4 Mobile Unit (Dr. Valvi)', dueDate: '2026-09-17', status: 'Completed', notes: 'Carcass buried 6 feet deep with quicklime per state bio-containment guidelines.', reportedDate: '2026-09-08'),
  ResponseTask(id: 'TASK-010', title: 'Vector Insect Fogging & Supportive Kit Distribution', district: 'Dhule', village: 'Shindkheda Rural', diseaseConcern: 'Lumpy Skin Disease (LSD)', priority: 'Medium', assignedTeam: 'Dhule MVU-01 (Dr. Deore)', dueDate: '2026-09-19', status: 'Assigned', notes: 'Provide village panchayat with pyrethroid sprays for community cattle sheds.', reportedDate: '2026-09-09'),
  ResponseTask(id: 'TASK-011', title: '14-Day Post-Vaccination Syndromic Surveillance Window', district: 'Satara', village: 'Karad Rural Milk Belt', diseaseConcern: 'Routine Surveillance', priority: 'Monitoring', assignedTeam: 'Satara MVU-02 (Dr. Mane)', dueDate: '2026-09-22', status: 'In Progress', notes: 'Maintain zero-case verification log with 12 local dairy societies.', reportedDate: '2026-09-08'),
  ResponseTask(id: 'TASK-012', title: 'Interstate Highway Live Checkpoint Surveillance Audit', district: 'Thane', village: 'Bhiwandi Highway Octroi Post', diseaseConcern: 'Routine Surveillance', priority: 'Monitoring', assignedTeam: 'Thane Regional MVU (Dr. Bhoir)', dueDate: '2026-09-24', status: 'In Progress', notes: 'Inspect animal health certificates on cattle vehicles arriving via NH48.', reportedDate: '2026-09-07'),
];

// ─── Reports Data ─────────────────────────────────────────────────────────────

const List<ReportSummary> reportsCatalog = [
  ReportSummary(id: 'REP-2026-091', title: 'Maharashtra Weekly Epidemiological Surveillance Bulletin', category: 'Disease Trends', generatedDate: '2026-09-12', recordsCount: 1420, status: 'Ready', fileSize: '3.4 MB', period: '05 Sep 2026 – 12 Sep 2026'),
  ReportSummary(id: 'REP-2026-090', title: 'District Livestock Risk Assessment & Vulnerability Ranking', category: 'District Risk Summary', generatedDate: '2026-09-10', recordsCount: 36, status: 'Ready', fileSize: '1.8 MB', period: 'Month of September 2026'),
  ReportSummary(id: 'REP-2026-089', title: 'Statewide FMD & HS Ring Vaccination Coverage Audit', category: 'Vaccination Coverage', generatedDate: '2026-09-08', recordsCount: 348, status: 'Ready', fileSize: '4.2 MB', period: 'Q3 2026 (July – Sept)'),
  ReportSummary(id: 'REP-2026-088', title: 'Livestock Mortality & Peracute Syndrome Investigation Log', category: 'Mortality Reports', generatedDate: '2026-09-05', recordsCount: 84, status: 'Ready', fileSize: '1.2 MB', period: 'Last 30 Days'),
  ReportSummary(id: 'REP-2026-087', title: 'Veterinary Mobile Unit Response Times & Task Resolution Index', category: 'Response Performance', generatedDate: '2026-09-01', recordsCount: 192, status: 'Ready', fileSize: '2.1 MB', period: 'August 2026'),
  ReportSummary(id: 'REP-2026-086', title: 'FMD Emergency Containment Campaign Performance Review (Pune/Nagpur)', category: 'Campaign Performance', generatedDate: '2026-08-28', recordsCount: 76, status: 'Ready', fileSize: '2.8 MB', period: 'Fortnightly Review'),
];

const List<DistrictRecord> districtRecords = [
  DistrictRecord(id: 'REC-01', district: 'Nagpur', primaryDisease: 'FMD', activeCases: 64, mortality: 8, coverage: '60.8%', riskLevel: 'Critical', responseUnit: 'Nagpur RRT 01', auditStatus: 'Under Investigation'),
  DistrictRecord(id: 'REC-02', district: 'Pune', primaryDisease: 'FMD', activeCases: 62, mortality: 7, coverage: '61.2%', riskLevel: 'Critical', responseUnit: 'Team Alpha', auditStatus: 'Containment Active'),
  DistrictRecord(id: 'REC-03', district: 'Amravati', primaryDisease: 'FMD', activeCases: 52, mortality: 5, coverage: '64.1%', riskLevel: 'High', responseUnit: 'Amravati RRT 02', auditStatus: 'Ring Vaccination'),
  DistrictRecord(id: 'REC-04', district: 'Nashik', primaryDisease: 'Brucellosis', activeCases: 48, mortality: 4, coverage: '54.5%', riskLevel: 'High', responseUnit: 'Nashik RRT 01', auditStatus: 'S19 Testing'),
  DistrictRecord(id: 'REC-05', district: 'Chandrapur', primaryDisease: 'FMD', activeCases: 39, mortality: 4, coverage: '65.8%', riskLevel: 'High', responseUnit: 'Chandrapur RRT', auditStatus: 'Market Frozen'),
  DistrictRecord(id: 'REC-06', district: 'Jalgaon', primaryDisease: 'HS', activeCases: 39, mortality: 3, coverage: '67.0%', riskLevel: 'High', responseUnit: 'Tapi Basin MVU', auditStatus: 'Prophylactic Rx'),
  DistrictRecord(id: 'REC-07', district: 'Sambhajinagar', primaryDisease: 'FMD', activeCases: 38, mortality: 3, coverage: '68.4%', riskLevel: 'High', responseUnit: 'Sambhajinagar RRT', auditStatus: 'Checkpost Alert'),
  DistrictRecord(id: 'REC-08', district: 'Ahmednagar', primaryDisease: 'FMD', activeCases: 37, mortality: 3, coverage: '69.5%', riskLevel: 'High', responseUnit: 'Rahuri Regional', auditStatus: 'Transit Inspection'),
  DistrictRecord(id: 'REC-09', district: 'Wardha', primaryDisease: 'FMD', activeCases: 34, mortality: 2, coverage: '69.2%', riskLevel: 'High', responseUnit: 'Wardha RRT 01', auditStatus: 'Buffer Zone'),
  DistrictRecord(id: 'REC-10', district: 'Yavatmal', primaryDisease: 'Anthrax (Susp)', activeCases: 32, mortality: 3, coverage: '69.0%', riskLevel: 'Moderate', responseUnit: 'Yavatmal RRT', auditStatus: 'Lab Pending'),
  DistrictRecord(id: 'REC-11', district: 'Solapur', primaryDisease: 'PPR', activeCases: 29, mortality: 2, coverage: '73.8%', riskLevel: 'Moderate', responseUnit: 'Solapur MVU-01', auditStatus: 'Flock Deworming'),
  DistrictRecord(id: 'REC-12', district: 'Akola', primaryDisease: 'HS', activeCases: 28, mortality: 2, coverage: '70.5%', riskLevel: 'Moderate', responseUnit: 'Akola MVU-01', auditStatus: 'Purna Basin'),
  DistrictRecord(id: 'REC-13', district: 'Satara', primaryDisease: 'Routine', activeCases: 11, mortality: 0, coverage: '88.4%', riskLevel: 'Low', responseUnit: 'Satara MVU-02', auditStatus: 'Verified Clean'),
  DistrictRecord(id: 'REC-14', district: 'Thane', primaryDisease: 'Routine', activeCases: 9, mortality: 0, coverage: '91.0%', riskLevel: 'Low', responseUnit: 'Thane Regional', auditStatus: 'Verified Clean'),
  DistrictRecord(id: 'REC-15', district: 'Sindhudurg', primaryDisease: 'Routine', activeCases: 6, mortality: 0, coverage: '91.5%', riskLevel: 'Low', responseUnit: 'Sindhudurg MVU', auditStatus: 'Verified Clean'),
  DistrictRecord(id: 'REC-16', district: 'Nandurbar', primaryDisease: 'Anthrax', activeCases: 18, mortality: 1, coverage: '62.0%', riskLevel: 'Moderate', responseUnit: 'Satpura 4x4 Unit', auditStatus: 'Tribal Zone'),
];
