import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import type { DistrictRiskData } from '@/types/disease';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  X,
  Syringe,
  Users,
  Send,
  FileDown,
  CheckCircle2,
  TrendingUp,
  TrendingDown,
  ChevronRight,
  Info
} from 'lucide-react';

interface DistrictDetailsPanelProps {
  district: DistrictRiskData | null;
  onClose: () => void;
  onCreateCampaign: (district: DistrictRiskData) => void;
  onAssignTeam: (district: DistrictRiskData) => void;
  onSendAdvisory: (district: DistrictRiskData) => void;
  onExportSummary: (district: DistrictRiskData) => void;
  onViewFullDetails?: (district: DistrictRiskData) => void;
}

export const DistrictDetailsPanel: React.FC<DistrictDetailsPanelProps> = ({
  district,
  onClose,
  onCreateCampaign,
  onAssignTeam,
  onSendAdvisory,
  onExportSummary,
  onViewFullDetails
}) => {
  if (!district) return null;

  const getRiskBadgeStyles = (level: string) => {
    switch (level) {
      case 'Critical':
        return 'bg-[#FDECEC] text-[#C94343] border-[#C94343]/30';
      case 'High':
        return 'bg-[#FFF2EA] text-[#C2410C] border-[#C2410C]/30';
      case 'Moderate':
        return 'bg-[#FFF5D6] text-[#B45309] border-[#D99A18]/30';
      case 'Low':
      default:
        return 'bg-[#EAF7F2] text-[#16845B] border-[#16845B]/30';
    }
  };

  const isPositiveTrend = district.trend.startsWith('+');

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: 20 }}
        transition={{ duration: 0.25, ease: 'easeOut' }}
        className="h-full flex flex-col bg-white border-l border-[#E4EAF0] shadow-xl overflow-hidden w-full"
      >
        {/* Panel Header */}
        <div className="p-4 sm:p-5 border-b border-[#E4EAF0] bg-[#F8FAFC] flex items-start justify-between gap-3">
          <div className="space-y-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-bold text-[#1769AA] uppercase tracking-wider">
                {district.division} Division
              </span>
              <span className="text-xs text-[#667482]">•</span>
              <span className="text-xs font-semibold text-[#667482]">{district.marathiName || district.districtName}</span>
            </div>
            <h2 className="text-xl sm:text-2xl font-bold text-[#18232B] tracking-tight truncate">
              {district.districtName}
            </h2>
            <div className="flex flex-wrap items-center gap-2 pt-0.5">
              <Badge
                variant="outline"
                className={`text-xs font-bold px-2.5 py-0.5 ${getRiskBadgeStyles(district.riskLevel)}`}
              >
                {district.riskLevel} Risk • {district.riskPercentage}%
              </Badge>
              <span className="text-xs font-semibold text-[#667482] flex items-center gap-1">
                {isPositiveTrend ? (
                  <TrendingUp className="size-3.5 text-[#C94343]" />
                ) : (
                  <TrendingDown className="size-3.5 text-[#16845B]" />
                )}
                Trend: <strong className={isPositiveTrend ? 'text-[#C94343]' : 'text-[#16845B]'}>{district.trend}</strong>
              </span>
            </div>
          </div>

          <button
            onClick={onClose}
            className="size-8 rounded-lg text-[#667482] hover:text-[#18232B] hover:bg-[#E4EAF0] flex items-center justify-center transition-colors cursor-pointer shrink-0"
            aria-label="Close intelligence panel"
          >
            <X className="size-5" />
          </button>
        </div>

        {/* Quick Action Bar (Top Primaries) */}
        <div className="p-3 sm:px-5 bg-white border-b border-[#E4EAF0] grid grid-cols-2 gap-2">
          <Button
            size="sm"
            onClick={() => onCreateCampaign(district)}
            className="bg-[#087F73] hover:bg-[#06635A] text-white text-xs font-semibold h-9 shadow-2xs gap-1.5 cursor-pointer"
          >
            <Syringe className="size-3.5" />
            <span>Create Campaign</span>
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={() => onAssignTeam(district)}
            className="border-[#12304A] text-[#12304A] hover:bg-[#12304A] hover:text-white text-xs font-semibold h-9 shadow-2xs gap-1.5 cursor-pointer"
          >
            <Users className="size-3.5" />
            <span>Assign Vet Team</span>
          </Button>
        </div>

        {/* Scrollable Intelligence Body */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-5 space-y-4 text-xs">
          {/* Key Metrics 4-Box Grid */}
          <div className="grid grid-cols-2 gap-2.5">
            <div className="p-3 rounded-xl bg-[#F8FAFC] border border-[#E4EAF0]">
              <span className="text-[10px] uppercase font-bold text-[#667482] tracking-wider block">
                Primary Suspected Disease
              </span>
              <p className="text-xs font-bold text-[#18232B] mt-1 line-clamp-2">
                {district.primaryDisease}
              </p>
            </div>

            <div className="p-3 rounded-xl bg-[#F8FAFC] border border-[#E4EAF0]">
              <span className="text-[10px] uppercase font-bold text-[#667482] tracking-wider block">
                Active Cases / Mortality
              </span>
              <div className="flex items-baseline gap-2 mt-1">
                <span className="text-base font-extrabold text-[#C94343]">
                  {district.activeCases}
                </span>
                <span className="text-xs text-[#667482]">
                  / {district.mortalityReports} deaths
                </span>
              </div>
            </div>

            <div className="p-3 rounded-xl bg-[#F8FAFC] border border-[#E4EAF0]">
              <span className="text-[10px] uppercase font-bold text-[#667482] tracking-wider block">
                Vaccination Coverage
              </span>
              <div className="flex items-baseline justify-between mt-1">
                <span className={`text-base font-extrabold ${district.vaccinationCoverage >= 80 ? 'text-[#16845B]' : district.vaccinationCoverage >= 65 ? 'text-[#D99A18]' : 'text-[#C94343]'}`}>
                  {district.vaccinationCoverage}%
                </span>
                <span className="text-[10px] text-[#667482]">Target: 85%</span>
              </div>
              <div className="w-full bg-[#E4EAF0] h-1.5 rounded-full mt-1.5 overflow-hidden">
                <div
                  className={`h-full rounded-full ${district.vaccinationCoverage >= 80 ? 'bg-[#16845B]' : district.vaccinationCoverage >= 65 ? 'bg-[#D99A18]' : 'bg-[#C94343]'}`}
                  style={{ width: `${Math.min(district.vaccinationCoverage, 100)}%` }}
                />
              </div>
            </div>

            <div className="p-3 rounded-xl bg-[#F8FAFC] border border-[#E4EAF0]">
              <span className="text-[10px] uppercase font-bold text-[#667482] tracking-wider block">
                Affected Villages
              </span>
              <div className="flex items-baseline gap-1 mt-1">
                <span className="text-base font-extrabold text-[#18232B]">
                  {district.affectedVillages}
                </span>
                <span className="text-xs text-[#667482]">villages monitored</span>
              </div>
              <span className="text-[10px] text-[#667482] block mt-1 truncate">
                {district.totalLivestock ? `${(district.totalLivestock / 100000).toFixed(1)}L livestock` : ''}
              </span>
            </div>
          </div>

          {/* Recommended Government Action Card (Highlighted) */}
          <div className="p-3.5 rounded-xl bg-[#EAF7F2] border border-[#087F73]/30 space-y-1.5">
            <div className="flex items-center gap-1.5 text-[#087F73] font-bold text-xs">
              <CheckCircle2 className="size-4 shrink-0" />
              <span>Recommended Government Action</span>
            </div>
            <p className="text-xs text-[#12304A] font-medium leading-relaxed">
              {district.recommendedAction}
            </p>
            <div className="pt-1 text-[11px] text-[#667482] font-medium">
              {district.vaccinationGap}
            </div>
          </div>

          {/* Risk Explanation */}
          <div className="p-3.5 rounded-xl bg-white border border-[#E4EAF0] space-y-2">
            <div className="flex items-center gap-1.5 text-[#18232B] font-bold text-xs">
              <Info className="size-3.5 text-[#1769AA]" />
              <span>Risk Explanation</span>
            </div>
            <p className="text-xs text-[#667482] leading-relaxed">
              {district.riskExplanation}
            </p>

            {district.whyAtRisk && district.whyAtRisk.length > 0 && (
              <ul className="space-y-1 pt-1 border-t border-[#E4EAF0]/60 text-[11px] text-[#18232B]">
                {district.whyAtRisk.map((reason, idx) => (
                  <li key={idx} className="flex items-start gap-1.5">
                    <span className="text-[#C94343] font-bold mt-0.5">•</span>
                    <span>{reason}</span>
                  </li>
                ))}
              </ul>
            )}
          </div>

          {/* Active Field Teams & Deployments */}
          {district.assignedTeams && district.assignedTeams.length > 0 && (
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="font-bold text-xs text-[#18232B]">
                  Active Field Veterinary Teams ({district.assignedTeams.length})
                </span>
                <span className="text-[10px] text-[#087F73] font-semibold">GPS Active</span>
              </div>
              <div className="space-y-1.5">
                {district.assignedTeams.map((team) => (
                  <div
                    key={team.id}
                    className="p-2.5 rounded-lg border border-[#E4EAF0] bg-[#F8FAFC] flex items-center justify-between"
                  >
                    <div>
                      <span className="font-bold text-xs text-[#18232B] block">
                        {team.leadVet}
                      </span>
                      <span className="text-[10px] text-[#667482]">
                        {team.mobileUnit} • {team.contact}
                      </span>
                    </div>
                    <Badge
                      variant="outline"
                      className={`text-[10px] font-semibold ${team.status === 'Field Deployed' ? 'bg-[#EAF7F2] text-[#16845B] border-[#16845B]/30' : 'bg-[#FFF5D6] text-[#B45309] border-[#D99A18]/30'}`}
                    >
                      {team.status}
                    </Badge>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Recent Syndromic Alerts */}
          {district.recentReports && district.recentReports.length > 0 && (
            <div className="space-y-2">
              <span className="font-bold text-xs text-[#18232B] block">
                Recent Village Syndromic Reports
              </span>
              <div className="space-y-1.5">
                {district.recentReports.map((report, idx) => (
                  <div
                    key={idx}
                    className="p-2 rounded-lg border border-[#E4EAF0] bg-white flex items-center justify-between text-[11px]"
                  >
                    <div>
                      <span className="font-semibold text-[#18232B]">{report.village}</span>
                      <span className="text-[#667482] block text-[10px]">{report.syndrome}</span>
                    </div>
                    <div className="text-right">
                      <span className="font-bold text-[#C94343]">{report.cattleAffected} affected</span>
                      <span className="text-[10px] text-[#667482] block">{report.date}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Bottom Actions Bar */}
        <div className="p-3 sm:p-4 border-t border-[#E4EAF0] bg-[#F8FAFC] space-y-2">
          <div className="grid grid-cols-2 gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => onSendAdvisory(district)}
              className="text-xs h-8 border-[#E4EAF0] gap-1.5 cursor-pointer"
            >
              <Send className="size-3.5 text-[#1769AA]" />
              <span>Send Advisory</span>
            </Button>

            <Button
              variant="outline"
              size="sm"
              onClick={() => onExportSummary(district)}
              className="text-xs h-8 border-[#E4EAF0] gap-1.5 cursor-pointer"
            >
              <FileDown className="size-3.5 text-[#087F73]" />
              <span>Export Summary</span>
            </Button>
          </div>

          {onViewFullDetails && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onViewFullDetails(district)}
              className="w-full text-xs h-8 text-[#1769AA] hover:text-[#0c4a6e] hover:bg-[#EAF3FB] font-semibold gap-1 cursor-pointer"
            >
              <span>View Full District Surveillance History</span>
              <ChevronRight className="size-3.5" />
            </Button>
          )}
        </div>
      </motion.div>
    </AnimatePresence>
  );
};
