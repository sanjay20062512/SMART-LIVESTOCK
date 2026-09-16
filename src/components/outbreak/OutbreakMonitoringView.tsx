import React, { useState } from 'react';
import {
  OUTBREAK_SIGNALS,
  OUTBREAK_TREND_DATA,
  DISTRICT_COMPARISON_DATA,
  RISK_FACTOR_BREAKDOWN
} from '@/data/outbreaks';
import { RiskBadge } from '@/components/common/RiskBadge';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip as RechartsTooltip,
  ResponsiveContainer,
  Legend
} from 'recharts';
import {
  AlertTriangle,
  TrendingUp,
  CheckCircle2
} from 'lucide-react';

export const OutbreakMonitoringView: React.FC = () => {
  const [activeTab, setActiveTab] = useState('overview');
  const [selectedDiseaseFilter, setSelectedDiseaseFilter] = useState('All');

  const filteredSignals = OUTBREAK_SIGNALS.filter((sig) => {
    if (selectedDiseaseFilter === 'All') return true;
    return sig.diseaseName.toLowerCase().includes(selectedDiseaseFilter.toLowerCase());
  });

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#C94343] uppercase tracking-wider">
              Surveillance Bio-Intelligence
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Real-Time Early Warning</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight">
            Outbreak Monitoring & Early Warning
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Identify emerging transmission clusters, track 30-day syndromic growth curves, and assess risk factor weights.
          </p>
        </div>

        {/* Filter */}
        <div className="flex items-center gap-2">
          <select
            value={selectedDiseaseFilter}
            onChange={(e) => setSelectedDiseaseFilter(e.target.value)}
            className="h-9 px-3 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
          >
            <option value="All">All Pathogens</option>
            <option value="Foot-and-Mouth">Foot-and-Mouth Disease (FMD)</option>
            <option value="Brucellosis">Brucellosis</option>
            <option value="Haemorrhagic">Haemorrhagic Septicaemia (HS)</option>
            <option value="Anthrax">Anthrax</option>
            <option value="Peste">PPR (Small Ruminants)</option>
          </select>
        </div>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="bg-[#EAF3FB]/70 p-1 border border-[#E4EAF0]">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="trends">Disease Trends (30-Day)</TabsTrigger>
          <TabsTrigger value="comparison">District Comparison</TabsTrigger>
          <TabsTrigger value="risk-factors">Risk Factors</TabsTrigger>
        </TabsList>

        {/* TAB 1: OVERVIEW */}
        <TabsContent value="overview" className="space-y-6">
          {/* Quick Metrics Bar */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <Card className="border-[#E4EAF0]">
              <CardContent className="p-5 flex items-center justify-between">
                <div className="space-y-1">
                  <span className="text-xs font-semibold text-[#667482] uppercase tracking-wider block">
                    Emerging Outbreak Signals
                  </span>
                  <div className="text-2xl font-bold text-[#C94343]">7 Active Clusters</div>
                  <span className="text-[11px] text-[#667482]">2 Critical in Nagpur & Pune</span>
                </div>
                <div className="size-11 rounded-xl bg-[#FDECEC] text-[#C94343] flex items-center justify-center border border-[#C94343]/20">
                  <AlertTriangle className="size-5" />
                </div>
              </CardContent>
            </Card>

            <Card className="border-[#E4EAF0]">
              <CardContent className="p-5 flex items-center justify-between">
                <div className="space-y-1">
                  <span className="text-xs font-semibold text-[#667482] uppercase tracking-wider block">
                    Multi-Pathogen Surge Rate
                  </span>
                  <div className="text-2xl font-bold text-[#D99A18]">+14.2% Growth</div>
                  <span className="text-[11px] text-[#C94343] font-medium">FMD velocity accelerating</span>
                </div>
                <div className="size-11 rounded-xl bg-[#FFF5D6] text-[#B87A04] flex items-center justify-center border border-[#D99A18]/30">
                  <TrendingUp className="size-5" />
                </div>
              </CardContent>
            </Card>

            <Card className="border-[#E4EAF0]">
              <CardContent className="p-5 flex items-center justify-between">
                <div className="space-y-1">
                  <span className="text-xs font-semibold text-[#667482] uppercase tracking-wider block">
                    Containment Readiness
                  </span>
                  <div className="text-2xl font-bold text-[#16845B]">100% Deployed</div>
                  <span className="text-[11px] text-[#16845B] font-medium">19 Rapid Response Teams active</span>
                </div>
                <div className="size-11 rounded-xl bg-[#EAF7F2] text-[#16845B] flex items-center justify-center border border-[#16845B]/20">
                  <CheckCircle2 className="size-5" />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Outbreak Signals Grid */}
          <div className="space-y-3">
            <h2 className="text-base font-bold text-[#18232B] tracking-tight">
              Active Outbreak Dossiers & Emerging Signals
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {filteredSignals.map((signal) => (
                <Card
                  key={signal.id}
                  className="border-[#E4EAF0] shadow-xs hover:border-[#CBD5E1] transition-all"
                >
                  <CardContent className="p-5 space-y-3">
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-sm text-[#18232B]">
                            {signal.diseaseName}
                          </span>
                          <Badge variant="outline" className="text-[10px] py-0">
                            {signal.pathogenType}
                          </Badge>
                        </div>
                        <span className="text-xs font-semibold text-[#1769AA] block mt-0.5">
                          {signal.affectedDistrict} District Cluster
                        </span>
                      </div>
                      <RiskBadge level={signal.riskLevel} />
                    </div>

                    <div className="grid grid-cols-3 gap-2 p-2.5 rounded-lg bg-[#F7F9FB] text-xs">
                      <div>
                        <span className="text-[#667482] block text-[10px]">Active Cases</span>
                        <strong className="text-sm font-bold text-[#18232B]">{signal.cases}</strong>
                      </div>
                      <div>
                        <span className="text-[#667482] block text-[10px]">Weekly Velocity</span>
                        <strong className="text-sm font-bold text-[#C94343]">+{signal.trendPercentage}%</strong>
                      </div>
                      <div>
                        <span className="text-[#667482] block text-[10px]">Flagged Date</span>
                        <strong className="text-xs font-semibold text-[#18232B]">{signal.detectionDate}</strong>
                      </div>
                    </div>

                    <div className="p-2.5 rounded-lg bg-[#EAF3FB]/70 border border-[#1769AA]/20 text-xs">
                      <span className="font-bold text-[#12304A] block mb-0.5">
                        Recommended Next Action:
                      </span>
                      <p className="text-[#667482] leading-relaxed">
                        {signal.recommendedNextAction}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </TabsContent>

        {/* TAB 2: DISEASE TRENDS */}
        <TabsContent value="trends" className="space-y-4">
          <Card className="border-[#E4EAF0] shadow-xs">
            <CardHeader className="border-b border-[#E4EAF0] pb-4">
              <CardTitle className="text-base font-bold text-[#18232B]">
                30-Day Multi-Pathogen Case Progression Curve
              </CardTitle>
              <CardDescription className="text-xs text-[#667482]">
                Active daily syndromic cases aggregated across all veterinary dispensary records in Maharashtra.
              </CardDescription>
            </CardHeader>
            <CardContent className="p-6">
              <div className="h-80 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={OUTBREAK_TREND_DATA}>
                    <defs>
                      <linearGradient id="fmdColor" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#C94343" stopOpacity={0.4} />
                        <stop offset="95%" stopColor="#C94343" stopOpacity={0} />
                      </linearGradient>
                      <linearGradient id="bruColor" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#D99A18" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#D99A18" stopOpacity={0} />
                      </linearGradient>
                      <linearGradient id="lsdColor" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#1769AA" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#1769AA" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#E4EAF0" />
                    <XAxis dataKey="date" stroke="#667482" fontSize={11} tickLine={false} />
                    <YAxis stroke="#667482" fontSize={11} tickLine={false} />
                    <RechartsTooltip
                      contentStyle={{
                        backgroundColor: '#FFFFFF',
                        borderColor: '#E4EAF0',
                        borderRadius: '8px',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                        fontSize: '12px'
                      }}
                    />
                    <Legend wrapperStyle={{ fontSize: '12px', paddingTop: '12px' }} />
                    <Area
                      type="monotone"
                      dataKey="FMD"
                      name="Foot-and-Mouth (FMD)"
                      stroke="#C94343"
                      strokeWidth={2}
                      fillOpacity={1}
                      fill="url(#fmdColor)"
                    />
                    <Area
                      type="monotone"
                      dataKey="Brucellosis"
                      name="Brucellosis"
                      stroke="#D99A18"
                      strokeWidth={2}
                      fillOpacity={1}
                      fill="url(#bruColor)"
                    />
                    <Area
                      type="monotone"
                      dataKey="LSD"
                      name="Lumpy Skin (LSD)"
                      stroke="#1769AA"
                      strokeWidth={1.8}
                      fillOpacity={1}
                      fill="url(#lsdColor)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* TAB 3: DISTRICT COMPARISON */}
        <TabsContent value="comparison" className="space-y-4">
          <Card className="border-[#E4EAF0] shadow-xs">
            <CardHeader className="border-b border-[#E4EAF0] pb-4">
              <CardTitle className="text-base font-bold text-[#18232B]">
                District Epidemiological Comparison (Active Cases vs. Coverage)
              </CardTitle>
              <CardDescription className="text-xs text-[#667482]">
                Comparing reported cases against vaccination saturation across high-density livestock belts.
              </CardDescription>
            </CardHeader>
            <CardContent className="p-6">
              <div className="h-80 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={DISTRICT_COMPARISON_DATA} margin={{ top: 10, right: 10, left: 0, bottom: 20 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#E4EAF0" />
                    <XAxis
                      dataKey="district"
                      stroke="#667482"
                      fontSize={10.5}
                      tickLine={false}
                      angle={-25}
                      textAnchor="end"
                    />
                    <YAxis stroke="#667482" fontSize={11} tickLine={false} />
                    <RechartsTooltip
                      contentStyle={{
                        backgroundColor: '#FFFFFF',
                        borderColor: '#E4EAF0',
                        borderRadius: '8px',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                        fontSize: '12px'
                      }}
                    />
                    <Legend wrapperStyle={{ fontSize: '12px', paddingTop: '12px' }} />
                    <Bar dataKey="cases" name="Active Cases" fill="#12304A" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="mortality" name="Mortality Headcount" fill="#C94343" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="vaccination" name="Vaccination Coverage %" fill="#087F73" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* TAB 4: RISK FACTORS */}
        <TabsContent value="risk-factors" className="space-y-4">
          <Card className="border-[#E4EAF0] shadow-xs">
            <CardHeader className="border-b border-[#E4EAF0] pb-4">
              <CardTitle className="text-base font-bold text-[#18232B]">
                Epidemiological Risk Factor Analysis & Weighting
              </CardTitle>
              <CardDescription className="text-xs text-[#667482]">
                Key algorithmic variables driving the Maharashtra disease risk scoring engine.
              </CardDescription>
            </CardHeader>
            <CardContent className="p-6 space-y-4">
              <div className="divide-y divide-[#E4EAF0]">
                {RISK_FACTOR_BREAKDOWN.map((factor) => (
                  <div key={factor.factor} className="py-4 first:pt-0 last:pb-0 space-y-2">
                    <div className="flex items-center justify-between text-xs">
                      <div className="space-y-0.5">
                        <span className="font-bold text-sm text-[#18232B]">{factor.factor}</span>
                        <span className="text-[#667482] block">Algorithm Model Weight: {factor.weight}</span>
                      </div>
                      <div className="text-right space-y-1">
                        <Badge
                          variant={
                            factor.status === 'Critical'
                              ? 'critical'
                              : factor.status === 'Elevated'
                              ? 'high'
                              : 'moderate'
                          }
                          className="text-[11px]"
                        >
                          {factor.status} ({factor.score}/100)
                        </Badge>
                        <span className="block text-[11px] text-[#C94343] font-semibold">
                          {factor.trend}
                        </span>
                      </div>
                    </div>

                    <div className="h-2 w-full bg-[#EAF3FB] rounded-full overflow-hidden">
                      <div
                        className={`h-full rounded-full ${
                          factor.score >= 75
                            ? 'bg-[#C94343]'
                            : factor.score >= 60
                            ? 'bg-[#D99A18]'
                            : 'bg-[#16845B]'
                        }`}
                        style={{ width: `${factor.score}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};
