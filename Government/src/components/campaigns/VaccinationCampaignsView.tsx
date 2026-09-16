import React, { useState } from 'react';
import { VACCINATION_CAMPAIGNS, CAMPAIGN_SUMMARY_METRICS } from '@/data/campaigns';
import type { VaccinationCampaign } from '@/types/government';
import { CreateCampaignModal } from '@/components/modals/CreateCampaignModal';
import { AssignTeamModal } from '@/components/modals/AssignTeamModal';
import { SendAdvisoryModal } from '@/components/modals/SendAdvisoryModal';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Plus,
  Calendar,
  AlertCircle,
  ShieldCheck,
  Send,
  Check
} from 'lucide-react';

export const VaccinationCampaignsView: React.FC = () => {
  const [campaigns, setCampaigns] = useState<VaccinationCampaign[]>(VACCINATION_CAMPAIGNS);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isAssignModalOpen, setIsAssignModalOpen] = useState(false);
  const [isAdvisoryModalOpen, setIsAdvisoryModalOpen] = useState(false);
  const [activeDistrict, setActiveDistrict] = useState('Pune');
  const [selectedCampaign, setSelectedCampaign] = useState<VaccinationCampaign | null>(null);

  const handleCampaignCreated = (newCamp: VaccinationCampaign) => {
    setCampaigns((prev) => [newCamp, ...prev]);
  };

  const handleMarkComplete = (id: string) => {
    setCampaigns((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status: 'Completed' } : c))
    );
  };

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#087F73] uppercase tracking-wider">
              State Prophylaxis Bureau
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Target Herd Immunity: 85%</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight">
            Vaccination Campaign Command Center
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Manage prophylactic immunisation drives, deploy biologicals, and eliminate district immunity deficits.
          </p>
        </div>

        <Button
          variant="default"
          size="sm"
          onClick={() => {
            setActiveDistrict('Pune');
            setIsCreateModalOpen(true);
          }}
          className="gap-1.5 bg-[#12304A] hover:bg-[#0d2336] self-start md:self-auto"
        >
          <Plus className="size-4" />
          Create Campaign
        </Button>
      </div>

      {/* Top 5 Metrics Row */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3 sm:gap-4">
        <div className="p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-xs space-y-1">
          <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
            Active Campaigns
          </span>
          <div className="text-2xl font-bold text-[#12304A]">
            {campaigns.filter((c) => c.status === 'Active').length}
          </div>
          <span className="text-[11px] text-[#16845B] font-medium">Statewide deployed</span>
        </div>

        <div className="p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-xs space-y-1">
          <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
            Animals Targeted
          </span>
          <div className="text-2xl font-bold text-[#18232B]">
            {CAMPAIGN_SUMMARY_METRICS.animalsTargeted.toLocaleString()}
          </div>
          <span className="text-[11px] text-[#667482]">Reserved biologicals</span>
        </div>

        <div className="p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-xs space-y-1">
          <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
            Animals Vaccinated
          </span>
          <div className="text-2xl font-bold text-[#087F73]">
            {CAMPAIGN_SUMMARY_METRICS.animalsVaccinated.toLocaleString()}
          </div>
          <span className="text-[11px] text-[#16845B] font-medium">Field verified</span>
        </div>

        <div className="p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-xs space-y-1">
          <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
            Overall Coverage
          </span>
          <div className="text-2xl font-bold text-[#1769AA]">
            {CAMPAIGN_SUMMARY_METRICS.overallCoverage}%
          </div>
          <span className="text-[11px] text-[#D99A18] font-medium">Target: 85% mandate</span>
        </div>

        <div className="p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-xs space-y-1 col-span-2 sm:col-span-1">
          <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
            Pending Villages
          </span>
          <div className="text-2xl font-bold text-[#C94343]">
            {CAMPAIGN_SUMMARY_METRICS.pendingVillages}
          </div>
          <span className="text-[11px] text-[#C94343] font-medium">Under active drive</span>
        </div>
      </div>

      {/* Disease Risk vs Vaccination Coverage Gap Callout Card */}
      <div className="p-5 rounded-xl bg-[#FFF5D6] border border-[#D99A18]/30 flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-xs">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <AlertCircle className="size-4 text-[#D99A18] shrink-0" />
            <span className="font-bold text-sm text-[#18232B]">
              Critical Immunity Deficit Detected: Pune & Nagpur Belts
            </span>
          </div>
          <p className="text-xs text-[#667482] leading-relaxed">
            District risk: <strong>78%</strong> | Vaccination coverage: <strong>61.2%</strong> | Vaccination gap detected: <strong>23.8% deficit</strong> | Recommended priority: <strong>Critical</strong>
          </p>
        </div>

        <Button
          variant="default"
          size="sm"
          onClick={() => {
            setActiveDistrict('Pune');
            setIsCreateModalOpen(true);
          }}
          className="bg-[#12304A] hover:bg-[#0d2336] shrink-0 text-xs"
        >
          Create Campaign for This District
        </Button>
      </div>

      {/* Campaign Cards List */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-base font-bold text-[#18232B] tracking-tight">
            Active & Scheduled State Drives ({campaigns.length})
          </h2>
          <span className="text-xs text-[#667482]">
            Data synchronized with State Veterinary Biologicals Institute
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {campaigns.map((camp) => (
            <Card
              key={camp.id}
              className="border-[#E4EAF0] shadow-xs hover:border-[#CBD5E1] transition-all space-y-3"
            >
              <CardContent className="p-5 space-y-4">
                {/* Card Top */}
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-sm text-[#18232B]">{camp.name}</span>
                      <Badge
                        variant={
                          camp.priority === 'Critical'
                            ? 'critical'
                            : camp.priority === 'High'
                            ? 'high'
                            : 'secondary'
                        }
                        className="text-[10px] py-0 px-1.5"
                      >
                        {camp.priority} Priority
                      </Badge>
                    </div>
                    <span className="text-xs font-semibold text-[#1769AA] block mt-0.5">
                      {camp.targetDistrict} District ({camp.blocks.join(', ')})
                    </span>
                    <span className="text-[11px] text-[#667482] block">
                      Target Disease: {camp.disease} • {camp.animalSpecies}
                    </span>
                  </div>

                  <Badge
                    variant={camp.status === 'Completed' ? 'low' : 'secondary'}
                    className="shrink-0 text-xs"
                  >
                    {camp.status}
                  </Badge>
                </div>

                {/* Progress Bar */}
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-[#667482]">
                      Progress: <strong>{camp.vaccinatedAnimals.toLocaleString()}</strong> of{' '}
                      <strong>{camp.targetAnimals.toLocaleString()}</strong> animals
                    </span>
                    <span className="font-bold text-[#087F73] text-sm">
                      {camp.coveragePercentage}%
                    </span>
                  </div>
                  <div className="h-2 w-full bg-[#EAF3FB] rounded-full overflow-hidden">
                    <div
                      className={`h-full rounded-full transition-all duration-500 ${
                        camp.coveragePercentage >= 80
                          ? 'bg-[#16845B]'
                          : camp.coveragePercentage >= 60
                          ? 'bg-[#087F73]'
                          : 'bg-[#D99A18]'
                      }`}
                      style={{ width: `${camp.coveragePercentage}%` }}
                    />
                  </div>
                </div>

                {/* Village Breakdown Count */}
                <div className="grid grid-cols-3 gap-2 p-2.5 rounded-lg bg-[#F7F9FB] text-xs">
                  <div>
                    <span className="text-[#667482] block text-[10px]">Target Villages</span>
                    <strong className="font-bold text-[#18232B]">{camp.targetVillagesCount}</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[10px]">Completed</span>
                    <strong className="font-bold text-[#16845B]">{camp.completedVillagesCount}</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[10px]">Pending</span>
                    <strong className="font-bold text-[#C94343]">{camp.pendingVillagesCount}</strong>
                  </div>
                </div>

                {/* Dates & Actions */}
                <div className="pt-2 border-t border-[#E4EAF0] flex flex-wrap items-center justify-between gap-2 text-xs">
                  <span className="text-[#667482] flex items-center gap-1 text-[11px]">
                    <Calendar className="size-3.5" />
                    {camp.startDate} to {camp.endDate}
                  </span>

                  <div className="flex items-center gap-1.5">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => {
                        setSelectedCampaign(camp);
                        setActiveDistrict(camp.targetDistrict);
                        setIsAssignModalOpen(true);
                      }}
                      className="h-8 text-xs gap-1"
                    >
                      <ShieldCheck className="size-3.5" />
                      Assign Team
                    </Button>

                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => {
                        setSelectedCampaign(camp);
                        setActiveDistrict(camp.targetDistrict);
                        setIsAdvisoryModalOpen(true);
                      }}
                      className="h-8 text-xs gap-1"
                    >
                      <Send className="size-3.5" />
                      Advisory
                    </Button>

                    {camp.status !== 'Completed' && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleMarkComplete(camp.id)}
                        className="h-8 text-xs text-[#16845B] hover:text-[#16845B] hover:bg-[#EAF7F2] gap-1"
                      >
                        <Check className="size-3.5" />
                        Complete
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Modals */}
      <CreateCampaignModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
        initialDistrict={activeDistrict}
        onCreated={handleCampaignCreated}
      />

      <AssignTeamModal
        isOpen={isAssignModalOpen}
        onClose={() => setIsAssignModalOpen(false)}
        districtName={activeDistrict}
        taskTitle={selectedCampaign?.name || 'Vaccination Campaign Deployment'}
        onAssigned={() => {}}
      />

      <SendAdvisoryModal
        isOpen={isAdvisoryModalOpen}
        onClose={() => setIsAdvisoryModalOpen(false)}
        districtName={activeDistrict}
        diseaseName={selectedCampaign?.disease || 'Foot-and-Mouth Disease'}
        onSent={() => {}}
      />
    </div>
  );
};
