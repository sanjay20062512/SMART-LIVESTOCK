import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { KpiCard } from '@/components/common/KpiCard';
import { RiskBadge } from '@/components/common/RiskBadge';
import { MAHARASHTRA_DISTRICTS } from '@/data/districts';
import { INITIAL_GOVT_ALERTS } from '@/data/alerts';
import { CreateCampaignModal } from '@/components/modals/CreateCampaignModal';
import { AssignTeamModal } from '@/components/modals/AssignTeamModal';
import {
  Activity,
  AlertTriangle,
  Syringe,
  ClipboardList,
  Map as MapIcon,
  Plus,
  ShieldCheck,
  ArrowRight,
  Clock
} from 'lucide-react';

export const OverviewView: React.FC = () => {
  const navigate = useNavigate();
  const [isCampaignModalOpen, setIsCampaignModalOpen] = useState(false);
  const [isAssignTeamOpen, setIsAssignTeamOpen] = useState(false);

  // Derive high-risk districts
  const highRiskDistricts = MAHARASHTRA_DISTRICTS.filter(
    (d) => d.riskScore >= 56
  );

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200">
      {/* Top Banner & Command Center Actions */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#087F73] uppercase tracking-wider">
              State Surveillance Bureau
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Q3 Live Cycle</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight mt-0.5">
            Government Health Command Center
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-1">
            Monitor animal-health risks, vaccination progress, and field response across Maharashtra.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          <Button
            variant="secondary"
            size="sm"
            onClick={() => navigate('/disease-intelligence')}
            className="gap-1.5"
          >
            <MapIcon className="size-4 text-[#1769AA]" />
            View Disease Map
          </Button>

          <Button
            variant="default"
            size="sm"
            onClick={() => setIsCampaignModalOpen(true)}
            className="gap-1.5 bg-[#12304A] hover:bg-[#0d2336]"
          >
            <Plus className="size-4" />
            Create Campaign
          </Button>

          <Button
            variant="teal"
            size="sm"
            onClick={() => setIsAssignTeamOpen(true)}
            className="gap-1.5"
          >
            <ShieldCheck className="size-4" />
            Assign Response Team
          </Button>
        </div>
      </div>

      {/* Four Premium KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard
          title="Active Disease Cases"
          value="1,284"
          subtitle="Confirmed syndromic reports"
          trend="+8.4% from last week"
          trendDirection="up"
          isAlertTrend={true}
          icon={Activity}
          statusColor="red"
          onClick={() => navigate('/outbreak-monitoring')}
        />

        <KpiCard
          title="High-Risk Districts"
          value={highRiskDistricts.length.toString()}
          subtitle="3 newly flagged this week"
          trend="Nagpur & Pune critical"
          trendDirection="up"
          isAlertTrend={true}
          icon={AlertTriangle}
          statusColor="amber"
          badgeText="Surge Area"
          onClick={() => navigate('/disease-intelligence')}
        />

        <KpiCard
          title="Vaccination Coverage"
          value="68.5%"
          subtitle="State target: 85% mandate"
          trend="+5.2% this month"
          trendDirection="up"
          isAlertTrend={false}
          icon={Syringe}
          statusColor="teal"
          onClick={() => navigate('/campaigns')}
        />

        <KpiCard
          title="Pending Government Actions"
          value="24"
          subtitle="7 urgent field response tasks"
          trend="3 awaiting lab confirm"
          trendDirection="neutral"
          icon={ClipboardList}
          statusColor="navy"
          onClick={() => navigate('/response')}
        />
      </div>

      {/* Wide Card: Maharashtra Health Pulse */}
      <Card className="border-[#E4EAF0] shadow-xs overflow-hidden">
        <CardHeader className="bg-[#F7F9FB] border-b border-[#E4EAF0] pb-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
            <div>
              <div className="flex items-center gap-2">
                <CardTitle className="text-base sm:text-lg font-bold text-[#18232B]">
                  Maharashtra Health Pulse
                </CardTitle>
                <Badge variant="high" className="text-[11px] font-semibold">
                  Elevated State Vigilance
                </Badge>
              </div>
              <CardDescription className="text-xs text-[#667482] mt-0.5">
                Consolidated state epidemiological risk index and response readiness snapshot.
              </CardDescription>
            </div>
            {/* Horizontal Status Summary */}
            <div className="flex items-center p-1 rounded-lg bg-white border border-[#E4EAF0] text-xs font-semibold">
              <span className="px-2.5 py-1 text-[#667482]">Stable</span>
              <span className="px-2.5 py-1 text-[#667482]">Monitoring</span>
              <span className="px-2.5 py-1 rounded-md bg-[#FFF5D6] text-[#B87A04] shadow-xs">
                Elevated
              </span>
              <span className="px-2.5 py-1 text-[#667482]">Critical</span>
            </div>
          </div>
        </CardHeader>

        <CardContent className="p-6 space-y-6">
          {/* Status Metrics Bar */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4 divide-y sm:divide-y-0 sm:divide-x divide-[#E4EAF0]">
            <div className="space-y-1">
              <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
                Overall State Risk
              </span>
              <div className="text-xl font-bold text-[#D99A18]">58 / 100</div>
              <span className="text-[11px] text-[#667482]">Elevated threshold</span>
            </div>

            <div className="sm:pl-4 space-y-1 pt-3 sm:pt-0">
              <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
                Total Reported Cases
              </span>
              <div className="text-xl font-bold text-[#18232B]">1,284</div>
              <span className="text-[11px] text-[#C94343] font-semibold">+8.4% weekly</span>
            </div>

            <div className="sm:pl-4 space-y-1 pt-3 sm:pt-0">
              <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
                High-Risk Districts
              </span>
              <div className="text-xl font-bold text-[#C94343]">{highRiskDistricts.length}</div>
              <span className="text-[11px] text-[#667482]">Across 5 divisions</span>
            </div>

            <div className="sm:pl-4 space-y-1 pt-3 sm:pt-0">
              <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
                Vaccination Coverage
              </span>
              <div className="text-xl font-bold text-[#087F73]">68.5%</div>
              <span className="text-[11px] text-[#16845B] font-semibold">+5.2% monthly</span>
            </div>

            <div className="sm:pl-4 space-y-1 pt-3 sm:pt-0">
              <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
                Mortality Reports
              </span>
              <div className="text-xl font-bold text-[#18232B]">43</div>
              <span className="text-[11px] text-[#16845B] font-semibold">-4% trend</span>
            </div>

            <div className="sm:pl-4 space-y-1 pt-3 sm:pt-0">
              <span className="text-[11px] font-semibold text-[#667482] uppercase tracking-wider block">
                Active Response Teams
              </span>
              <div className="text-xl font-bold text-[#1769AA]">19 Units</div>
              <span className="text-[11px] text-[#1769AA] font-semibold">100% Deployed</span>
            </div>
          </div>

          {/* Progress Indicators */}
          <div className="space-y-4 pt-4 border-t border-[#E4EAF0]">
            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold text-[#18232B]">
                  State Vaccination Mandate Progress (Target: 85%)
                </span>
                <span className="font-bold text-[#087F73]">68.5%</span>
              </div>
              <div className="h-2.5 w-full bg-[#EAF3FB] rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-[#087F73] to-[#16845B] rounded-full transition-all duration-500"
                  style={{ width: '68.5%' }}
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold text-[#18232B]">
                  Veterinary Task Resolution Index (30-Day Rate)
                </span>
                <span className="font-bold text-[#1769AA]">79.2%</span>
              </div>
              <div className="h-2.5 w-full bg-[#EAF3FB] rounded-full overflow-hidden">
                <div
                  className="h-full bg-[#1769AA] rounded-full transition-all duration-500"
                  style={{ width: '79.2%' }}
                />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Two-Column Grid: High Priority Districts & Urgent Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Flagged High-Risk Districts List */}
        <Card className="border-[#E4EAF0] shadow-xs">
          <CardHeader className="pb-3 border-b border-[#E4EAF0] flex flex-row items-center justify-between">
            <div>
              <CardTitle className="text-base font-bold text-[#18232B]">
                High-Risk Districts Requiring Containment
              </CardTitle>
              <CardDescription className="text-xs text-[#667482]">
                Ranked by syndromic risk score and vaccination deficit.
              </CardDescription>
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate('/disease-intelligence')}
              className="text-xs text-[#1769AA] gap-1"
            >
              Interactive Map <ArrowRight className="size-3.5" />
            </Button>
          </CardHeader>
          <CardContent className="p-0 divide-y divide-[#E4EAF0]">
            {highRiskDistricts.slice(0, 5).map((d) => (
              <div
                key={d.id}
                onClick={() => navigate(`/disease-intelligence?district=${d.id}`)}
                className="p-4 hover:bg-[#F7F9FB] transition-colors flex items-center justify-between gap-3 cursor-pointer group"
              >
                <div className="space-y-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-sm text-[#18232B] group-hover:text-[#1769AA] transition-colors">
                      {d.name}
                    </span>
                    <span className="text-xs text-[#667482]">({d.division})</span>
                    <RiskBadge level={d.riskLevel} score={d.riskScore} />
                  </div>
                  <div className="flex items-center gap-3 text-xs text-[#667482]">
                    <span>Primary: <strong>{d.suspectedDisease.split('(')[0]}</strong></span>
                    <span>Cases: <strong>{d.activeCases}</strong></span>
                    <span>Coverage: <strong>{d.vaccinationCoverage}%</strong></span>
                  </div>
                </div>

                <Button variant="outline" size="sm" className="shrink-0 text-xs h-8">
                  Inspect
                </Button>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Live Alerts & Action Triggers Feed */}
        <Card className="border-[#E4EAF0] shadow-xs">
          <CardHeader className="pb-3 border-b border-[#E4EAF0] flex flex-row items-center justify-between">
            <div>
              <CardTitle className="text-base font-bold text-[#18232B]">
                Recent Government Health Advisories & Alerts
              </CardTitle>
              <CardDescription className="text-xs text-[#667482]">
                Critical outbreak flags and containment milestones.
              </CardDescription>
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate('/alerts')}
              className="text-xs text-[#1769AA] gap-1"
            >
              All Alerts <ArrowRight className="size-3.5" />
            </Button>
          </CardHeader>
          <CardContent className="p-0 divide-y divide-[#E4EAF0]">
            {INITIAL_GOVT_ALERTS.slice(0, 4).map((alert) => (
              <div key={alert.id} className="p-4 hover:bg-[#F7F9FB] transition-colors space-y-1.5">
                <div className="flex items-center justify-between gap-2">
                  <div className="flex items-center gap-2 min-w-0">
                    <Badge
                      variant={
                        alert.priority === 'Critical'
                          ? 'critical'
                          : alert.priority === 'High'
                          ? 'high'
                          : 'moderate'
                      }
                      className="text-[10px] py-0 px-1.5 shrink-0"
                    >
                      {alert.priority}
                    </Badge>
                    <span className="font-bold text-xs text-[#18232B] truncate">
                      {alert.title}
                    </span>
                  </div>
                  <span className="text-[11px] text-[#667482] flex items-center gap-1 shrink-0">
                    <Clock className="size-3" />
                    {alert.time}
                  </span>
                </div>
                <p className="text-xs text-[#667482] leading-relaxed line-clamp-2">
                  {alert.description}
                </p>
                <div className="pt-1 flex items-center justify-between">
                  <span className="text-[11px] font-semibold text-[#1769AA]">
                    {alert.district}
                  </span>
                  <button
                    onClick={() => navigate('/alerts')}
                    className="text-xs font-semibold text-[#087F73] hover:underline cursor-pointer"
                  >
                    {alert.actionText} →
                  </button>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>

      {/* Modals */}
      <CreateCampaignModal
        isOpen={isCampaignModalOpen}
        onClose={() => setIsCampaignModalOpen(false)}
        onCreated={() => {
          navigate('/campaigns');
        }}
      />

      <AssignTeamModal
        isOpen={isAssignTeamOpen}
        onClose={() => setIsAssignTeamOpen(false)}
        districtName="Nagpur"
        taskTitle="Emergency Ring Containment Taskforce"
        onAssigned={() => {
          navigate('/response');
        }}
      />
    </div>
  );
};
