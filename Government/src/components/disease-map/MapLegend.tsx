import React, { useState } from 'react';
import type { MapMode } from '@/types/disease';
import { ChevronDown, ChevronUp, Info } from 'lucide-react';

interface MapLegendProps {
  mapMode: MapMode;
  className?: string;
}

export const MapLegend: React.FC<MapLegendProps> = ({ mapMode, className = '' }) => {
  const [isExpanded, setIsExpanded] = useState(true);

  if (mapMode === 'vaccination') {
    return (
      <div
        className={`bg-white/95 backdrop-blur-md rounded-xl border border-[#E4EAF0] shadow-sm p-3 text-xs pointer-events-auto transition-all ${className}`}
      >
        <div className="flex items-center justify-between gap-2 mb-2">
          <div className="flex items-center gap-1.5">
            <div className="size-2 rounded-full bg-[#087F73]" />
            <span className="font-bold text-[#18232B] text-[11px] tracking-wide uppercase">
              Vaccination Saturation
            </span>
          </div>
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="text-[#667482] hover:text-[#18232B] p-0.5 rounded cursor-pointer"
            aria-label="Toggle legend"
          >
            {isExpanded ? <ChevronUp className="size-3.5" /> : <ChevronDown className="size-3.5" />}
          </button>
        </div>

        {isExpanded && (
          <div className="space-y-1.5 pt-1 border-t border-[#E4EAF0]/60">
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-2">
                <span className="size-3 rounded-xs bg-[#10B981] inline-block shadow-2xs" />
                <span className="text-[#18232B] font-medium text-[11px]">Optimal Coverage</span>
              </div>
              <span className="text-[#667482] font-semibold text-[11px]">80–100%</span>
            </div>

            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-2">
                <span className="size-3 rounded-xs bg-[#F59E0B] inline-block shadow-2xs" />
                <span className="text-[#18232B] font-medium text-[11px]">Moderate Buffer</span>
              </div>
              <span className="text-[#667482] font-semibold text-[11px]">65–79%</span>
            </div>

            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-2">
                <span className="size-3 rounded-xs bg-[#EF4444] inline-block shadow-2xs" />
                <span className="text-[#18232B] font-medium text-[11px]">Critical Deficit</span>
              </div>
              <span className="text-[#667482] font-semibold text-[11px]">&lt; 65%</span>
            </div>
          </div>
        )}
      </div>
    );
  }

  return (
    <div
      className={`bg-white/95 backdrop-blur-md rounded-xl border border-[#E4EAF0] shadow-sm p-3 text-xs pointer-events-auto transition-all ${className}`}
    >
      <div className="flex items-center justify-between gap-2 mb-2">
        <div className="flex items-center gap-1.5">
          <Info className="size-3.5 text-[#087F73]" />
          <span className="font-bold text-[#18232B] text-[11px] tracking-wide uppercase">
            Risk Classification
          </span>
        </div>
        <button
          onClick={() => setIsExpanded(!isExpanded)}
          className="text-[#667482] hover:text-[#18232B] p-0.5 rounded cursor-pointer"
          aria-label="Toggle legend"
        >
          {isExpanded ? <ChevronUp className="size-3.5" /> : <ChevronDown className="size-3.5" />}
        </button>
      </div>

      {isExpanded && (
        <div className="space-y-1.5 pt-1 border-t border-[#E4EAF0]/60">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <span className="size-3 rounded-xs bg-[#10B981] inline-block shadow-2xs" />
              <span className="text-[#18232B] font-medium text-[11px]">Low Risk</span>
            </div>
            <span className="text-[#667482] font-semibold text-[11px]">0–30%</span>
          </div>

          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <span className="size-3 rounded-xs bg-[#F59E0B] inline-block shadow-2xs" />
              <span className="text-[#18232B] font-medium text-[11px]">Moderate Risk</span>
            </div>
            <span className="text-[#667482] font-semibold text-[11px]">31–55%</span>
          </div>

          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <span className="size-3 rounded-xs bg-[#F97316] inline-block shadow-2xs" />
              <span className="text-[#18232B] font-medium text-[11px]">High Risk</span>
            </div>
            <span className="text-[#667482] font-semibold text-[11px]">56–75%</span>
          </div>

          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <span className="size-3 rounded-xs bg-[#EF4444] inline-block shadow-2xs" />
              <span className="text-[#18232B] font-medium text-[11px]">Critical Risk</span>
            </div>
            <span className="text-[#667482] font-semibold text-[11px]">76–100%</span>
          </div>

          <div className="pt-1.5 mt-1 border-t border-[#E4EAF0]/50 text-[10px] text-[#667482] flex items-center justify-between">
            <span>Surveillance surveillance index</span>
            <span className="text-[9px] font-semibold text-[#087F73]">Demo Data</span>
          </div>
        </div>
      )}
    </div>
  );
};
