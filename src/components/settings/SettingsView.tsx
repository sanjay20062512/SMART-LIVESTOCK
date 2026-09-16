import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import {
  Bell,
  Sliders,
  User,
  Check,
  CheckCircle2
} from 'lucide-react';

export const SettingsView: React.FC = () => {
  const [criticalThreshold, setCriticalThreshold] = useState('75');
  const [highThreshold, setHighThreshold] = useState('55');
  const [vaccinationTarget, setVaccinationTarget] = useState('85');
  const [autoSmsEnabled, setAutoSmsEnabled] = useState(true);
  const [labAutoSync, setLabAutoSync] = useState(true);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const handleSave = () => {
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 2000);
  };

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200 max-w-4xl">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#1769AA] uppercase tracking-wider">
              Administration & Policy
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">System Configuration</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight">
            Surveillance & Account Settings
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Calibrate algorithmic risk thresholds, manage rapid alert dispatch criteria, and review official officer credentials.
          </p>
        </div>

        <Button
          variant="default"
          size="sm"
          onClick={handleSave}
          className="gap-1.5 bg-[#12304A] hover:bg-[#0d2336] self-start sm:self-auto text-xs"
        >
          {savedSuccess ? (
            <>
              <CheckCircle2 className="size-4 text-emerald-400" />
              Settings Saved
            </>
          ) : (
            <>
              <Check className="size-4" />
              Save Configuration
            </>
          )}
        </Button>
      </div>

      {/* Official Officer Profile Card */}
      <Card className="border-[#E4EAF0] shadow-xs">
        <CardHeader className="pb-3 border-b border-[#E4EAF0] bg-[#F7F9FB]">
          <div className="flex items-center gap-2">
            <User className="size-4 text-[#1769AA]" />
            <CardTitle className="text-base font-bold text-[#18232B]">
              Government Officer Identity & Jurisdiction
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-5">
          <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
            <div className="size-14 rounded-2xl bg-[#12304A] text-white flex items-center justify-center font-bold text-lg shadow-sm shrink-0">
              RP
            </div>
            <div className="space-y-1 flex-1">
              <div className="flex items-center gap-2 flex-wrap">
                <span className="text-base font-bold text-[#18232B]">Dr. Rajesh Patil</span>
                <Badge variant="low" className="text-[10px]">Active State Officer</Badge>
              </div>
              <p className="text-xs text-[#667482]">
                Joint Director of Animal Husbandry (Epidemiological Surveillance)
              </p>
              <div className="text-[11px] text-[#1769AA] font-semibold flex items-center gap-2 pt-0.5">
                <span>Jurisdiction: All 36 Maharashtra Districts</span>
                <span>•</span>
                <span>HQ: Central Building, Pune</span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Surveillance Algorithm Risk Thresholds */}
      <Card className="border-[#E4EAF0] shadow-xs">
        <CardHeader className="pb-3 border-b border-[#E4EAF0] bg-[#F7F9FB]">
          <div className="flex items-center gap-2">
            <Sliders className="size-4 text-[#087F73]" />
            <CardTitle className="text-base font-bold text-[#18232B]">
              Epidemiological Scoring Thresholds
            </CardTitle>
          </div>
          <CardDescription className="text-xs text-[#667482]">
            Define the clinical metric cutoff points for automatic risk tier escalations on the GIS map.
          </CardDescription>
        </CardHeader>
        <CardContent className="p-5 space-y-4 text-xs">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="font-semibold text-[#18232B] block mb-1">
                Critical Risk Cutoff Score (%)
              </label>
              <Input
                type="number"
                value={criticalThreshold}
                onChange={(e) => setCriticalThreshold(e.target.value)}
                min="50"
                max="95"
              />
              <span className="text-[11px] text-[#667482] mt-1 block">
                Triggers automatic rapid response task generation.
              </span>
            </div>

            <div>
              <label className="font-semibold text-[#18232B] block mb-1">
                High Risk Cutoff Score (%)
              </label>
              <Input
                type="number"
                value={highThreshold}
                onChange={(e) => setHighThreshold(e.target.value)}
                min="30"
                max="75"
              />
              <span className="text-[11px] text-[#667482] mt-1 block">
                Flags district for veterinary audit and warning pills.
              </span>
            </div>

            <div>
              <label className="font-semibold text-[#18232B] block mb-1">
                Mandatory Herd Coverage Target (%)
              </label>
              <Input
                type="number"
                value={vaccinationTarget}
                onChange={(e) => setVaccinationTarget(e.target.value)}
                min="70"
                max="100"
              />
              <span className="text-[11px] text-[#667482] mt-1 block">
                Standard state mandate for protective herd immunity.
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Automated Advisory & Diagnostic Sync Settings */}
      <Card className="border-[#E4EAF0] shadow-xs">
        <CardHeader className="pb-3 border-b border-[#E4EAF0] bg-[#F7F9FB]">
          <div className="flex items-center gap-2">
            <Bell className="size-4 text-[#D99A18]" />
            <CardTitle className="text-base font-bold text-[#18232B]">
              Automated Alert Routing & Integrations
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-5 space-y-3 text-xs">
          <label className="flex items-start gap-3 p-3 rounded-xl border border-[#E4EAF0] cursor-pointer hover:bg-[#F7F9FB]">
            <input
              type="checkbox"
              checked={autoSmsEnabled}
              onChange={(e) => setAutoSmsEnabled(e.target.checked)}
              className="mt-0.5 rounded text-[#087F73] focus:ring-[#087F73]"
            />
            <div className="space-y-0.5">
              <span className="font-bold text-[#18232B] block">
                Auto-Broadcast Containment Advisory on Critical Risk Detection
              </span>
              <span className="text-[#667482] leading-relaxed block">
                Automatically dispatch SMS notifications to dairy co-operative leaders when a taluka enters Critical tier.
              </span>
            </div>
          </label>

          <label className="flex items-start gap-3 p-3 rounded-xl border border-[#E4EAF0] cursor-pointer hover:bg-[#F7F9FB]">
            <input
              type="checkbox"
              checked={labAutoSync}
              onChange={(e) => setLabAutoSync(e.target.checked)}
              className="mt-0.5 rounded text-[#087F73] focus:ring-[#087F73]"
            />
            <div className="space-y-0.5">
              <span className="font-bold text-[#18232B] block">
                Live Synchronization with State Animal Disease Diagnostic Labs (Pune)
              </span>
              <span className="text-[#667482] leading-relaxed block">
                Automatically ingest serological PCR and bacterial culture confirmations from regional labs.
              </span>
            </div>
          </label>
        </CardContent>
      </Card>
    </div>
  );
};
