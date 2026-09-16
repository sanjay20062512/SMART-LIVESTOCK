import React from 'react';
import { useLocation, Link } from 'react-router-dom';
import {
  Bell,
  RefreshCw,
  WifiOff,
  MapPin,
  ChevronDown,
  User,
  LogOut,
  ShieldAlert,
  Settings,
  Menu
} from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';
import { INITIAL_GOVT_ALERTS } from '@/data/alerts';

interface TopHeaderProps {
  isOffline: boolean;
  onToggleOffline: () => void;
  onMobileMenuOpen: () => void;
  lastUpdated: string;
  onRefreshData: () => void;
  unreadCount?: number;
}

export const TopHeader: React.FC<TopHeaderProps> = ({
  isOffline,
  onToggleOffline,
  onMobileMenuOpen,
  lastUpdated,
  onRefreshData,
  unreadCount = 3
}) => {
  const location = useLocation();

  const getPageMeta = () => {
    switch (location.pathname) {
      case '/disease-intelligence':
        return {
          title: 'Maharashtra Disease Intelligence Map',
          subtitle: 'District-level epidemiological risk boundaries and field response surveillance.',
          breadcrumb: 'Epidemiology'
        };
      case '/outbreak-monitoring':
        return {
          title: 'Outbreak Monitoring & Early Warning',
          subtitle: 'Multi-pathogen time-series analytics, syndromic surge detection, and risk factor weights.',
          breadcrumb: 'Analytics'
        };
      case '/campaigns':
        return {
          title: 'Vaccination Campaign Command Center',
          subtitle: 'District herd immunity tracking, prophylactic supply logistics, and village drives.',
          breadcrumb: 'Operations'
        };
      case '/response':
        return {
          title: 'Government Rapid Response Center',
          subtitle: 'Field task management, mobile veterinary unit assignment, and containment SOPs.',
          breadcrumb: 'Response'
        };
      case '/alerts':
        return {
          title: 'Urgent Disease Alerts & Notifications',
          subtitle: 'Critical risk escalations, laboratory confirmations, and advisory triggers.',
          breadcrumb: 'Alerts'
        };
      case '/reports':
        return {
          title: 'Epidemiological Reports & Analytics',
          subtitle: 'Official veterinary intelligence bulletins, mortality logs, and CSV exports.',
          breadcrumb: 'Documentation'
        };
      case '/settings':
        return {
          title: 'Government Surveillance Settings',
          subtitle: 'District risk threshold calibrations, automated notification rules, and officer credentials.',
          breadcrumb: 'Configuration'
        };
      case '/overview':
      default:
        return {
          title: 'Government Health Command Center',
          subtitle: 'Monitor animal-health risks, vaccination progress, and field response across Maharashtra.',
          breadcrumb: 'Command Center'
        };
    }
  };

  const meta = getPageMeta();

  return (
    <header className="sticky top-0 z-20 w-full bg-white/95 backdrop-blur-md border-b border-[#E4EAF0] px-4 sm:px-6 py-3 transition-colors">
      <div className="flex items-center justify-between gap-4">
        {/* Left Side: Mobile Menu Button & Breadcrumb + Page Title */}
        <div className="flex items-center gap-3 min-w-0">
          <button
            onClick={onMobileMenuOpen}
            className="md:hidden size-9 rounded-lg border border-[#E4EAF0] text-[#18232B] flex items-center justify-center hover:bg-[#F7F9FB] cursor-pointer shrink-0"
            aria-label="Open navigation menu"
          >
            <Menu className="size-5" />
          </button>

          <div className="min-w-0">
            <div className="flex items-center gap-1.5 text-[11px] font-medium text-[#667482] leading-none mb-1 truncate">
              <span>Maharashtra</span>
              <span>/</span>
              <span>Government Intelligence</span>
              <span>/</span>
              <span className="text-[#1769AA] font-semibold">{meta.breadcrumb}</span>
            </div>
            <h1 className="text-base sm:text-lg font-bold text-[#18232B] tracking-tight truncate leading-snug">
              {meta.title}
            </h1>
            <p className="text-xs text-[#667482] hidden lg:block truncate max-w-2xl">
              {meta.subtitle}
            </p>
          </div>
        </div>

        {/* Right Side: Location, Refresh, Connectivity, Notifications, Officer Dropdown */}
        <div className="flex items-center gap-2 sm:gap-3 shrink-0">
          {/* Location Badge */}
          <div className="hidden sm:flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#EAF3FB] border border-[#1769AA]/20 text-xs font-semibold text-[#12304A]">
            <MapPin className="size-3.5 text-[#1769AA]" />
            <span>Maharashtra State (Pune HQ)</span>
          </div>

          {/* Refresh Action with Last Updated Tooltip */}
          <Tooltip delayDuration={150}>
            <TooltipTrigger asChild>
              <button
                onClick={onRefreshData}
                className="size-8.5 rounded-lg border border-[#E4EAF0] bg-white text-[#667482] hover:text-[#12304A] hover:bg-[#F7F9FB] flex items-center justify-center transition-colors cursor-pointer"
                aria-label="Refresh surveillance data"
              >
                <RefreshCw className="size-4" />
              </button>
            </TooltipTrigger>
            <TooltipContent side="bottom" className="text-xs">
              Last synchronized: {lastUpdated} (Click to refresh)
            </TooltipContent>
          </Tooltip>

          {/* Connectivity Status Pill with Offline Simulation Toggle */}
          <Tooltip delayDuration={150}>
            <TooltipTrigger asChild>
              <button
                onClick={onToggleOffline}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border transition-all cursor-pointer ${
                  isOffline
                    ? 'bg-[#FFF5D6] text-[#B87A04] border-[#D99A18]/30 hover:bg-[#faecc2]'
                    : 'bg-[#EAF7F2] text-[#16845B] border-[#16845B]/20 hover:bg-[#d5f0e6]'
                }`}
              >
                {isOffline ? (
                  <>
                    <WifiOff className="size-3.5 text-[#D99A18]" />
                    <span className="hidden md:inline">Offline Mode</span>
                  </>
                ) : (
                  <>
                    <span className="size-2 rounded-full bg-[#16845B] animate-pulse" />
                    <span className="hidden md:inline">Connected</span>
                  </>
                )}
              </button>
            </TooltipTrigger>
            <TooltipContent side="bottom" className="text-xs">
              {isOffline
                ? 'Offline mode active. Click to simulate reconnecting.'
                : 'Connected to State Central Animal Health Repository. Click to simulate offline mode.'}
            </TooltipContent>
          </Tooltip>

          {/* Alerts Notification Dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                className="size-8.5 rounded-lg border border-[#E4EAF0] bg-white text-[#18232B] hover:bg-[#F7F9FB] relative flex items-center justify-center transition-colors cursor-pointer"
                aria-label="Notifications"
              >
                <Bell className="size-4 text-[#667482]" />
                {unreadCount > 0 && (
                  <span className="absolute -top-1 -right-1 size-4 rounded-full bg-[#C94343] text-white text-[9px] font-bold flex items-center justify-center ring-2 ring-white">
                    {unreadCount}
                  </span>
                )}
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-80 p-0 shadow-lg">
              <div className="p-3 border-b border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
                <div className="flex items-center gap-1.5">
                  <ShieldAlert className="size-4 text-[#C94343]" />
                  <span className="font-bold text-xs text-[#18232B]">
                    Active Surveillance Alerts
                  </span>
                </div>
                <Badge variant="critical" className="text-[10px] py-0">
                  {unreadCount} Unread
                </Badge>
              </div>
              <div className="max-h-72 overflow-y-auto divide-y divide-[#E4EAF0]">
                {INITIAL_GOVT_ALERTS.slice(0, 3).map((a) => (
                  <div key={a.id} className="p-3 hover:bg-[#F7F9FB] transition-colors text-xs space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-[#18232B] line-clamp-1">{a.title}</span>
                      <span className="text-[10px] text-[#667482] shrink-0">{a.time}</span>
                    </div>
                    <p className="text-[#667482] text-[11px] line-clamp-2 leading-relaxed">
                      {a.description}
                    </p>
                  </div>
                ))}
              </div>
              <div className="p-2 border-t border-[#E4EAF0] bg-[#F7F9FB] text-center">
                <Link
                  to="/alerts"
                  className="text-xs font-semibold text-[#1769AA] hover:underline"
                >
                  View All State Alerts →
                </Link>
              </div>
            </DropdownMenuContent>
          </DropdownMenu>

          {/* Government Officer Profile Dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                className="flex items-center gap-2 pl-2 pr-2.5 py-1 rounded-xl border border-[#E4EAF0] bg-white hover:bg-[#F7F9FB] transition-colors cursor-pointer text-left"
                aria-label="Officer Profile Menu"
              >
                <div className="size-7 rounded-lg bg-[#12304A] text-white flex items-center justify-center font-bold text-xs shrink-0">
                  RP
                </div>
                <div className="hidden xl:flex flex-col">
                  <span className="font-bold text-xs text-[#18232B] leading-tight">
                    Dr. Rajesh Patil
                  </span>
                  <span className="text-[10px] text-[#667482] leading-tight truncate">
                    Joint Director, Animal Husbandry
                  </span>
                </div>
                <ChevronDown className="size-3.5 text-[#667482]" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56 shadow-lg">
              <DropdownMenuLabel>
                <div className="font-bold text-xs text-[#18232B]">Dr. Rajesh Patil</div>
                <div className="text-[11px] text-[#667482] font-normal">
                  District Animal Husbandry Officer / HQ
                </div>
                <div className="text-[10px] text-[#1769AA] font-medium mt-0.5">
                  Maharashtra Animal Health Portal
                </div>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem asChild>
                <Link to="/settings" className="flex items-center gap-2">
                  <User className="size-3.5 text-[#667482]" />
                  <span>Official Profile & Roster</span>
                </Link>
              </DropdownMenuItem>
              <DropdownMenuItem asChild>
                <Link to="/settings" className="flex items-center gap-2">
                  <Settings className="size-3.5 text-[#667482]" />
                  <span>Surveillance Sensitivity</span>
                </Link>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="text-[#C94343] focus:text-[#C94343] focus:bg-[#FDECEC]">
                <LogOut className="size-3.5 mr-2" />
                <span>Sign Out</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
};
