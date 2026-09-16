import React, { useState } from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { TopHeader } from './TopHeader';
import {
  LayoutDashboard,
  Map as MapIcon,
  Activity,
  Syringe,
  ShieldAlert,
  Bell,
  FileSpreadsheet,
  Settings,
  X,
  WifiOff
} from 'lucide-react';
import brandLogo from '@/assets/brand_logo.png';
import { cn } from '@/lib/utils';

export const AppShell: React.FC = () => {
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isOffline, setIsOffline] = useState(false);
  const [lastUpdated, setLastUpdated] = useState('Just now');
  const unreadCount = 3;

  const handleRefresh = () => {
    setLastUpdated('Just now');
  };

  const navItems = [
    { name: 'Overview', to: '/overview', icon: LayoutDashboard },
    { name: 'Disease Intelligence', to: '/disease-intelligence', icon: MapIcon },
    { name: 'Outbreak Monitoring', to: '/outbreak-monitoring', icon: Activity },
    { name: 'Vaccination Campaigns', to: '/campaigns', icon: Syringe },
    { name: 'Government Response', to: '/response', icon: ShieldAlert },
    { name: 'Alerts', to: '/alerts', icon: Bell, badge: unreadCount },
    { name: 'Reports', to: '/reports', icon: FileSpreadsheet },
    { name: 'Settings', to: '/settings', icon: Settings }
  ];

  return (
    <div className="min-h-screen flex bg-[#F7F9FB] text-[#18232B] font-sans antialiased">
      {/* Desktop & Tablet Sidebar */}
      <div className="hidden md:block shrink-0">
        <Sidebar
          isCollapsed={isSidebarCollapsed}
          onToggleCollapse={() => setIsSidebarCollapsed((prev) => !prev)}
          unreadAlertCount={unreadCount}
        />
      </div>

      {/* Mobile Slide-Out Navigation Drawer */}
      {isMobileMenuOpen && (
        <div className="fixed inset-0 z-50 md:hidden flex">
          <div
            className="fixed inset-0 bg-[#12304A]/60 backdrop-blur-xs transition-opacity"
            onClick={() => setIsMobileMenuOpen(false)}
          />
          <div className="relative w-4/5 max-w-xs bg-white h-full flex flex-col z-10 shadow-2xl">
            <div className="h-16 flex items-center justify-between px-4 border-b border-[#E4EAF0]">
              <div className="flex items-center gap-3">
                <img
                  src={brandLogo}
                  alt="Smart Livestock Logo"
                  className="h-7 w-auto object-contain"
                />
                <span className="font-bold text-sm text-[#12304A]">Smart Livestock</span>
              </div>
              <button
                onClick={() => setIsMobileMenuOpen(false)}
                className="size-8 rounded-lg text-[#667482] hover:bg-[#F7F9FB] flex items-center justify-center cursor-pointer"
              >
                <X className="size-5" />
              </button>
            </div>
            <div className="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
              {navItems.map((item) => {
                const Icon = item.icon;
                return (
                  <NavLink
                    key={item.name}
                    to={item.to}
                    onClick={() => setIsMobileMenuOpen(false)}
                    className={({ isActive }) =>
                      cn(
                        'flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer',
                        isActive
                          ? 'bg-[#12304A] text-white'
                          : 'text-[#18232B] hover:bg-[#EAF3FB]'
                      )
                    }
                  >
                    <Icon className="size-4.5 shrink-0" />
                    <span className="flex-1">{item.name}</span>
                    {item.badge !== undefined && item.badge > 0 && (
                      <span className="size-5 rounded-full text-[10px] font-bold flex items-center justify-center bg-[#C94343] text-white">
                        {item.badge}
                      </span>
                    )}
                  </NavLink>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        <TopHeader
          isOffline={isOffline}
          onToggleOffline={() => setIsOffline((prev) => !prev)}
          onMobileMenuOpen={() => setIsMobileMenuOpen(true)}
          lastUpdated={lastUpdated}
          onRefreshData={handleRefresh}
          unreadCount={unreadCount}
        />

        {/* Offline Alert Banner if offline is simulated */}
        {isOffline && (
          <div className="bg-[#FFF5D6] border-b border-[#D99A18]/30 px-4 sm:px-6 py-2 flex items-center justify-between text-xs text-[#B87A04] transition-all">
            <div className="flex items-center gap-2">
              <WifiOff className="size-4 shrink-0 text-[#D99A18]" />
              <span>
                <strong>Offline Mode:</strong> You are currently operating offline. Displaying cached surveillance data from the local database.
              </span>
            </div>
            <button
              onClick={() => setIsOffline(false)}
              className="text-xs font-bold underline hover:opacity-80 cursor-pointer ml-4"
            >
              Reconnect
            </button>
          </div>
        )}

        {/* Page Content Outlet */}
        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto w-full">
          <Outlet context={{ isOffline, onRefresh: handleRefresh }} />
        </main>
      </div>
    </div>
  );
};
