import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { MAHARASHTRA_DISTRICTS } from '@/data/districts';
import type { VaccinationCampaign } from '@/types/government';
import {
  X,
  CheckCircle2,
  ChevronRight,
  ChevronLeft,
  Calendar,
  Syringe,
  MapPin,
  AlertCircle
} from 'lucide-react';

interface CreateCampaignModalProps {
  isOpen: boolean;
  onClose: () => void;
  onCreated: (campaign: VaccinationCampaign) => void;
  initialDistrict?: string;
  initialDisease?: string;
  initialPriority?: 'Critical' | 'High' | 'Medium';
}

export const CreateCampaignModal: React.FC<CreateCampaignModalProps> = ({
  isOpen,
  onClose,
  onCreated,
  initialDistrict = 'Pune',
  initialDisease = 'Foot-and-Mouth Disease (FMD)',
  initialPriority = 'High'
}) => {
  const [step, setStep] = useState(1);
  const [selectedDistrict, setSelectedDistrict] = useState(initialDistrict);
  const [selectedBlocks, setSelectedBlocks] = useState('Haveli, Shirur, Baramati');
  const [targetVillages, setTargetVillages] = useState('16');
  const [selectedDisease, setSelectedDisease] = useState(initialDisease);
  const [targetAnimals, setTargetAnimals] = useState('8500');
  const [animalSpecies, setAnimalSpecies] = useState('Cattle & Buffalo');
  const [startDate, setStartDate] = useState('2026-09-15');
  const [endDate, setEndDate] = useState('2026-10-15');
  const [priority, setPriority] = useState<'Critical' | 'High' | 'Medium'>(initialPriority);
  const [campaignName, setCampaignName] = useState(
    `${selectedDistrict} ${selectedDisease.split(' ')[0]} Ring Drive`
  );

  if (!isOpen) return null;

  const districtData = MAHARASHTRA_DISTRICTS.find(
    (d) => d.name.toLowerCase() === selectedDistrict.toLowerCase()
  ) || MAHARASHTRA_DISTRICTS[0];

  const handleLaunch = () => {
    const newCamp: VaccinationCampaign = {
      id: `CAMP-MH-${Math.floor(100 + Math.random() * 900)}`,
      name: campaignName || `${selectedDistrict} Animal Health Campaign`,
      disease: selectedDisease,
      targetDistrict: selectedDistrict,
      blocks: selectedBlocks.split(',').map((b) => b.trim()),
      targetVillages: `${targetVillages} villages`,
      animalSpecies: animalSpecies,
      startDate: startDate,
      endDate: endDate,
      targetAnimals: parseInt(targetAnimals) || 5000,
      vaccinatedAnimals: 0,
      coveragePercentage: 0,
      status: 'Active',
      priority: priority,
      targetVillagesCount: parseInt(targetVillages) || 12,
      completedVillagesCount: 0,
      pendingVillagesCount: parseInt(targetVillages) || 12
    };
    onCreated(newCamp);
    onClose();
  };

  const stepsList = [
    'District',
    'Blocks & Villages',
    'Disease / Vaccine',
    'Target Animals',
    'Timeline',
    'Priority',
    'Review'
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-[#12304A]/60 backdrop-blur-xs animate-in fade-in-0">
      <div className="bg-white rounded-2xl border border-[#E4EAF0] shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
        {/* Modal Header */}
        <div className="px-6 py-4 border-b border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-xs font-semibold uppercase tracking-wider text-[#1769AA]">
                Government Campaign Wizard
              </span>
              <Badge variant="outline" className="text-[11px] font-medium py-0">
                Step {step} of 7
              </Badge>
            </div>
            <h2 className="text-lg font-bold text-[#18232B] tracking-tight">
              Create Vaccination Campaign
            </h2>
          </div>
          <button
            onClick={onClose}
            className="size-8 rounded-lg text-[#667482] hover:text-[#18232B] hover:bg-[#E4EAF0] flex items-center justify-center transition-colors cursor-pointer"
          >
            <X className="size-4" />
          </button>
        </div>

        {/* Horizontal Step Indicator */}
        <div className="px-6 py-3 border-b border-[#E4EAF0] bg-white overflow-x-auto">
          <div className="flex items-center gap-2 min-w-max">
            {stepsList.map((st, idx) => {
              const stNum = idx + 1;
              const isPassed = step > stNum;
              const isCurrent = step === stNum;
              return (
                <div key={st} className="flex items-center gap-2">
                  <div
                    className={`size-6 rounded-full flex items-center justify-center text-xs font-bold transition-all ${
                      isPassed
                        ? 'bg-[#16845B] text-white'
                        : isCurrent
                        ? 'bg-[#12304A] text-white ring-2 ring-[#087F73]/30'
                        : 'bg-[#E4EAF0] text-[#667482]'
                    }`}
                  >
                    {isPassed ? <CheckCircle2 className="size-3.5" /> : stNum}
                  </div>
                  <span
                    className={`text-xs font-medium ${
                      isCurrent ? 'text-[#12304A] font-semibold' : 'text-[#667482]'
                    }`}
                  >
                    {st}
                  </span>
                  {idx < stepsList.length - 1 && (
                    <div className="w-4 h-px bg-[#E4EAF0]" />
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Modal Body */}
        <div className="p-6 overflow-y-auto flex-1 space-y-4">
          {/* STEP 1: District */}
          {step === 1 && (
            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Select Maharashtra District
                </label>
                <select
                  value={selectedDistrict}
                  onChange={(e) => {
                    setSelectedDistrict(e.target.value);
                    setCampaignName(`${e.target.value} ${selectedDisease.split(' ')[0]} Drive`);
                  }}
                  className="w-full h-10 px-3 rounded-lg border border-[#E4EAF0] bg-white text-sm text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
                >
                  {MAHARASHTRA_DISTRICTS.map((d) => (
                    <option key={d.id} value={d.name}>
                      {d.name} ({d.division} Division) — Risk: {d.riskScore}%
                    </option>
                  ))}
                </select>
              </div>

              {/* District Context Card */}
              <div className="p-4 rounded-xl bg-[#EAF3FB]/70 border border-[#1769AA]/20 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-[#12304A] flex items-center gap-1.5">
                    <MapPin className="size-3.5 text-[#1769AA]" />
                    {districtData.name} Epidemiological Profile
                  </span>
                  <Badge variant={districtData.riskScore >= 75 ? 'critical' : 'high'}>
                    Risk: {districtData.riskScore}%
                  </Badge>
                </div>
                <p className="text-xs text-[#667482] leading-relaxed">
                  {districtData.riskSummary}
                </p>
                <div className="pt-2 flex flex-wrap gap-4 text-xs font-medium text-[#18232B]">
                  <span>Active Cases: <strong>{districtData.activeCases}</strong></span>
                  <span>Vaccination Coverage: <strong>{districtData.vaccinationCoverage}%</strong></span>
                  <span className="text-[#C94343] font-semibold">{districtData.vaccinationGap}</span>
                </div>
              </div>
            </div>
          )}

          {/* STEP 2: Blocks and Villages */}
          {step === 2 && (
            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Target Talukas / Blocks (comma-separated)
                </label>
                <Input
                  value={selectedBlocks}
                  onChange={(e) => setSelectedBlocks(e.target.value)}
                  placeholder="e.g. Haveli, Shirur, Baramati"
                />
                <span className="text-[11px] text-[#667482] mt-1 block">
                  Priority administrative blocks requiring ring containment.
                </span>
              </div>
              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Number of Target Villages
                </label>
                <Input
                  type="number"
                  value={targetVillages}
                  onChange={(e) => setTargetVillages(e.target.value)}
                  min="1"
                  max="120"
                />
              </div>
            </div>
          )}

          {/* STEP 3: Disease / Vaccine */}
          {step === 3 && (
            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Select Target Disease / Vaccine
                </label>
                <select
                  value={selectedDisease}
                  onChange={(e) => {
                    setSelectedDisease(e.target.value);
                    setCampaignName(`${selectedDistrict} ${e.target.value.split(' ')[0]} Drive`);
                  }}
                  className="w-full h-10 px-3 rounded-lg border border-[#E4EAF0] bg-white text-sm text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
                >
                  <option value="Foot-and-Mouth Disease (FMD)">Foot-and-Mouth Disease (FMD) — Trivalent Vaccine</option>
                  <option value="Brucellosis">Brucellosis — Strain 19 / Rev 1 Live Attenuated</option>
                  <option value="Haemorrhagic Septicaemia (HS)">Haemorrhagic Septicaemia (HS) — Oil Adjuvant / Alum</option>
                  <option value="Anthrax">Anthrax — Live Spore Vaccine</option>
                  <option value="Peste des Petits Ruminants (PPR)">PPR — Sungri 96 Vaccine</option>
                  <option value="Lumpy Skin Disease (LSD)">Lumpy Skin Disease (LSD) — Goat Pox Heterologous</option>
                </select>
              </div>

              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Campaign Title
                </label>
                <Input
                  value={campaignName}
                  onChange={(e) => setCampaignName(e.target.value)}
                  placeholder="e.g. Pune FMD Emergency Ring Drive"
                />
              </div>
            </div>
          )}

          {/* STEP 4: Target Animals */}
          {step === 4 && (
            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Target Animal Species
                </label>
                <select
                  value={animalSpecies}
                  onChange={(e) => setAnimalSpecies(e.target.value)}
                  className="w-full h-10 px-3 rounded-lg border border-[#E4EAF0] bg-white text-sm text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
                >
                  <option value="Cattle & Buffalo">Cattle & Buffalo (Bovine Belt)</option>
                  <option value="Crossbred Dairy Cattle">Crossbred Dairy Cattle Only</option>
                  <option value="Female Calves (4-8 months)">Female Calves (4-8 months) — S19</option>
                  <option value="Sheep & Goat">Sheep & Goat (Small Ruminants)</option>
                  <option value="Draft Working Bullocks">Draft Working Bullocks</option>
                </select>
              </div>

              <div>
                <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                  Target Animal Population Headcount
                </label>
                <Input
                  type="number"
                  value={targetAnimals}
                  onChange={(e) => setTargetAnimals(e.target.value)}
                  min="100"
                  step="500"
                />
                <span className="text-[11px] text-[#667482] mt-1 block">
                  Cold chain doses will be reserved from State Veterinary Biologicals Institute, Pune.
                </span>
              </div>
            </div>
          )}

          {/* STEP 5: Timeline */}
          {step === 5 && (
            <div className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                    Campaign Start Date
                  </label>
                  <Input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                    Target Completion Date
                  </label>
                  <Input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                  />
                </div>
              </div>

              <div className="p-3.5 rounded-lg bg-[#EAF7F2] border border-[#16845B]/20 text-xs text-[#16845B] flex items-center gap-2">
                <Calendar className="size-4 shrink-0" />
                <span>Recommended campaign window is 30 days to ensure protective herd immunity.</span>
              </div>
            </div>
          )}

          {/* STEP 6: Priority */}
          {step === 6 && (
            <div className="space-y-4">
              <label className="text-xs font-semibold text-[#18232B] block mb-1.5">
                Assign Campaign Priority Level
              </label>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { level: 'Critical', desc: 'Active outbreak, ring vaccination within 24h' },
                  { level: 'High', desc: 'Elevated syndromic signals or <65% coverage' },
                  { level: 'Medium', desc: 'Routine pre-seasonal buffer drive' }
                ].map((item) => (
                  <button
                    key={item.level}
                    type="button"
                    onClick={() => setPriority(item.level as any)}
                    className={`p-3.5 rounded-xl border text-left transition-all cursor-pointer ${
                      priority === item.level
                        ? 'border-[#12304A] bg-[#12304A] text-white shadow-md'
                        : 'border-[#E4EAF0] bg-white text-[#18232B] hover:bg-[#F7F9FB]'
                    }`}
                  >
                    <span className="font-bold text-sm block">{item.level}</span>
                    <span
                      className={`text-[11px] leading-tight block mt-1 ${
                        priority === item.level ? 'text-white/80' : 'text-[#667482]'
                      }`}
                    >
                      {item.desc}
                    </span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* STEP 7: Review and Launch */}
          {step === 7 && (
            <div className="space-y-4">
              <div className="p-4 rounded-xl border border-[#E4EAF0] bg-[#F7F9FB] space-y-3 text-xs">
                <div className="flex items-center justify-between pb-2 border-b border-[#E4EAF0]">
                  <span className="font-bold text-sm text-[#18232B]">{campaignName}</span>
                  <Badge variant={priority === 'Critical' ? 'critical' : priority === 'High' ? 'high' : 'moderate'}>
                    {priority} Priority
                  </Badge>
                </div>
                <div className="grid grid-cols-2 gap-3 text-[#18232B]">
                  <div>
                    <span className="text-[#667482] block text-[11px]">Target District</span>
                    <strong>{selectedDistrict}</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[11px]">Disease / Vaccine</span>
                    <strong>{selectedDisease}</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[11px]">Target Animals</span>
                    <strong>{parseInt(targetAnimals).toLocaleString()} heads ({animalSpecies})</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[11px]">Villages & Blocks</span>
                    <strong>{targetVillages} villages across {selectedBlocks}</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[11px]">Timeline</span>
                    <strong>{startDate} to {endDate}</strong>
                  </div>
                  <div>
                    <span className="text-[#667482] block text-[11px]">State Authorization</span>
                    <strong className="text-[#16845B]">Govt of Maharashtra Animal Husbandry</strong>
                  </div>
                </div>
              </div>

              <div className="p-3 rounded-lg bg-[#FFF5D6] border border-[#D99A18]/30 text-xs text-[#B87A04] flex items-center gap-2">
                <AlertCircle className="size-4 shrink-0" />
                <span>Launching will generate field response tasks for assigned veterinary officers.</span>
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-4 border-t border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
          {step > 1 ? (
            <Button
              type="button"
              variant="secondary"
              size="sm"
              onClick={() => setStep((s) => s - 1)}
            >
              <ChevronLeft className="size-4" />
              Previous
            </Button>
          ) : (
            <Button type="button" variant="ghost" size="sm" onClick={onClose}>
              Cancel
            </Button>
          )}

          {step < 7 ? (
            <Button
              type="button"
              variant="default"
              size="sm"
              onClick={() => setStep((s) => s + 1)}
            >
              Continue
              <ChevronRight className="size-4" />
            </Button>
          ) : (
            <Button
              type="button"
              variant="teal"
              size="sm"
              onClick={handleLaunch}
              className="gap-2"
            >
              <Syringe className="size-4" />
              Launch Campaign
            </Button>
          )}
        </div>
      </div>
    </div>
  );
};
