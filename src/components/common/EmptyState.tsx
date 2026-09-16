import React from 'react';
import { Button } from '@/components/ui/button';
import type { LucideIcon } from 'lucide-react';
import { Inbox } from 'lucide-react';
import { cn } from '@/lib/utils';

interface EmptyStateProps {
  icon?: LucideIcon;
  title: string;
  description: string;
  actionLabel?: string;
  onAction?: () => void;
  className?: string;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  icon: Icon = Inbox,
  title,
  description,
  actionLabel,
  onAction,
  className
}) => {
  return (
    <div
      className={cn(
        'flex flex-col items-center justify-center p-8 sm:p-12 text-center rounded-xl border border-dashed border-[#E4EAF0] bg-white',
        className
      )}
    >
      <div className="size-12 rounded-xl bg-[#EAF3FB] border border-[#1769AA]/20 flex items-center justify-center text-[#1769AA] mb-4">
        <Icon className="size-6" />
      </div>
      <h3 className="text-base font-semibold text-[#18232B] tracking-tight">{title}</h3>
      <p className="mt-1.5 text-xs text-[#667482] max-w-sm leading-relaxed">{description}</p>
      {actionLabel && onAction && (
        <Button onClick={onAction} variant="secondary" size="sm" className="mt-5">
          {actionLabel}
        </Button>
      )}
    </div>
  );
};
