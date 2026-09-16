import React, { useState } from 'react';
import type { MapMode } from '@/types/disease';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Search,
  RotateCcw,
  Maximize2,
  Minimize2,
  ShieldAlert,
  Syringe,
  X,
  SlidersHorizontal
} from 'lucide-react';

interface MapFiltersProps {
  searchQuery: string;
  onSearchChange: (value: string) => void;
  selectedDisease: string;
  onDiseaseChange: (value: string) => void;
  selectedRiskLevel: string;
  onRiskLevelChange: (value: string) => void;
  selectedTimeframe: string;
  onTimeframeChange: (value: string) => void;
  mapMode: MapMode;
  onMapModeChange: (mode: MapMode) => void;
  onResetView: () => void;
  isFullscreen: boolean;
  onToggleFullscreen: () => void;
  filteredCount: number;
  totalCount: number;
}

export const MapFilters: React.FC<MapFiltersProps> = ({
  searchQuery,
  onSearchChange,
  selectedDisease,
  onDiseaseChange,
  selectedRiskLevel,
  onRiskLevelChange,
  selectedTimeframe,
  onTimeframeChange,
  mapMode,
  onMapModeChange,
  onResetView,
  isFullscreen,
  onToggleFullscreen,
  filteredCount,
  totalCount
}) => {
  const [isMobileDrawerOpen, setIsMobileDrawerOpen] = useState(false);

  const activeFiltersCount =
    (searchQuery ? 1 : 0) +
    (selectedDisease !== 'All' ? 1 : 0) +
    (selectedRiskLevel !== 'All' ? 1 : 0) +
    (selectedTimeframe !== '7 Days' ? 1 : 0);

  const handleClearAll = () => {
    onSearchChange('');
    onDiseaseChange('All');
    onRiskLevelChange('All');
    onTimeframeChange('7 Days');
  };

  return (
    <div className="space-y-3">
      {/* Top Header & Mode Switcher Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-1">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#087F73] uppercase tracking-wider">
              Surveillance GIS
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Maharashtra District Polygon Boundaries</span>
            <span className="text-xs text-[#667482]">•</span>
            <Badge variant="outline" className="text-[10px] font-semibold text-[#087F73] border-[#087F73]/30 bg-[#EAF7F2]">
              Demo surveillance data
            </Badge>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight mt-0.5">
            Maharashtra Disease Intelligence
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Explore district-level animal-health risks and identify areas requiring government action.
          </p>
        </div>

        {/* Mode Toggle Pills (Disease Risk vs Vaccination Saturation) */}
        <div className="flex items-center p-1 rounded-xl bg-white border border-[#E4EAF0] shadow-2xs text-xs font-semibold self-start sm:self-auto shrink-0">
          <button
            onClick={() => onMapModeChange('risk')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
              mapMode === 'risk'
                ? 'bg-[#12304A] text-white shadow-2xs'
                : 'text-[#667482] hover:text-[#18232B]'
            }`}
          >
            <ShieldAlert className="size-3.5" />
            <span>Disease Risk Index</span>
          </button>
          <button
            onClick={() => onMapModeChange('vaccination')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
              mapMode === 'vaccination'
                ? 'bg-[#087F73] text-white shadow-2xs'
                : 'text-[#667482] hover:text-[#18232B]'
            }`}
          >
            <Syringe className="size-3.5" />
            <span>Vaccination Saturation</span>
          </button>
        </div>
      </div>

      {/* Main Filter Bar Card */}
      <div className="p-3 sm:p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-2xs space-y-3">
        {/* Mobile Header Toggle */}
        <div className="flex sm:hidden items-center justify-between">
          <div className="relative flex-1 mr-2">
            <Search className="size-3.5 text-[#667482] absolute left-3 top-2.5" />
            <Input
              value={searchQuery}
              onChange={(e) => onSearchChange(e.target.value)}
              placeholder="Search district..."
              className="pl-8 h-8 text-xs bg-white"
            />
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setIsMobileDrawerOpen(!isMobileDrawerOpen)}
            className="h-8 gap-1.5 text-xs border-[#E4EAF0]"
          >
            <SlidersHorizontal className="size-3.5" />
            <span>Filters</span>
            {activeFiltersCount > 0 && (
              <span className="size-4 rounded-full bg-[#087F73] text-white text-[10px] flex items-center justify-center font-bold">
                {activeFiltersCount}
              </span>
            )}
          </Button>
        </div>

        {/* Desktop Filter Row (or Mobile expanded drawer) */}
        <div className={`grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-12 gap-2.5 items-center ${isMobileDrawerOpen ? 'block' : 'hidden sm:grid'}`}>
          {/* District Search (Desktop) */}
          <div className="hidden sm:block lg:col-span-4 relative">
            <Search className="size-4 text-[#667482] absolute left-3 top-2.5" />
            <Input
              value={searchQuery}
              onChange={(e) => onSearchChange(e.target.value)}
              placeholder="Search district name or disease..."
              className="pl-9 pr-7 h-9 text-xs bg-white border-[#E4EAF0] focus:ring-[#087F73]"
            />
            {searchQuery && (
              <button
                onClick={() => onSearchChange('')}
                className="absolute right-2.5 top-2.5 text-[#667482] hover:text-[#18232B] cursor-pointer"
                title="Clear search"
              >
                <X className="size-3.5" />
              </button>
            )}
          </div>

          {/* Disease Filter Dropdown */}
          <div className="lg:col-span-3">
            <select
              value={selectedDisease}
              onChange={(e) => onDiseaseChange(e.target.value)}
              className="w-full h-9 px-3 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73] font-medium"
            >
              <option value="All">All Pathogens (FMD, LSD, HS, BQ, Anthrax...)</option>
              <option value="Foot-and-Mouth">Foot-and-Mouth Disease (FMD)</option>
              <option value="Lumpy">Lumpy Skin Disease (LSD)</option>
              <option value="Haemorrhagic">Haemorrhagic Septicaemia (HS)</option>
              <option value="Black Quarter">Black Quarter (BQ)</option>
              <option value="Brucellosis">Brucellosis</option>
              <option value="Anthrax">Anthrax</option>
              <option value="Peste">PPR (Small Ruminants)</option>
            </select>
          </div>

          {/* Risk Level Filter Dropdown */}
          <div className="lg:col-span-2">
            <select
              value={selectedRiskLevel}
              onChange={(e) => onRiskLevelChange(e.target.value)}
              className="w-full h-9 px-3 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73] font-medium"
            >
              <option value="All">All Risk Tiers</option>
              <option value="Critical">Critical Risk (76–100%)</option>
              <option value="High">High Risk (56–75%)</option>
              <option value="Moderate">Moderate Risk (31–55%)</option>
              <option value="Low">Low Risk (0–30%)</option>
            </select>
          </div>

          {/* Timeframe Filter Dropdown */}
          <div className="lg:col-span-2">
            <select
              value={selectedTimeframe}
              onChange={(e) => onTimeframeChange(e.target.value)}
              className="w-full h-9 px-3 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73] font-medium"
            >
              <option value="7 Days">Last 7 Days (Surge)</option>
              <option value="30 Days">Last 30 Days</option>
              <option value="90 Days">Last 90 Days</option>
              <option value="This Year">Current Year</option>
            </select>
          </div>

          {/* Map Controls (Reset & Fullscreen) */}
          <div className="lg:col-span-1 flex items-center justify-end gap-1.5">
            <Button
              variant="outline"
              size="icon"
              onClick={onResetView}
              className="size-9 text-[#18232B] border-[#E4EAF0] hover:bg-[#F1F5F9] shrink-0"
              title="Reset Map to Maharashtra"
            >
              <RotateCcw className="size-4 text-[#667482]" />
            </Button>
            <Button
              variant="outline"
              size="icon"
              onClick={onToggleFullscreen}
              className="size-9 text-[#18232B] border-[#E4EAF0] hover:bg-[#F1F5F9] shrink-0"
              title={isFullscreen ? 'Exit Fullscreen' : 'Fullscreen Map'}
            >
              {isFullscreen ? (
                <Minimize2 className="size-4 text-[#667482]" />
              ) : (
                <Maximize2 className="size-4 text-[#667482]" />
              )}
            </Button>
          </div>
        </div>

        {/* Active Filter Chips & Status Indicator */}
        <div className="flex flex-wrap items-center justify-between gap-2 pt-1 border-t border-[#E4EAF0]/60 text-xs">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-[#667482] font-medium">
              Showing <strong className="text-[#18232B] font-bold">{filteredCount}</strong> of {totalCount} Maharashtra districts
            </span>

            {activeFiltersCount > 0 && (
              <button
                onClick={handleClearAll}
                className="text-[11px] font-semibold text-[#C94343] hover:underline flex items-center gap-1 ml-2 cursor-pointer"
              >
                <X className="size-3" />
                Reset filters
              </button>
            )}
          </div>

          <div className="flex items-center gap-3 text-[11px] text-[#667482]">
            <span>Surveillance Mode: <strong className="text-[#18232B]">{mapMode === 'risk' ? 'Epidemiological Risk' : 'Vaccine Saturation'}</strong></span>
            <span>Timeframe: <strong className="text-[#18232B]">{selectedTimeframe}</strong></span>
          </div>
        </div>
      </div>
    </div>
  );
};
