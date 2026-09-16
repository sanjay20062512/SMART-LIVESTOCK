import React from 'react';
import { Badge } from '@/components/ui/badge';
import type { RiskLevel } from '@/types/government';
import { cn } from '@/lib/utils';

interface RiskBadgeProps {
  level: RiskLevel | string;
  score?: number;
  className?: string;
  showDot?: boolean;
}

export const RiskBadge: React.FC<RiskBadgeProps> = ({
  level,
  score,
  className,
  showDot = true
}) => {
  const normLevel = level.toLowerCase();

  const getVariant = () => {
    switch (normLevel) {
      case 'critical':
        return 'critical';
      case 'high':
        return 'high';
      case 'moderate':
      case 'medium':
        return 'moderate';
      case 'low':
      default:
        return 'low';
    }
  };

  const getDotColor = () => {
    switch (normLevel) {
      case 'critical':
        return 'bg-[#C94343]';
      case 'high':
        return 'bg-[#C2410C]';
      case 'moderate':
      case 'medium':
        return 'bg-[#D99A18]';
      case 'low':
      default:
        return 'bg-[#16845B]';
    }
  };

  const getLabel = () => {
    switch (normLevel) {
      case 'critical':
        return 'Critical';
      case 'high':
        return 'High Risk';
      case 'moderate':
      case 'medium':
        return 'Moderate';
      case 'low':
      default:
        return 'Low Risk';
    }
  };

  return (
    <Badge
      variant={getVariant() as any}
      className={cn('inline-flex items-center gap-1.5 py-0.5 px-2.5 font-semibold text-xs', className)}
    >
      {showDot && <span className={cn('size-1.5 rounded-full shrink-0', getDotColor())} />}
      <span>{getLabel()}</span>
      {score !== undefined && <span className="opacity-80 font-normal">({score}%)</span>}
    </Badge>
  );
};
