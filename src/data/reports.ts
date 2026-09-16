import type { ReportSummary } from '../types/government';

export const REPORTS_CATALOG: ReportSummary[] = [
  {
    id: 'REP-2026-091',
    title: 'Maharashtra Weekly Epidemiological Surveillance Bulletin',
    category: 'Disease Trends',
    generatedDate: '2026-09-12',
    recordsCount: 1420,
    status: 'Ready',
    fileSize: '3.4 MB',
    period: '05 Sep 2026 – 12 Sep 2026'
  },
  {
    id: 'REP-2026-090',
    title: 'District Livestock Risk Assessment & Vulnerability Ranking',
    category: 'District Risk Summary',
    generatedDate: '2026-09-10',
    recordsCount: 36,
    status: 'Ready',
    fileSize: '1.8 MB',
    period: 'Month of September 2026'
  },
  {
    id: 'REP-2026-089',
    title: 'Statewide FMD & HS Ring Vaccination Coverage Audit',
    category: 'Vaccination Coverage',
    generatedDate: '2026-09-08',
    recordsCount: 348,
    status: 'Ready',
    fileSize: '4.2 MB',
    period: 'Q3 2026 (July – Sept)'
  },
  {
    id: 'REP-2026-088',
    title: 'Livestock Mortality & Peracute Syndrome Investigation Log',
    category: 'Mortality Reports',
    generatedDate: '2026-09-05',
    recordsCount: 84,
    status: 'Ready',
    fileSize: '1.2 MB',
    period: 'Last 30 Days'
  },
  {
    id: 'REP-2026-087',
    title: 'Veterinary Mobile Unit Response Times & Task Resolution Index',
    category: 'Response Performance',
    generatedDate: '2026-09-01',
    recordsCount: 192,
    status: 'Ready',
    fileSize: '2.1 MB',
    period: 'August 2026'
  },
  {
    id: 'REP-2026-086',
    title: 'FMD Emergency Containment Campaign Performance Review (Pune/Nagpur)',
    category: 'Campaign Performance',
    generatedDate: '2026-08-28',
    recordsCount: 76,
    status: 'Ready',
    fileSize: '2.8 MB',
    period: 'Fortnightly Review'
  }
];

export const TABLE_REPORT_RECORDS = [
  { id: 'REC-01', district: 'Nagpur', primaryDisease: 'FMD', activeCases: 64, mortality: 8, coverage: '60.8%', riskLevel: 'Critical', responseUnit: 'Nagpur RRT 01', auditStatus: 'Under Investigation' },
  { id: 'REC-02', district: 'Pune', primaryDisease: 'FMD', activeCases: 62, mortality: 7, coverage: '61.2%', riskLevel: 'Critical', responseUnit: 'Team Alpha', auditStatus: 'Containment Active' },
  { id: 'REC-03', district: 'Amravati', primaryDisease: 'FMD', activeCases: 52, mortality: 5, coverage: '64.1%', riskLevel: 'High', responseUnit: 'Amravati RRT 02', auditStatus: 'Ring Vaccination' },
  { id: 'REC-04', district: 'Nashik', primaryDisease: 'Brucellosis', activeCases: 48, mortality: 4, coverage: '54.5%', riskLevel: 'High', responseUnit: 'Nashik RRT 01', auditStatus: 'S19 Testing' },
  { id: 'REC-05', district: 'Chandrapur', primaryDisease: 'FMD', activeCases: 39, mortality: 4, coverage: '65.8%', riskLevel: 'High', responseUnit: 'Chandrapur RRT', auditStatus: 'Market Frozen' },
  { id: 'REC-06', district: 'Jalgaon', primaryDisease: 'HS', activeCases: 39, mortality: 3, coverage: '67.0%', riskLevel: 'High', responseUnit: 'Tapi Basin MVU', auditStatus: 'Prophylactic Rx' },
  { id: 'REC-07', district: 'Chh. Sambhajinagar', primaryDisease: 'FMD', activeCases: 38, mortality: 3, coverage: '68.4%', riskLevel: 'High', responseUnit: 'Sambhajinagar RRT', auditStatus: 'Checkpost Alert' },
  { id: 'REC-08', district: 'Ahmednagar', primaryDisease: 'FMD', activeCases: 37, mortality: 3, coverage: '69.5%', riskLevel: 'High', responseUnit: 'Rahuri Regional', auditStatus: 'Transit Inspection' },
  { id: 'REC-09', district: 'Wardha', primaryDisease: 'FMD', activeCases: 34, mortality: 2, coverage: '69.2%', riskLevel: 'High', responseUnit: 'Wardha RRT 01', auditStatus: 'Buffer Zone' },
  { id: 'REC-10', district: 'Yavatmal', primaryDisease: 'Anthrax (Susp)', activeCases: 32, mortality: 3, coverage: '69.0%', riskLevel: 'Moderate', responseUnit: 'Yavatmal RRT', auditStatus: 'Lab Pending' },
  { id: 'REC-11', district: 'Nanded', primaryDisease: 'FMD', activeCases: 31, mortality: 2, coverage: '71.8%', riskLevel: 'Moderate', responseUnit: 'Nanded Border', auditStatus: 'Checkpost Active' },
  { id: 'REC-12', district: 'Solapur', primaryDisease: 'PPR', activeCases: 29, mortality: 2, coverage: '73.8%', riskLevel: 'Moderate', responseUnit: 'Solapur MVU-01', auditStatus: 'Flock Deworming' },
  { id: 'REC-13', district: 'Akola', primaryDisease: 'HS', activeCases: 28, mortality: 2, coverage: '70.5%', riskLevel: 'Moderate', responseUnit: 'Akola MVU-01', auditStatus: 'Purna Basin' },
  { id: 'REC-14', district: 'Satara', primaryDisease: 'Routine Surveillance', activeCases: 11, mortality: 0, coverage: '88.4%', riskLevel: 'Low', responseUnit: 'Satara MVU-02', auditStatus: 'Verified Clean' },
  { id: 'REC-15', district: 'Thane', primaryDisease: 'Routine Surveillance', activeCases: 9, mortality: 0, coverage: '91.0%', riskLevel: 'Low', responseUnit: 'Thane Regional', auditStatus: 'Verified Clean' },
  { id: 'REC-16', district: 'Sindhudurg', primaryDisease: 'Routine Surveillance', activeCases: 6, mortality: 0, coverage: '91.5%', riskLevel: 'Low', responseUnit: 'Sindhudurg MVU', auditStatus: 'Verified Clean' }
];
