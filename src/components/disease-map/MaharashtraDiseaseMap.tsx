import React, { useEffect, useRef, useCallback, useMemo } from 'react';
import { MapContainer, TileLayer, GeoJSON, Marker, useMap } from 'react-leaflet';
import L from 'leaflet';
import type { FeatureCollection, Feature, Geometry } from 'geojson';
import rawGeoJson from '@/data/maharashtra-districts.json';
import maharashtraMaskJson from '@/data/maharashtra-mask.json';
import maharashtraOutlineJson from '@/data/maharashtra-outline.json';
import {
  MAHARASHTRA_DISTRICT_RISK_DATA,
  getDistrictByName,
  getRiskColor,
  getVaccinationColor
} from '@/data/maharashtraDistricts';
import type { DistrictRiskData, MapMode } from '@/types/disease';
import { MapLegend } from './MapLegend';

// Cast raw GeoJSON into typed FeatureCollection
const maharashtraGeoData = rawGeoJson as unknown as FeatureCollection<Geometry, {
  dtname: string;
  stname: string;
  dtcode11?: string;
  id?: string;
}>;

const maharashtraMask = maharashtraMaskJson as unknown as Feature<Geometry>;
const maharashtraOutline = maharashtraOutlineJson as unknown as Feature<Geometry>;

// State bounds for Maharashtra: [[South-West], [North-East]]
// Restricting bounds strictly prevents users from panning outside Maharashtra
const MAHARASHTRA_BOUNDS: L.LatLngBoundsLiteral = [
  [15.5, 72.4],
  [22.2, 81.1]
];

const MAHARASHTRA_CENTER: [number, number] = [19.25, 76.5];

interface MaharashtraDiseaseMapProps {
  selectedDistrict: DistrictRiskData | null;
  onSelectDistrict: (district: DistrictRiskData) => void;
  hoveredDistrict: DistrictRiskData | null;
  onHoverDistrict: (district: DistrictRiskData | null) => void;
  filteredDistricts: DistrictRiskData[];
  mapMode: MapMode;
  resetViewTrigger: number;
}

// Controller component to smoothly control camera inside Leaflet context
const MapViewController: React.FC<{
  selectedDistrict: DistrictRiskData | null;
  resetViewTrigger: number;
}> = ({ selectedDistrict, resetViewTrigger }) => {
  const map = useMap();
  const initialFitRef = useRef(false);

  // Fit strictly to Maharashtra state on page load
  useEffect(() => {
    if (!initialFitRef.current) {
      map.fitBounds(MAHARASHTRA_BOUNDS, {
        padding: [20, 20],
        animate: false
      });
      initialFitRef.current = true;
    }
  }, [map]);

  // Reset to full state bounds when resetTrigger changes
  useEffect(() => {
    if (resetViewTrigger > 0) {
      map.flyToBounds(MAHARASHTRA_BOUNDS, {
        padding: [20, 20],
        duration: 0.8
      });
    }
  }, [resetViewTrigger, map]);

  // Smoothly pan/zoom to selected district coordinates
  useEffect(() => {
    if (selectedDistrict?.coordinates) {
      map.flyTo(selectedDistrict.coordinates, 8, {
        duration: 0.8,
        easeLinearity: 0.25
      });
    } else if (initialFitRef.current && !selectedDistrict) {
      // If district deselected, smoothly return to full Maharashtra state view
      map.flyToBounds(MAHARASHTRA_BOUNDS, {
        padding: [20, 20],
        duration: 0.8
      });
    }
  }, [selectedDistrict, map]);

  return null;
};

// Helper to create non-overlapping, high-contrast district name labels
const createDistrictLabelIcon = (name: string, isSelected: boolean) => {
  return L.divIcon({
    className: 'district-label-container',
    html: `<span class="district-map-label ${isSelected ? 'selected' : ''}">${name}</span>`,
    iconSize: [60, 16],
    iconAnchor: [30, 8]
  });
};

