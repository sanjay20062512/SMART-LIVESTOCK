import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { TooltipProvider } from '@/components/ui/tooltip';
import { AppShell } from '@/components/layout/AppShell';
import { OverviewView } from '@/components/dashboard/OverviewView';
import { DiseaseMapView } from '@/components/disease-map/DiseaseMapView';
import { OutbreakMonitoringView } from '@/components/outbreak/OutbreakMonitoringView';
import { VaccinationCampaignsView } from '@/components/campaigns/VaccinationCampaignsView';
import { GovernmentResponseView } from '@/components/response/GovernmentResponseView';
import { AlertsView } from '@/components/alerts/AlertsView';
import { ReportsView } from '@/components/reports/ReportsView';
import { SettingsView } from '@/components/settings/SettingsView';

export function App() {
  return (
    <TooltipProvider delayDuration={150}>
      <BrowserRouter>
        <Routes>
          <Route path="/embed/disease-map" element={<div className="p-3 sm:p-5 bg-[#F7F9FB] min-h-screen"><DiseaseMapView /></div>} />
          <Route element={<AppShell />}>
            <Route path="/" element={<Navigate to="/overview" replace />} />
            <Route path="/overview" element={<OverviewView />} />
            <Route path="/disease-intelligence" element={<DiseaseMapView />} />
            <Route path="/outbreak-monitoring" element={<OutbreakMonitoringView />} />
            <Route path="/campaigns" element={<VaccinationCampaignsView />} />
            <Route path="/response" element={<GovernmentResponseView />} />
            <Route path="/alerts" element={<AlertsView />} />
            <Route path="/reports" element={<ReportsView />} />
            <Route path="/settings" element={<SettingsView />} />
            <Route path="*" element={<Navigate to="/overview" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  );
}

export default App;
