import React from 'react';
import { NavLink } from 'react-router-dom';
import brandLogo from '@/assets/brand_logo.png';
import {
  LayoutDashboard,
  Map as MapIcon,
  Activity,
  Syringe,
  ShieldAlert,
  Bell,
  FileSpreadsheet,
  Settings,
  ChevronLeft,
  ChevronRight,
  ShieldCheck
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';

interface SidebarProps {
  isCollapsed: boolean;
  onToggleCollapse: () => void;
  unreadAlertCount?: number;
}

export const Sidebar: React.FC<SidebarProps> = ({
  isCollapsed,
  onToggleCollapse,
  unreadAlertCount = 3
}) => {
  const navItems = [
    { name: 'Overview', to: '/overview', icon: LayoutDashboard },
    { name: 'Disease Intelligence', to: '/disease-intelligence', icon: MapIcon },
    { name: 'Outbreak Monitoring', to: '/outbreak-monitoring', icon: Activity },
    { name: 'Vaccination Campaigns', to: '/campaigns', icon: Syringe },
    { name: 'Government Response', to: '/response', icon: ShieldAlert },
    { name: 'Alerts', to: '/alerts', icon: Bell, badge: unreadAlertCount },
    { name: 'Reports', to: '/reports', icon: FileSpreadsheet },
    { name: 'Settings', to: '/settings', icon: Settings }
  ];

  return (
    <aside
      className={cn(
        'h-screen sticky top-0 z-30 flex flex-col bg-white border-r border-[#E4EAF0] transition-all duration-300 select-none shadow-xs',
        isCollapsed ? 'w-20' : 'w-64'
      )}
    >
      {/* Brand Header */}
      <div className="h-16 flex items-center px-4 border-b border-[#E4EAF0] justify-between gap-3">
        <div className="flex items-center gap-3 overflow-hidden">
          <img
            src={brandLogo}
            alt="Smart Livestock Brand Logo"
            className="h-8 w-auto max-w-[34px] object-contain shrink-0"
          />
          {!isCollapsed && (
            <div className="flex flex-col overflow-hidden">
              <span className="font-bold text-sm text-[#12304A] tracking-tight leading-tight truncate">
                Smart Livestock
              </span>
              <span className="text-[11px] font-medium text-[#1769AA] truncate">
                Government Intelligence
              </span>
            </div>
          )}
        </div>

        <button
          onClick={onToggleCollapse}
          className="size-7 rounded-lg border border-[#E4EAF0] text-[#667482] hover:text-[#18232B] hover:bg-[#F7F9FB] flex items-center justify-center transition-colors cursor-pointer shrink-0"
          title={isCollapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {isCollapsed ? (
            <ChevronRight className="size-4" />
          ) : (
            <ChevronLeft className="size-4" />
          )}
        </button>
      </div>

      {/* Navigation List */}
      <div className="flex-1 py-4 px-2.5 space-y-1 overflow-y-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          const linkNode = (
            <NavLink
              to={item.to}
              className={({ isActive }) =>
                cn(
                  'flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition-all duration-150 relative group cursor-pointer',
                  isActive
                    ? 'bg-[#12304A] text-white shadow-xs'
                    : 'text-[#18232B] hover:bg-[#EAF3FB]/70 hover:text-[#1769AA]',
                  isCollapsed && 'justify-center px-0'
                )
              }
            >
              {({ isActive }) => (
                <>
                  <Icon
                    className={cn(
                      'size-4.5 shrink-0 transition-colors',
                      isActive ? 'text-white' : 'text-[#667482] group-hover:text-[#1769AA]'
                    )}
                  />
                  {!isCollapsed && (
                    <span className="flex-1 truncate tracking-tight">{item.name}</span>
                  )}
                  {item.badge !== undefined && item.badge > 0 && (
                    <span
                      className={cn(
                        'size-5 rounded-full text-[10px] font-bold flex items-center justify-center shrink-0 transition-all',
                        isActive
                          ? 'bg-[#C94343] text-white'
                          : 'bg-[#FDECEC] text-[#C94343] border border-[#C94343]/20'
                      )}
                    >
                      {item.badge}
                    </span>
                  )}
                </>
              )}
            </NavLink>
          );

          if (isCollapsed) {
            return (
              <Tooltip key={item.name} delayDuration={100}>
                <TooltipTrigger asChild>{linkNode}</TooltipTrigger>
                <TooltipContent side="right" className="font-semibold text-xs">
                  {item.name}
                </TooltipContent>
              </Tooltip>
            );
          }

          return <div key={item.name}>{linkNode}</div>;
        })}
      </div>

      {/* Official Jurisdiction Footer Badge */}
      {!isCollapsed ? (
        <div className="p-3 border-t border-[#E4EAF0] bg-[#F7F9FB] m-2 rounded-xl text-xs">
          <div className="flex items-center gap-2 text-[#12304A] font-bold mb-1">
            <ShieldCheck className="size-4 text-[#087F73]" />
            <span>State Jurisdiction</span>
          </div>
          <p className="text-[11px] text-[#667482] leading-tight">
            Maharashtra Dept of Animal Husbandry, Govt. of Maharashtra
          </p>
        </div>
      ) : (
        <div className="p-3 border-t border-[#E4EAF0] flex justify-center text-[#087F73]">
          <ShieldCheck className="size-4" />
        </div>
      )}
    </aside>
  );
};
