import React, { useState, useMemo, useRef, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import {
  MAHARASHTRA_DISTRICT_RISK_DATA,
  getDistrictByName
} from '@/data/maharashtraDistricts';
import type { DistrictRiskData, MapMode } from '@/types/disease';
import { MaharashtraDiseaseMap } from './MaharashtraDiseaseMap';
import { MapFilters } from './MapFilters';
import { DistrictDetailsPanel } from './DistrictDetailsPanel';
import { CreateCampaignModal } from '@/components/modals/CreateCampaignModal';
import { AssignTeamModal } from '@/components/modals/AssignTeamModal';
import { SendAdvisoryModal } from '@/components/modals/SendAdvisoryModal';
import { ReportPreviewModal } from '@/components/modals/ReportPreviewModal';

export const DiseaseMapView: React.FC = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const initialDistrictParam = searchParams.get('district');

  // Selected district state (defaults to null on load so full Maharashtra map is immediately visible)
  const [selectedDistrict, setSelectedDistrict] = useState<DistrictRiskData | null>(() => {
    if (initialDistrictParam) {
      return getDistrictByName(initialDistrictParam) || null;
    }
    return null; // Full Maharashtra overview on load
  });

  const [hoveredDistrict, setHoveredDistrict] = useState<DistrictRiskData | null>(null);

  // Filter States
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDisease, setSelectedDisease] = useState('All');
  const [selectedRiskLevel, setSelectedRiskLevel] = useState('All');
  const [selectedTimeframe, setSelectedTimeframe] = useState('7 Days');
  const [mapMode, setMapMode] = useState<MapMode>('risk');

  // Map viewport triggers
  const [resetViewTrigger, setResetViewTrigger] = useState(0);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Modals state
  const [isCampaignModalOpen, setIsCampaignModalOpen] = useState(false);
  const [isAssignTeamOpen, setIsAssignTeamOpen] = useState(false);
  const [isSendAdvisoryOpen, setIsSendAdvisoryOpen] = useState(false);
  const [isReportModalOpen, setIsReportModalOpen] = useState(false);
  const [modalDistrict, setModalDistrict] = useState<DistrictRiskData | null>(selectedDistrict);

  // Update query params when selected district changes
  const handleSelectDistrict = (district: DistrictRiskData) => {
    setSelectedDistrict(district);
    setSearchParams({ district: district.id }, { replace: true });
  };

  // Filtered district list based on search and dropdown filters
  const filteredDistricts = useMemo(() => {
    return MAHARASHTRA_DISTRICT_RISK_DATA.filter((d) => {
      const q = searchQuery.toLowerCase().trim();
      const matchesSearch =
        !q ||
        d.districtName.toLowerCase().includes(q) ||
        (d.marathiName && d.marathiName.toLowerCase().includes(q)) ||
        d.division.toLowerCase().includes(q) ||
        d.primaryDisease.toLowerCase().includes(q);

      const matchesDisease =
        selectedDisease === 'All' ||
        d.primaryDisease.toLowerCase().includes(selectedDisease.toLowerCase());

      const matchesRisk =
        selectedRiskLevel === 'All' ||
        d.riskLevel.toLowerCase() === selectedRiskLevel.toLowerCase();

      return matchesSearch && matchesDisease && matchesRisk;
    });
  }, [searchQuery, selectedDisease, selectedRiskLevel]);

  // If search query exactly matches a district, auto-focus it
  useEffect(() => {
    if (searchQuery.trim().length >= 3) {
      const exactMatch = MAHARASHTRA_DISTRICT_RISK_DATA.find(
        (d) =>
          d.districtName.toLowerCase() === searchQuery.trim().toLowerCase() ||
          d.id.toLowerCase() === searchQuery.trim().toLowerCase()
      );
      if (exactMatch && exactMatch.id !== selectedDistrict?.id) {
        setSelectedDistrict(exactMatch);
      }
    }
  }, [searchQuery, selectedDistrict]);

  // Handlers for action triggers
  const handleResetView = () => {
    setSelectedDistrict(null);
    setSearchParams({}, { replace: true });
    setResetViewTrigger((prev) => prev + 1);
  };

  const handleToggleFullscreen = () => {
    if (!document.fullscreenElement) {
      containerRef.current?.requestFullscreen();
      setIsFullscreen(true);
    } else {
      document.exitFullscreen();
      setIsFullscreen(false);
    }
  };

  const handleCreateCampaign = (district: DistrictRiskData) => {
    setModalDistrict(district);
    setIsCampaignModalOpen(true);
  };

  const handleAssignTeam = (district: DistrictRiskData) => {
    setModalDistrict(district);
    setIsAssignTeamOpen(true);
  };

  const handleSendAdvisory = (district: DistrictRiskData) => {
    setModalDistrict(district);
    setIsSendAdvisoryOpen(true);
  };

  const handleExportSummary = (district: DistrictRiskData) => {
    setModalDistrict(district);
    setIsReportModalOpen(true);
  };

  return (
    <div className="space-y-4 animate-in fade-in-50 duration-200">
      {/* Search & Filter Controls */}
      <MapFilters
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        selectedDisease={selectedDisease}
        onDiseaseChange={setSelectedDisease}
        selectedRiskLevel={selectedRiskLevel}
        onRiskLevelChange={setSelectedRiskLevel}
        selectedTimeframe={selectedTimeframe}
        onTimeframeChange={setSelectedTimeframe}
        mapMode={mapMode}
        onMapModeChange={setMapMode}
        onResetView={handleResetView}
        isFullscreen={isFullscreen}
        onToggleFullscreen={handleToggleFullscreen}
        filteredCount={filteredDistricts.length}
        totalCount={MAHARASHTRA_DISTRICT_RISK_DATA.length}
      />

      {/* Main Map Card Layout */}
      <div
        ref={containerRef}
        className="rounded-2xl border border-[#E4EAF0] bg-white shadow-sm overflow-hidden p-2 sm:p-3 relative"
      >
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-3 min-h-[580px] lg:min-h-[660px]">
          {/* Left / Center Map Section */}
          <div
            className={`transition-all duration-300 ${
              selectedDistrict ? 'lg:col-span-7 xl:col-span-8' : 'lg:col-span-12'
            }`}
          >
            <MaharashtraDiseaseMap
              selectedDistrict={selectedDistrict}
              onSelectDistrict={handleSelectDistrict}
              hoveredDistrict={hoveredDistrict}
              onHoverDistrict={setHoveredDistrict}
              filteredDistricts={filteredDistricts}
              mapMode={mapMode}
              resetViewTrigger={resetViewTrigger}
            />
          </div>

          {/* Right District Intelligence Panel (Desktop) */}
          {selectedDistrict && (
            <div className="hidden lg:block lg:col-span-5 xl:col-span-4 h-full min-h-[580px] lg:min-h-[660px]">
              <DistrictDetailsPanel
                district={selectedDistrict}
                onClose={() => {
                  setSelectedDistrict(null);
                  setSearchParams({}, { replace: true });
                }}
                onCreateCampaign={handleCreateCampaign}
                onAssignTeam={handleAssignTeam}
                onSendAdvisory={handleSendAdvisory}
                onExportSummary={handleExportSummary}
              />
            </div>
          )}
        </div>
      </div>

      {/* Mobile / Tablet Bottom Sheet Overlay when a district is selected */}
      {selectedDistrict && (
        <div className="block lg:hidden fixed inset-x-0 bottom-0 z-50 max-h-[80vh] rounded-t-2xl shadow-2xl border-t border-[#E4EAF0] bg-white overflow-hidden">
          <DistrictDetailsPanel
            district={selectedDistrict}
            onClose={() => {
              setSelectedDistrict(null);
              setSearchParams({}, { replace: true });
            }}
            onCreateCampaign={handleCreateCampaign}
            onAssignTeam={handleAssignTeam}
            onSendAdvisory={handleSendAdvisory}
            onExportSummary={handleExportSummary}
          />
        </div>
      )}

      {/* Connected Action Modals */}
      {modalDistrict && (
        <>
          {/* Create Vaccination Campaign Modal */}
          <CreateCampaignModal
            isOpen={isCampaignModalOpen}
            onClose={() => setIsCampaignModalOpen(false)}
            initialDistrict={modalDistrict.districtName}
            initialDisease={modalDistrict.primaryDisease}
            initialPriority={
              modalDistrict.riskPercentage >= 76
                ? 'Critical'
                : modalDistrict.riskPercentage >= 56
                ? 'High'
                : 'Medium'
            }
            onCreated={() => {
              setIsCampaignModalOpen(false);
            }}
          />

          {/* Assign Veterinary Team Modal */}
          <AssignTeamModal
            isOpen={isAssignTeamOpen}
            onClose={() => setIsAssignTeamOpen(false)}
            districtName={modalDistrict.districtName}
            taskTitle={`${modalDistrict.primaryDisease} Surveillance & Emergency Ring Response`}
            onAssigned={() => {
              setIsAssignTeamOpen(false);
            }}
          />

          {/* Send Advisory Modal */}
          <SendAdvisoryModal
            isOpen={isSendAdvisoryOpen}
            onClose={() => setIsSendAdvisoryOpen(false)}
            districtName={modalDistrict.districtName}
            diseaseName={modalDistrict.primaryDisease}
            onSent={() => {
              setIsSendAdvisoryOpen(false);
            }}
          />

          {/* Report Preview Modal */}
          <ReportPreviewModal
            isOpen={isReportModalOpen}
            onClose={() => setIsReportModalOpen(false)}
            reportTitle={`${modalDistrict.districtName} District Animal Epidemiological Intelligence Summary`}
            reportCategory="Epidemiological Intelligence"
          />
        </>
      )}
    </div>
  );
};
