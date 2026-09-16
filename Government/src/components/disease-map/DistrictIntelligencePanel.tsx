import type { DistrictData } from '@/types/government';
import { RiskBadge } from '@/components/common/RiskBadge';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  X,
  Syringe,
  ShieldCheck,
  Send,
  FileText,
  AlertTriangle,
  Activity,
  Phone
} from 'lucide-react';

interface DistrictIntelligencePanelProps {
  district: DistrictData | null;
  onClose: () => void;
  onCreateCampaign: (district: DistrictData) => void;
  onAssignTeam: (district: DistrictData) => void;
  onSendAdvisory: (district: DistrictData) => void;
  onExportReport: (district: DistrictData) => void;
}

export const DistrictIntelligencePanel: React.FC<DistrictIntelligencePanelProps> = ({
  district,
  onClose,
  onCreateCampaign,
  onAssignTeam,
  onSendAdvisory,
  onExportReport
}) => {
  if (!district) return null;

  return (
    <div className="h-full flex flex-col bg-white border-l border-[#E4EAF0] shadow-xl overflow-hidden transition-all duration-300">
      {/* Panel Top Header */}
      <div className="p-4 sm:p-5 border-b border-[#E4EAF0] bg-[#F7F9FB] flex items-start justify-between gap-3">
        <div className="space-y-1 min-w-0">
          <div className="flex items-center gap-2">
            <span className="text-[11px] font-bold text-[#1769AA] uppercase tracking-wider">
              {district.division} Division
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">{district.marathiName || district.name}</span>
          </div>
          <h2 className="text-xl font-bold text-[#18232B] tracking-tight truncate">
            {district.name} District Intelligence
          </h2>
          <div className="flex items-center gap-2 pt-1">
            <RiskBadge level={district.riskLevel} score={district.riskScore} />
            <span className="text-xs font-semibold text-[#667482] flex items-center gap-1">
              <Activity className="size-3.5" />
              Trend: <strong className={district.trend.startsWith('+') ? 'text-[#C94343]' : 'text-[#16845B]'}>{district.trend}</strong>
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

      {/* Main Content Area */}
      <div className="flex-1 overflow-y-auto p-4 sm:p-5 space-y-5 text-xs">
        {/* Quick Action Bar */}
        <div className="grid grid-cols-2 gap-2">
          <Button
            variant="default"
            size="sm"
            onClick={() => onCreateCampaign(district)}
            className="gap-1.5 bg-[#12304A] hover:bg-[#0d2336] text-[11px] h-8.5"
          >
            <Syringe className="size-3.5" />
            Create Campaign
          </Button>

          <Button
            variant="teal"
            size="sm"
            onClick={() => onAssignTeam(district)}
            className="gap-1.5 text-[11px] h-8.5"
          >
            <ShieldCheck className="size-3.5" />
            Assign Team
          </Button>

          <Button
            variant="secondary"
            size="sm"
            onClick={() => onSendAdvisory(district)}
            className="gap-1.5 text-[11px] h-8.5"
          >
            <Send className="size-3.5" />
            Send Advisory
          </Button>

          <Button
            variant="secondary"
            size="sm"
            onClick={() => onExportReport(district)}
            className="gap-1.5 text-[11px] h-8.5"
          >
            <FileText className="size-3.5" />
            Export Dossier
          </Button>
        </div>

        {/* 4 Clinical KPI Tiles */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
          <div className="p-3 rounded-xl bg-[#F7F9FB] border border-[#E4EAF0] space-y-0.5">
            <span className="text-[10px] font-semibold text-[#667482] uppercase tracking-wider">
              Suspected Disease
            </span>
            <div className="font-bold text-xs text-[#18232B] truncate" title={district.suspectedDisease}>
              {district.suspectedDisease.split('(')[0]}
            </div>
          </div>

          <div className="p-3 rounded-xl bg-[#F7F9FB] border border-[#E4EAF0] space-y-0.5">
            <span className="text-[10px] font-semibold text-[#667482] uppercase tracking-wider">
              Active Cases
            </span>
            <div className="font-bold text-base text-[#18232B]">
              {district.activeCases}
            </div>
          </div>

          <div className="p-3 rounded-xl bg-[#F7F9FB] border border-[#E4EAF0] space-y-0.5">
            <span className="text-[10px] font-semibold text-[#667482] uppercase tracking-wider">
              Mortality
            </span>
            <div className="font-bold text-base text-[#C94343]">
              {district.mortality}
            </div>
          </div>

          <div className="p-3 rounded-xl bg-[#F7F9FB] border border-[#E4EAF0] space-y-0.5">
            <span className="text-[10px] font-semibold text-[#667482] uppercase tracking-wider">
              Affected Villages
            </span>
            <div className="font-bold text-base text-[#18232B]">
              {district.affectedVillages}
            </div>
          </div>
        </div>

        {/* Vaccination Coverage & Gap Indicator */}
        <div className="p-4 rounded-xl bg-white border border-[#E4EAF0] space-y-2.5 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="font-bold text-xs text-[#18232B]">Vaccination Coverage Status</span>
            <span className="font-bold text-sm text-[#087F73]">{district.vaccinationCoverage}%</span>
          </div>
          <div className="h-2 w-full bg-[#EAF3FB] rounded-full overflow-hidden">
            <div
              className={`h-full rounded-full transition-all duration-500 ${
                district.vaccinationCoverage >= 80
                  ? 'bg-[#16845B]'
                  : district.vaccinationCoverage >= 65
                  ? 'bg-[#D99A18]'
                  : 'bg-[#C94343]'
              }`}
              style={{ width: `${district.vaccinationCoverage}%` }}
            />
          </div>
          <div className="flex items-center justify-between text-[11px]">
            <span className="text-[#667482]">Target Threshold: 85% Mandate</span>
            <span className="font-semibold text-[#C94343]">{district.vaccinationGap}</span>
          </div>
        </div>

        {/* Risk Summary */}
        <div className="space-y-1.5">
          <h3 className="font-bold text-xs text-[#12304A] uppercase tracking-wider">
            Risk Summary & Clinical Assessment
          </h3>
          <p className="p-3 rounded-xl bg-[#F7F9FB] border border-[#E4EAF0] text-xs text-[#18232B] leading-relaxed">
            {district.riskSummary}
          </p>
        </div>

        {/* Why This Area Is At Risk */}
        <div className="space-y-2">
          <h3 className="font-bold text-xs text-[#12304A] uppercase tracking-wider">
            Why This Area Is At Risk
          </h3>
          <ul className="space-y-1.5">
            {district.whyAtRisk.map((reason, idx) => (
              <li
                key={idx}
                className="p-2.5 rounded-lg bg-white border border-[#E4EAF0] flex items-start gap-2 text-xs text-[#18232B]"
              >
                <AlertTriangle className="size-3.5 text-[#D99A18] shrink-0 mt-0.5" />
                <span className="leading-relaxed">{reason}</span>
              </li>
            ))}
          </ul>
        </div>

        {/* Recommended Government Action */}
        <div className="p-3.5 rounded-xl bg-[#EAF7F2] border border-[#16845B]/20 space-y-1">
          <span className="font-bold text-xs text-[#16845B] uppercase tracking-wider block">
            Recommended Government Action
          </span>
          <p className="text-xs text-[#18232B] leading-relaxed">
            {district.recommendedAction}
          </p>
        </div>

        {/* Assigned Veterinary Teams */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <h3 className="font-bold text-xs text-[#12304A] uppercase tracking-wider">
              Assigned Veterinary Units ({district.assignedTeams.length})
            </h3>
            <button
              onClick={() => onAssignTeam(district)}
              className="text-[11px] font-semibold text-[#1769AA] hover:underline cursor-pointer"
            >
              + Deploy Unit
            </button>
          </div>
          <div className="space-y-1.5">
            {district.assignedTeams.map((team) => (
              <div
                key={team.id}
                className="p-3 rounded-lg border border-[#E4EAF0] bg-white flex items-center justify-between gap-2"
              >
                <div className="space-y-0.5">
                  <div className="font-bold text-[#18232B]">{team.leadVet}</div>
                  <div className="text-[11px] text-[#667482]">{team.mobileUnit}</div>
                </div>
                <div className="text-right space-y-1">
                  <Badge
                    variant={
                      team.status === 'Field Deployed'
                        ? 'low'
                        : team.status === 'En Route'
                        ? 'moderate'
                        : 'secondary'
                    }
                    className="text-[10px] py-0 px-1.5"
                  >
                    {team.status}
                  </Badge>
                  <div className="text-[10px] text-[#667482] flex items-center gap-1">
                    <Phone className="size-2.5" />
                    {team.contact}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Field Reports */}
        <div className="space-y-2">
          <h3 className="font-bold text-xs text-[#12304A] uppercase tracking-wider">
            Recent Syndromic Field Reports
          </h3>
          <div className="divide-y divide-[#E4EAF0] border border-[#E4EAF0] rounded-xl bg-white overflow-hidden">
            {district.recentReports.map((report, idx) => (
              <div key={idx} className="p-3 flex items-center justify-between gap-2 text-xs">
                <div className="space-y-0.5">
                  <div className="font-semibold text-[#18232B]">{report.village}</div>
                  <div className="text-[11px] text-[#667482]">{report.syndrome}</div>
                </div>
                <div className="text-right shrink-0">
                  <span className="font-bold text-[#C94343]">{report.cattleAffected} cases</span>
                  <span className="block text-[10px] text-[#667482]">{report.date}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