export const MaharashtraDiseaseMap: React.FC<MaharashtraDiseaseMapProps> = ({
  selectedDistrict,
  onSelectDistrict,
  onHoverDistrict,
  filteredDistricts,
  mapMode,
  resetViewTrigger
}) => {
  const geoJsonLayerRef = useRef<L.GeoJSON | null>(null);

  // Check if a district matches the current search / filter
  const isDistrictFiltered = useCallback((districtName: string): boolean => {
    return filteredDistricts.some((d) => d.districtName === districtName);
  }, [filteredDistricts]);

  // Dynamic polygon styling preserving 0-30%, 31-55%, 56-75%, 76-100% risk colors
  const styleFeature = useCallback((feature?: Feature<Geometry, { dtname: string }>): L.PathOptions => {
    if (!feature?.properties) {
      return { fillOpacity: 0.2, weight: 1, color: '#94A3B8' };
    }

    const dtname = feature.properties.dtname;
    const districtData = getDistrictByName(dtname);
    const isSelected = selectedDistrict && getDistrictByName(selectedDistrict.districtName)?.districtName === districtData?.districtName;
    const isFiltered = isDistrictFiltered(districtData?.districtName || dtname);

    if (!districtData) {
      return {
        fillColor: '#CBD5E1',
        fillOpacity: 0.25,
        color: '#94A3B8',
        weight: 1
      };
    }

    const fillColor =
      mapMode === 'vaccination'
        ? getVaccinationColor(districtData.vaccinationCoverage, 1)
        : getRiskColor(districtData.riskPercentage, 1);

    if (isSelected) {
      return {
        fillColor,
        fillOpacity: 0.95,
        color: '#12304A', // Deep navy prominent border
        weight: 3.5,
        dashArray: undefined
      };
    }

    return {
      fillColor,
      fillOpacity: isFiltered ? 0.8 : 0.15,
      color: isFiltered ? '#FFFFFF' : '#CBD5E1',
      weight: isFiltered ? 1.5 : 1,
      dashArray: isFiltered ? undefined : '3 3'
    };
  }, [selectedDistrict, isDistrictFiltered, mapMode]);

  // Update styles when selection, mode, or filter changes
  useEffect(() => {
    if (geoJsonLayerRef.current) {
      geoJsonLayerRef.current.setStyle(styleFeature);
    }
  }, [styleFeature]);

  // Handle interaction on each district polygon
  const onEachFeature = useCallback((feature: Feature<Geometry, { dtname: string }>, layer: L.Layer) => {
    const dtname = feature.properties.dtname;
    const districtData = getDistrictByName(dtname);

    // Build custom tooltip HTML
    if (districtData) {
      const tooltipContent = `
        <div style="min-width: 140px; font-family: Inter, system-ui, sans-serif;">
          <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-bottom: 4px;">
            <strong style="font-size: 13px; color: #18232B; font-weight: 700;">${districtData.districtName}</strong>
            <span style="font-size: 10px; color: #667482; font-weight: 600;">${districtData.division}</span>
          </div>
          <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 4px;">
            <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background-color: ${getRiskColor(districtData.riskPercentage, 1)};"></span>
            <span style="font-size: 11px; font-weight: 700; color: #18232B;">${districtData.riskLevel} Risk (${districtData.riskPercentage}%)</span>
          </div>
          <div style="font-size: 10px; color: #475569; border-top: 1px solid #E2E8F0; padding-top: 3px; margin-top: 2px;">
            <span style="color: #667482;">Disease:</span> <strong>${districtData.primaryDisease}</strong>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 10px; color: #667482; margin-top: 2px;">
            <span>Vaccination: <strong>${districtData.vaccinationCoverage}%</strong></span>
            <span>Cases: <strong style="color: #C94343;">${districtData.activeCases}</strong></span>
          </div>
        </div>
      `;

      layer.bindTooltip(tooltipContent, {
        className: 'leaflet-tooltip-maharashtra',
        sticky: true,
        direction: 'top',
        opacity: 0.98
      });
    }

    // Attach event listeners
    layer.on({
      mouseover: (e: L.LeafletMouseEvent) => {
        const targetLayer = e.target;
        if (districtData) {
          onHoverDistrict(districtData);
        }
        targetLayer.setStyle({
          fillOpacity: 0.92,
          weight: 2.5,
          color: '#12304A'
        });
        if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
          targetLayer.bringToFront();
        }
      },
      mouseout: (e: L.LeafletMouseEvent) => {
        onHoverDistrict(null);
        const targetLayer = e.target;
        // Re-apply correct style
        targetLayer.setStyle(styleFeature(feature));
      },
      click: (e: L.LeafletMouseEvent) => {
        if (districtData) {
          onSelectDistrict(districtData);
        }
        L.DomEvent.stopPropagation(e);
      }
    });
  }, [onHoverDistrict, onSelectDistrict, styleFeature]);

  // Memoize district labels
  const districtMarkers = useMemo(() => {
    return MAHARASHTRA_DISTRICT_RISK_DATA.map((district) => {
      const isSelected = selectedDistrict?.id === district.id;
      return (
        <Marker
          key={district.id}
          position={district.coordinates}
          icon={createDistrictLabelIcon(district.districtName, isSelected)}
          interactive={false}
        />
      );
    });
  }, [selectedDistrict]);

  return (
    <div className="relative w-full h-full min-h-[480px] sm:min-h-[560px] lg:min-h-[620px] rounded-2xl overflow-hidden bg-[#F8FAFC]">
      <MapContainer
        center={MAHARASHTRA_CENTER}
        zoom={7}
        minZoom={7}
        maxZoom={12}
        maxBounds={MAHARASHTRA_BOUNDS}
        maxBoundsViscosity={1.0}
        scrollWheelZoom={true}
        className="w-full h-full z-0"
      >
        {/* OpenStreetMap: Clean public tiles with no API key requirement */}
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
        />

        {/* Outer Mask: Blocks out all surrounding Indian states, countries, and oceans outside Maharashtra */}
        <GeoJSON
          data={maharashtraMask}
          style={{
            fillColor: '#F8FAFC',
            fillOpacity: 1.0,
            stroke: false,
            weight: 0
          }}
          interactive={false}
        />

        {/* Dynamic Maharashtra District GeoJSON Vector Layer */}
        <GeoJSON
          ref={geoJsonLayerRef}
          data={maharashtraGeoData}
          style={styleFeature}
          onEachFeature={onEachFeature}
        />

        {/* Maharashtra State Outer Boundary: Clean authoritative boundary */}
        <GeoJSON
          data={maharashtraOutline}
          style={{
            fillColor: 'transparent',
            fillOpacity: 0,
            color: '#0F172A',
            weight: 2.5,
            opacity: 0.95
          }}
          interactive={false}
        />

        {/* Clear non-overlapping district name labels */}
        {districtMarkers}

        {/* View controller handling animated camera, fitBounds, and zoom */}
        <MapViewController
          selectedDistrict={selectedDistrict}
          resetViewTrigger={resetViewTrigger}
        />
      </MapContainer>

      {/* Floating Map Legend (Bottom-Left) */}
      <div className="absolute bottom-4 left-4 z-400 max-w-[260px]">
        <MapLegend mapMode={mapMode} />
      </div>

      {/* Watermark State Indicator (Top-Left) */}
      <div className="absolute top-3 left-3 z-400 pointer-events-none">
        <div className="px-3 py-1.5 rounded-xl bg-white/95 backdrop-blur-md border border-[#E4EAF0] shadow-sm text-xs space-y-0.5">
          <div className="font-bold text-[#12304A] flex items-center gap-1.5">
            <span className="size-2 rounded-full bg-[#087F73] animate-pulse" />
            <span>Maharashtra State Animal Disease Intelligence</span>
          </div>
          <span className="text-[10px] text-[#667482] block">
            Maharashtra District Boundaries • 36 Administrative Units
          </span>
        </div>
      </div>
    </div>
  );
};
