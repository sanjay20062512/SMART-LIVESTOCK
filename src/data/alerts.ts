import type { GovtAlert } from '../types/government';

export const INITIAL_GOVT_ALERTS: GovtAlert[] = [
  {
    id: 'ALT-001',
    type: 'Outbreak',
    title: 'Critical Outbreak Alert: FMD Cluster Confirmed in Nagpur',
    district: 'Nagpur',
    time: '12 min ago',
    priority: 'Critical',
    isRead: false,
    resolved: false,
    actionText: 'Review Outbreak Dossier',
    description: '14 acute vesicular cases confirmed in Kamptee dairy belt. Viral load tests confirm Type O FMD pathogen.'
  },
  {
    id: 'ALT-002',
    type: 'Risk Escalation',
    title: 'Risk Escalation: Pune District Surpasses Critical Risk Threshold (78%)',
    district: 'Pune',
    time: '42 min ago',
    priority: 'Critical',
    isRead: false,
    resolved: false,
    actionText: 'Open District Intelligence',
    description: 'Surge of 16% in reported clinical syndromes across Haveli taluka. Vaccination coverage gap sits at 23.8%.'
  },
  {
    id: 'ALT-003',
    type: 'Lab Confirmation',
    title: 'Lab Confirmation: Anthrax Suspicion Samples Dispatched to Pune Lab',
    district: 'Yavatmal',
    time: '2 hours ago',
    priority: 'Critical',
    isRead: false,
    resolved: false,
    actionText: 'View Response Task',
    description: 'Sudden mortality of 2 bullocks in Wani scrubland. Smears sent to State Animal Disease Diagnostic Laboratory.'
  },
  {
    id: 'ALT-004',
    type: 'Campaign Due',
    title: 'Campaign Milestone: FMD Ring Drive in Pune Reaches 78% Target',
    district: 'Pune',
    time: '3 hours ago',
    priority: 'High',
    isRead: true,
    resolved: false,
    actionText: 'Inspect Campaign Progress',
    description: '6,630 animals vaccinated across 11 villages. 7 remote villages remain pending in high-density dairy belt.'
  },
  {
    id: 'ALT-005',
    type: 'Risk Escalation',
    title: 'Epidemiological Signal: High HS Cluster Detected in Tapi Floodplain',
    district: 'Jalgaon',
    time: '5 hours ago',
    priority: 'High',
    isRead: true,
    resolved: false,
    actionText: 'View District Status',
    description: 'Respiratory distress reported in 39 working bullocks in low-lying river areas following unseasonal moisture.'
  },
  {
    id: 'ALT-006',
    type: 'Advisory',
    title: 'Advisory Issued: State-Wide Biosecurity Guidelines for Cattle Markets',
    district: 'Maharashtra State',
    time: 'Yesterday',
    priority: 'Medium',
    isRead: true,
    resolved: true,
    actionText: 'Download Advisory PDF',
    description: 'Mandatory sodium carbonate wash requirement published for all district weekly animal trade grounds.'
  }
];
