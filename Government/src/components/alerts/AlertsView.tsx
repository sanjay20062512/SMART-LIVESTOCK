import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { INITIAL_GOVT_ALERTS } from '@/data/alerts';
import type { GovtAlert } from '@/types/government';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Bell,
  CheckCircle2,
  Clock,
  ShieldAlert,
  AlertTriangle,
  FileText,
  Check,
  ArrowRight
} from 'lucide-react';

export const AlertsView: React.FC = () => {
  const navigate = useNavigate();
  const [alerts, setAlerts] = useState<GovtAlert[]>(INITIAL_GOVT_ALERTS);
  const [activeFilter, setActiveFilter] = useState<'All' | 'Critical' | 'High' | 'Unread' | 'Resolved'>('All');

  const handleMarkRead = (id: string) => {
    setAlerts((prev) =>
      prev.map((a) => (a.id === id ? { ...a, isRead: true } : a))
    );
  };

  const handleResolve = (id: string) => {
    setAlerts((prev) =>
      prev.map((a) => (a.id === id ? { ...a, resolved: true, isRead: true } : a))
    );
  };

  const filteredAlerts = alerts.filter((a) => {
    if (activeFilter === 'Critical') return a.priority === 'Critical';
    if (activeFilter === 'High') return a.priority === 'High';
    if (activeFilter === 'Unread') return !a.isRead;
    if (activeFilter === 'Resolved') return a.resolved;
    return true;
  });

  const getAlertIcon = (type: string) => {
    switch (type) {
      case 'Outbreak':
        return <ShieldAlert className="size-4 text-[#C94343]" />;
      case 'Risk Escalation':
        return <AlertTriangle className="size-4 text-[#D99A18]" />;
      case 'Lab Confirmation':
        return <FileText className="size-4 text-[#1769AA]" />;
      default:
        return <Bell className="size-4 text-[#087F73]" />;
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#C94343] uppercase tracking-wider">
              Surveillance Dispatch
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Real-Time Notifications</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight">
            Urgent Disease Alerts & Advisories
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Monitor real-time epidemiological surge signals, laboratory confirmations, and advisory triggers across Maharashtra.
          </p>
        </div>

        <Button
          variant="secondary"
          size="sm"
          onClick={() => setAlerts((prev) => prev.map((a) => ({ ...a, isRead: true })))}
          className="text-xs self-start md:self-auto"
        >
          Mark All as Read
        </Button>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        {(['All', 'Critical', 'High', 'Unread', 'Resolved'] as const).map((filter) => {
          const count =
            filter === 'All'
              ? alerts.length
              : filter === 'Critical'
              ? alerts.filter((a) => a.priority === 'Critical').length
              : filter === 'High'
              ? alerts.filter((a) => a.priority === 'High').length
              : filter === 'Unread'
              ? alerts.filter((a) => !a.isRead).length
              : alerts.filter((a) => a.resolved).length;

          return (
            <button
              key={filter}
              onClick={() => setActiveFilter(filter)}
              className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer ${
                activeFilter === filter
                  ? 'bg-[#12304A] text-white shadow-xs'
                  : 'bg-white border border-[#E4EAF0] text-[#667482] hover:text-[#18232B] hover:bg-[#F7F9FB]'
              }`}
            >
              <span>{filter}</span>
              <span
                className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                  activeFilter === filter
                    ? 'bg-white/20 text-white'
                    : 'bg-[#EAF3FB] text-[#1769AA]'
                }`}
              >
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Alerts List */}
      <div className="space-y-3">
        {filteredAlerts.length === 0 ? (
          <div className="p-12 text-center bg-white rounded-xl border border-dashed border-[#E4EAF0] text-[#667482]">
            <CheckCircle2 className="size-8 mx-auto text-[#16845B] mb-2" />
            <h3 className="font-bold text-sm text-[#18232B]">No alerts matching this filter</h3>
            <p className="text-xs text-[#667482] mt-1">All high-priority signals in this category have been acknowledged.</p>
          </div>
        ) : (
          filteredAlerts.map((alert) => (
            <Card
              key={alert.id}
              className={`border transition-all ${
                !alert.isRead
                  ? 'border-[#1769AA]/40 bg-white shadow-xs'
                  : 'border-[#E4EAF0] bg-white opacity-90'
              }`}
            >
              <CardContent className="p-4 sm:p-5 space-y-3">
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-3">
                  <div className="space-y-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <div className="size-7 rounded-lg bg-[#F7F9FB] border border-[#E4EAF0] flex items-center justify-center shrink-0">
                        {getAlertIcon(alert.type)}
                      </div>
                      <span className="font-bold text-sm text-[#18232B] leading-tight">
                        {alert.title}
                      </span>
                      {!alert.isRead && (
                        <span className="size-2 rounded-full bg-[#1769AA] shrink-0" title="Unread" />
                      )}
                    </div>

                    <p className="text-xs text-[#667482] leading-relaxed pl-9">
                      {alert.description}
                    </p>
                  </div>

                  <div className="flex items-center gap-2 pl-9 sm:pl-0 shrink-0 self-start sm:self-auto">
                    <Badge
                      variant={
                        alert.priority === 'Critical'
                          ? 'critical'
                          : alert.priority === 'High'
                          ? 'high'
                          : 'moderate'
                      }
                      className="text-[10px] py-0 px-1.5"
                    >
                      {alert.priority}
                    </Badge>
                    <span className="text-[11px] text-[#667482] flex items-center gap-1">
                      <Clock className="size-3" />
                      {alert.time}
                    </span>
                  </div>
                </div>

                <div className="pt-2 border-t border-[#E4EAF0] flex flex-wrap items-center justify-between gap-2 text-xs pl-9">
                  <span className="text-[#1769AA] font-semibold">
                    District Jurisdiction: <strong>{alert.district}</strong>
                  </span>

                  <div className="flex items-center gap-2">
                    {!alert.isRead && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleMarkRead(alert.id)}
                        className="h-8 text-xs text-[#667482]"
                      >
                        Mark Read
                      </Button>
                    )}

                    {!alert.resolved ? (
                      <Button
                        variant="secondary"
                        size="sm"
                        onClick={() => handleResolve(alert.id)}
                        className="h-8 text-xs gap-1"
                      >
                        <Check className="size-3.5 text-[#16845B]" />
                        Resolve Alert
                      </Button>
                    ) : (
                      <span className="text-xs text-[#16845B] font-semibold flex items-center gap-1">
                        <CheckCircle2 className="size-3.5" /> Resolved
                      </span>
                    )}

                    <Button
                      variant="default"
                      size="sm"
                      onClick={() => navigate('/disease-intelligence')}
                      className="h-8 text-xs gap-1 bg-[#12304A]"
                    >
                      <span>Take Action</span>
                      <ArrowRight className="size-3.5" />
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
};
