import type { DiseaseOutbreak, OutbreakTrendPoint } from '../types/government';

export const OUTBREAK_SIGNALS: DiseaseOutbreak[] = [
  {
    id: 'out-001',
    diseaseName: 'Foot-and-Mouth Disease (FMD)',
    affectedDistrict: 'Nagpur',
    riskLevel: 'Critical',
    cases: 64,
    trendPercentage: 18,
    detectionDate: '2026-09-08',
    recommendedNextAction: 'Establish 10km containment ring, freeze cattle markets, and deploy 3 mobile vaccination units.',
    pathogenType: 'Viral'
  },
  {
    id: 'out-002',
    diseaseName: 'Foot-and-Mouth Disease (FMD)',
    affectedDistrict: 'Pune',
    riskLevel: 'Critical',
    cases: 62,
    trendPercentage: 16,
    detectionDate: '2026-09-07',
    recommendedNextAction: 'Initiate emergency booster campaign across Haveli and Shirur blocks; screen cooperative milk tankers.',
    pathogenType: 'Viral'
  },
  {
    id: 'out-003',
    diseaseName: 'Foot-and-Mouth Disease (FMD)',
    affectedDistrict: 'Amravati',
    riskLevel: 'High',
    cases: 52,
    trendPercentage: 14,
    detectionDate: '2026-09-09',
    recommendedNextAction: 'Deploy 5km radius ring vaccination and enforce checkpost disinfectant tyre dips.',
    pathogenType: 'Viral'
  },
  {
    id: 'out-004',
    diseaseName: 'Brucellosis',
    affectedDistrict: 'Nashik',
    riskLevel: 'High',
    cases: 48,
    trendPercentage: 12,
    detectionDate: '2026-09-04',
    recommendedNextAction: 'Execute mandatory calfhood S19 vaccination drive and sero-screen all breeding bulls.',
    pathogenType: 'Bacterial'
  },
  {
    id: 'out-005',
    diseaseName: 'Haemorrhagic Septicaemia (HS)',
    affectedDistrict: 'Jalgaon',
    riskLevel: 'High',
    cases: 39,
    trendPercentage: 8,
    detectionDate: '2026-09-06',
    recommendedNextAction: 'Pre-position emergency antibiotics and dispatch mobile vet vaccination teams to Tapi river villages.',
    pathogenType: 'Bacterial'
  },
  {
    id: 'out-006',
    diseaseName: 'Anthrax',
    affectedDistrict: 'Yavatmal',
    riskLevel: 'Moderate',
    cases: 32,
    trendPercentage: 7,
    detectionDate: '2026-09-05',
    recommendedNextAction: 'Enforce ring vaccination in forest fringe villages and supervise carcass burial protocols.',
    pathogenType: 'Bacterial'
  },
  {
    id: 'out-007',
    diseaseName: 'Peste des Petits Ruminants (PPR)',
    affectedDistrict: 'Solapur',
    riskLevel: 'Moderate',
    cases: 29,
    trendPercentage: 3,
    detectionDate: '2026-09-03',
    recommendedNextAction: 'Prioritize targeted PPR goat vaccination in migratory herds and pastoral checkposts.',
    pathogenType: 'Viral'
  }
];

// 30-Day Historical Surveillance Trend for Recharts
export const OUTBREAK_TREND_DATA: OutbreakTrendPoint[] = [
  { date: 'Aug 15', FMD: 18, LSD: 12, Brucellosis: 14, Anthrax: 3, PPR: 10 },
  { date: 'Aug 18', FMD: 22, LSD: 11, Brucellosis: 15, Anthrax: 4, PPR: 12 },
  { date: 'Aug 21', FMD: 27, LSD: 14, Brucellosis: 16, Anthrax: 3, PPR: 13 },
  { date: 'Aug 24', FMD: 31, LSD: 13, Brucellosis: 19, Anthrax: 5, PPR: 14 },
  { date: 'Aug 27', FMD: 38, LSD: 15, Brucellosis: 22, Anthrax: 4, PPR: 15 },
  { date: 'Aug 30', FMD: 46, LSD: 17, Brucellosis: 26, Anthrax: 6, PPR: 18 },
  { date: 'Sep 02', FMD: 55, LSD: 16, Brucellosis: 29, Anthrax: 5, PPR: 20 },
  { date: 'Sep 05', FMD: 68, LSD: 18, Brucellosis: 34, Anthrax: 7, PPR: 22 },
  { date: 'Sep 08', FMD: 84, LSD: 19, Brucellosis: 39, Anthrax: 8, PPR: 25 },
  { date: 'Sep 11', FMD: 102, LSD: 21, Brucellosis: 44, Anthrax: 9, PPR: 27 },
  { date: 'Sep 13', FMD: 118, LSD: 22, Brucellosis: 48, Anthrax: 8, PPR: 29 }
];

export const DISTRICT_COMPARISON_DATA = [
  { district: 'Nagpur', cases: 64, mortality: 8, vaccination: 61 },
  { district: 'Pune', cases: 62, mortality: 7, vaccination: 61 },
  { district: 'Amravati', cases: 52, mortality: 5, vaccination: 64 },
  { district: 'Nashik', cases: 48, mortality: 4, vaccination: 54 },
  { district: 'Chandrapur', cases: 39, mortality: 4, vaccination: 66 },
  { district: 'Jalgaon', cases: 39, mortality: 3, vaccination: 67 },
  { district: 'Sambhajinagar', cases: 38, mortality: 3, vaccination: 68 },
  { district: 'Ahmednagar', cases: 37, mortality: 3, vaccination: 70 },
  { district: 'Wardha', cases: 34, mortality: 2, vaccination: 69 },
  { district: 'Yavatmal', cases: 32, mortality: 3, vaccination: 69 },
  { district: 'Solapur', cases: 29, mortality: 2, vaccination: 74 },
  { district: 'Akola', cases: 28, mortality: 2, vaccination: 70 }
];

export const RISK_FACTOR_BREAKDOWN = [
  { factor: 'Herd Mobility & Unscreened Transit', weight: '35%', score: 82, trend: '+14%', status: 'Elevated' },
  { factor: 'Vaccination Coverage Deficits (<85%)', weight: '25%', score: 78, trend: '+9%', status: 'Critical' },
  { factor: 'Post-Monsoon Moisture & Vector Surge', weight: '20%', score: 68, trend: '+12%', status: 'Elevated' },
  { factor: 'Delayed Syndromic Reporting (>48h)', weight: '12%', score: 58, trend: '-3%', status: 'Moderate' },
  { factor: 'Historical Soil & Environmental Reservoirs', weight: '8%', score: 52, trend: '0%', status: 'Monitoring' }
];
