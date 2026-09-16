import type { ResponseTask } from '../types/government';

export const INITIAL_RESPONSE_TASKS: ResponseTask[] = [
  // Critical Priority
  {
    id: 'TASK-001',
    title: 'Emergency 10km Ring Vaccination & Quarantining',
    district: 'Nagpur',
    village: 'Kamptee Dairy Belt (Cluster 4)',
    diseaseConcern: 'Foot-and-Mouth Disease (FMD)',
    priority: 'Critical',
    assignedTeam: 'Nagpur Rapid Response 01 (Dr. Gajbhiye)',
    dueDate: '2026-09-14',
    status: 'In Progress',
    notes: '16 cattle presenting vesicular tongue erosions. Ring vaccination active in 5km inner perimeter.',
    reportedDate: '2026-09-12'
  },
  {
    id: 'TASK-002',
    title: 'Emergency Containment & Milk Tanker Disinfection',
    district: 'Pune',
    village: 'Uruli Kanchan Dairy Route',
    diseaseConcern: 'Foot-and-Mouth Disease (FMD)',
    priority: 'Critical',
    assignedTeam: 'Team Alpha (Dr. Deshmukh)',
    dueDate: '2026-09-14',
    status: 'In Progress',
    notes: 'Sodium carbonate foot dips installed at primary co-operative chilling station gates.',
    reportedDate: '2026-09-12'
  },
  {
    id: 'TASK-003',
    title: 'Investigate Sudden Bull Mortality & Spore Swabbing',
    district: 'Yavatmal',
    village: 'Wani Scrubland Border',
    diseaseConcern: 'Anthrax (Suspected)',
    priority: 'Critical',
    assignedTeam: 'Yavatmal RRT (Dr. Meshram)',
    dueDate: '2026-09-13',
    status: 'Awaiting Lab Result',
    notes: 'Blood smear shipped via cold chain to State Animal Disease Diagnostic Lab, Pune.',
    reportedDate: '2026-09-11'
  },

  // High Priority
  {
    id: 'TASK-004',
    title: 'Melghat Foothills Barrier Checkpost & Serum Collection',
    district: 'Amravati',
    village: 'Achalpur Foothill Hamlet',
    diseaseConcern: 'Foot-and-Mouth Disease (FMD)',
    priority: 'High',
    assignedTeam: 'Melghat 4x4 Van (Dr. Tayade)',
    dueDate: '2026-09-15',
    status: 'Assigned',
    notes: 'Prevent cattle from migrating into tiger reserve buffer areas during active outbreak.',
    reportedDate: '2026-09-11'
  },
  {
    id: 'TASK-005',
    title: 'Serological Screening of Bulk Milk Tanks & Bull Ring Tests',
    district: 'Nashik',
    village: 'Niphad Chilling Centre',
    diseaseConcern: 'Brucellosis',
    priority: 'High',
    assignedTeam: 'Nashik RRT 01 (Dr. Sonawane)',
    dueDate: '2026-09-16',
    status: 'In Progress',
    notes: 'MRT positive reactions recorded in 3 cooperative route collection tanks.',
    reportedDate: '2026-09-10'
  },
  {
    id: 'TASK-006',
    title: 'Floodplain Prophylactic Antibiotic & Vaccine Mobilization',
    district: 'Jalgaon',
    village: 'Bhusawal Tapi Floodplain',
    diseaseConcern: 'Haemorrhagic Septicaemia (HS)',
    priority: 'High',
    assignedTeam: 'Tapi Basin MVU (Dr. Chaudhari)',
    dueDate: '2026-09-16',
    status: 'Assigned',
    notes: 'Draft bullocks in 4 low-lying villages scheduled for immediate treatment.',
    reportedDate: '2026-09-10'
  },
  {
    id: 'TASK-007',
    title: 'Livestock Fair Sanitation & Inspection Checkpoints',
    district: 'Chhatrapati Sambhajinagar',
    village: 'Gangapur Weekly Mandi',
    diseaseConcern: 'Foot-and-Mouth Disease (FMD)',
    priority: 'High',
    assignedTeam: 'Sambhajinagar RRT (Dr. Kale)',
    dueDate: '2026-09-15',
    status: 'New',
    notes: 'Enforce entry permits and visual mouth/hoof inspections before auction entry.',
    reportedDate: '2026-09-12'
  },

  // Medium Priority
  {
    id: 'TASK-008',
    title: 'Migratory Sheep Flock Health Audit & Deworming',
    district: 'Solapur',
    village: 'Pandharpur South Pastures',
    diseaseConcern: 'Peste des Petits Ruminants (PPR)',
    priority: 'Medium',
    assignedTeam: 'Solapur MVU-01 (Dr. Jagtap)',
    dueDate: '2026-09-18',
    status: 'In Progress',
    notes: 'Targeting 8 nomadic dhangar shepherd encampments in dryland belt.',
    reportedDate: '2026-09-09'
  },
  {
    id: 'TASK-009',
    title: 'Soil Spore Neutralization & Deep Burial Supervision',
    district: 'Nandurbar',
    village: 'Dhadgaon Forest Edge',
    diseaseConcern: 'Anthrax',
    priority: 'Medium',
    assignedTeam: 'Satpura 4x4 Mobile Unit (Dr. Valvi)',
    dueDate: '2026-09-17',
    status: 'Completed',
    notes: 'Carcass buried 6 feet deep with quicklime per state bio-containment guidelines.',
    reportedDate: '2026-09-08'
  },
  {
    id: 'TASK-010',
    title: 'Vector Insect Fogging & Supportive Kit Distribution',
    district: 'Dhule',
    village: 'Shindkheda Rural',
    diseaseConcern: 'Lumpy Skin Disease (LSD)',
    priority: 'Medium',
    assignedTeam: 'Dhule MVU-01 (Dr. Deore)',
    dueDate: '2026-09-19',
    status: 'Assigned',
    notes: 'Provide village panchayat with pyrethroid sprays for community cattle sheds.',
    reportedDate: '2026-09-09'
  },

  // Monitoring Priority
  {
    id: 'TASK-011',
    title: '14-Day Post-Vaccination Syndromic Surveillance Window',
    district: 'Satara',
    village: 'Karad Rural Milk Belt',
    diseaseConcern: 'Routine Surveillance',
    priority: 'Monitoring',
    assignedTeam: 'Satara MVU-02 (Dr. Mane)',
    dueDate: '2026-09-22',
    status: 'In Progress',
    notes: 'Maintain zero-case verification log with 12 local dairy societies.',
    reportedDate: '2026-09-08'
  },
  {
    id: 'TASK-012',
    title: 'Interstate Highway Live Checkpoint Surveillance Audit',
    district: 'Thane',
    village: 'Bhiwandi Highway Octroi Post',
    diseaseConcern: 'Routine Surveillance',
    priority: 'Monitoring',
    assignedTeam: 'Thane Regional MVU (Dr. Bhoir)',
    dueDate: '2026-09-24',
    status: 'In Progress',
    notes: 'Inspect animal health certificates on cattle vehicles arriving via NH48.',
    reportedDate: '2026-09-07'
  }
];
