import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { X, ShieldCheck, UserCheck } from 'lucide-react';

interface AssignTeamModalProps {
  isOpen: boolean;
  onClose: () => void;
  districtName?: string;
  taskTitle?: string;
  onAssigned?: (teamName: string, leadVet: string) => void;
}

export const AssignTeamModal: React.FC<AssignTeamModalProps> = ({
  isOpen,
  onClose,
  districtName = 'Pune',
  taskTitle = 'Emergency Field Surveillance & Ring Containment',
  onAssigned
}) => {
  const [selectedTeam, setSelectedTeam] = useState('Team Alpha (Dr. Deshmukh)');
  const [dispatchInstructions, setDispatchInstructions] = useState(
    'Prioritize crossbred dairy clusters; coordinate with local dairy cooperative supervisors.'
  );

  if (!isOpen) return null;

  const handleConfirm = () => {
    if (onAssigned) {
      onAssigned(selectedTeam, selectedTeam.split('(')[1]?.replace(')', '') || 'Dr. Deshmukh');
    }
    onClose();
  };

  const availableTeams = [
    { name: 'Team Alpha (Dr. Deshmukh)', unit: 'Mobile Vet Van 01', availability: 'Available Now' },
    { name: 'Team Beta (Dr. Kadam)', unit: 'Mobile Vet Van 03', availability: 'Available Now' },
    { name: 'Rapid Response Taskforce (Dr. Ananya Joshi)', unit: 'RRT Pune Core 4x4', availability: 'En Route' },
    { name: 'Regional Mobile Veterinary Unit 04', unit: 'MVU Special Van', availability: 'Standby' }
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-[#12304A]/60 backdrop-blur-xs animate-in fade-in-0">
      <div className="bg-white rounded-2xl border border-[#E4EAF0] shadow-2xl w-full max-w-lg overflow-hidden flex flex-col">
        <div className="px-6 py-4 border-b border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
          <div className="flex items-center gap-2">
            <div className="size-8 rounded-lg bg-[#EAF3FB] text-[#1769AA] flex items-center justify-center">
              <ShieldCheck className="size-4" />
            </div>
            <div>
              <h2 className="text-base font-bold text-[#18232B] tracking-tight">
                Assign Veterinary Response Unit
              </h2>
              <span className="text-xs text-[#667482]">Target Location: {districtName} District</span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="size-8 rounded-lg text-[#667482] hover:text-[#18232B] hover:bg-[#E4EAF0] flex items-center justify-center transition-colors cursor-pointer"
          >
            <X className="size-4" />
          </button>
        </div>

        <div className="p-6 space-y-4 text-xs">
          <div className="p-3.5 rounded-xl bg-[#F7F9FB] border border-[#E4EAF0] space-y-1">
            <span className="text-[#667482] font-semibold text-[11px] uppercase tracking-wider block">
              Active Task / Outbreak Context
            </span>
            <span className="font-semibold text-sm text-[#18232B] block">{taskTitle}</span>
          </div>

          <div>
            <label className="font-semibold text-[#18232B] block mb-2">
              Select Certified Field Veterinary Roster
            </label>
            <div className="space-y-2">
              {availableTeams.map((t) => (
                <div
                  key={t.name}
                  onClick={() => setSelectedTeam(t.name)}
                  className={`p-3 rounded-xl border flex items-center justify-between cursor-pointer transition-all ${
                    selectedTeam === t.name
                      ? 'border-[#087F73] bg-[#EAF7F2] shadow-xs'
                      : 'border-[#E4EAF0] hover:bg-[#F7F9FB]'
                  }`}
                >
                  <div>
                    <div className="font-bold text-[#18232B]">{t.name}</div>
                    <div className="text-[#667482] text-[11px]">{t.unit}</div>
                  </div>
                  <Badge variant={t.availability === 'Available Now' ? 'low' : 'secondary'}>
                    {t.availability}
                  </Badge>
                </div>
              ))}
            </div>
          </div>

          <div>
            <label className="font-semibold text-[#18232B] block mb-1.5">
              Special Field Dispatch Directives
            </label>
            <Input
              value={dispatchInstructions}
              onChange={(e) => setDispatchInstructions(e.target.value)}
              placeholder="Enter special directives..."
            />
          </div>
        </div>

        <div className="px-6 py-4 border-t border-[#E4EAF0] flex items-center justify-end gap-2 bg-[#F7F9FB]">
          <Button variant="ghost" size="sm" onClick={onClose}>
            Cancel
          </Button>
          <Button variant="teal" size="sm" onClick={handleConfirm} className="gap-1.5">
            <UserCheck className="size-4" />
            Confirm Team Assignment
          </Button>
        </div>
      </div>
    </div>
  );
};
