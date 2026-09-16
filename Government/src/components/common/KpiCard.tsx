import React from 'react';
import { Card, CardContent } from '@/components/ui/card';
import type { LucideIcon } from 'lucide-react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { cn } from '@/lib/utils';

interface KpiCardProps {
  title: string;
  value: string | number;
  subtitle: string;
  trend?: string;
  trendDirection?: 'up' | 'down' | 'neutral';
  isAlertTrend?: boolean; // true if 'up' is negative (e.g. cases)
  icon: LucideIcon;
  badgeText?: string;
  statusColor?: 'teal' | 'navy' | 'amber' | 'red' | 'green';
  onClick?: () => void;
  className?: string;
}

export const KpiCard: React.FC<KpiCardProps> = ({
  title,
  value,
  subtitle,
  trend,
  trendDirection = 'neutral',
  isAlertTrend = false,
  icon: Icon,
  badgeText,
  statusColor = 'navy',
  onClick,
  className
}) => {
  const getIconBg = () => {
    switch (statusColor) {
      case 'teal':
        return 'bg-[#EAF7F2] text-[#087F73] border-[#087F73]/20';
      case 'amber':
        return 'bg-[#FFF5D6] text-[#B87A04] border-[#D99A18]/30';
      case 'red':
        return 'bg-[#FDECEC] text-[#C94343] border-[#C94343]/20';
      case 'green':
        return 'bg-[#EAF7F2] text-[#16845B] border-[#16845B]/20';
      case 'navy':
      default:
        return 'bg-[#EAF3FB] text-[#12304A] border-[#1769AA]/20';
    }
  };

  const getTrendColor = () => {
    if (trendDirection === 'neutral') return 'text-[#667482]';
    if (isAlertTrend) {
      return trendDirection === 'up' ? 'text-[#C94343]' : 'text-[#16845B]';
    }
    return trendDirection === 'up' ? 'text-[#16845B]' : 'text-[#C94343]';
  };

  return (
    <Card
      onClick={onClick}
      className={cn(
        'relative overflow-hidden transition-all duration-200 border-[#E4EAF0] hover:border-[#CBD5E1] hover:shadow-md cursor-default',
        onClick && 'cursor-pointer active:scale-[0.99]',
        className
      )}
    >
      <CardContent className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1">
            <span className="text-xs font-semibold text-[#667482] uppercase tracking-wider block">
              {title}
            </span>
            <div className="flex items-baseline gap-2">
              <span className="text-2xl sm:text-3xl font-bold tracking-tight text-[#18232B]">
                {value}
              </span>
              {badgeText && (
                <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-[#EAF3FB] text-[#1769AA] border border-[#1769AA]/20">
                  {badgeText}
                </span>
              )}
            </div>
          </div>
          <div
            className={cn(
              'size-10 rounded-xl flex items-center justify-center border shrink-0',
              getIconBg()
            )}
          >
            <Icon className="size-5" />
          </div>
        </div>

        <div className="mt-4 pt-3 border-t border-[#E4EAF0]/60 flex items-center justify-between text-xs">
          <span className="text-[#667482] line-clamp-1">{subtitle}</span>
          {trend && (
            <div className={cn('flex items-center gap-1 font-semibold shrink-0', getTrendColor())}>
              {trendDirection === 'up' && <TrendingUp className="size-3.5" />}
              {trendDirection === 'down' && <TrendingDown className="size-3.5" />}
              {trendDirection === 'neutral' && <Minus className="size-3.5" />}
              <span>{trend}</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};
