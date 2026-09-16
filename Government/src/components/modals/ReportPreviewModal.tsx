import React from 'react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { TABLE_REPORT_RECORDS } from '@/data/reports';
import { X, Printer, Download, FileText, CheckCircle2 } from 'lucide-react';

interface ReportPreviewModalProps {
  isOpen: boolean;
  onClose: () => void;
  reportTitle?: string;
  reportCategory?: string;
}

export const ReportPreviewModal: React.FC<ReportPreviewModalProps> = ({
  isOpen,
  onClose,
  reportTitle = 'Maharashtra Weekly Epidemiological Surveillance Bulletin',
  reportCategory = 'Disease Trends'
}) => {
  if (!isOpen) return null;

  const handlePrint = () => {
    window.print();
  };

  const handleExportCSV = () => {
    const headers = ['Record ID', 'District', 'Primary Disease', 'Active Cases', 'Mortality', 'Vaccination Coverage', 'Risk Level', 'Response Unit', 'Audit Status'];
    const rows = TABLE_REPORT_RECORDS.map((r) => [
      r.id,
      r.district,
      r.primaryDisease,
      r.activeCases,
      r.mortality,
      r.coverage,
      r.riskLevel,
      r.responseUnit,
      r.auditStatus
    ]);
    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map(e => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `${reportTitle.replace(/\s+/g, '_')}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-[#12304A]/60 backdrop-blur-xs animate-in fade-in-0">
      <div className="bg-white rounded-2xl border border-[#E4EAF0] shadow-2xl w-full max-w-4xl overflow-hidden flex flex-col max-h-[92vh]">
        {/* Header */}
        <div className="px-6 py-4 border-b border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
          <div className="flex items-center gap-3">
            <div className="size-9 rounded-xl bg-[#EAF7F2] text-[#087F73] flex items-center justify-center border border-[#087F73]/20">
              <FileText className="size-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xs font-semibold uppercase tracking-wider text-[#087F73]">
                  Government of Maharashtra
                </span>
                <Badge variant="secondary" className="text-[10px] py-0 px-1.5">
                  Official Bulletin
                </Badge>
              </div>
              <h2 className="text-base font-bold text-[#18232B] tracking-tight">
                {reportTitle}
              </h2>
            </div>
          </div>
          <button
            onClick={onClose}
            className="size-8 rounded-lg text-[#667482] hover:text-[#18232B] hover:bg-[#E4EAF0] flex items-center justify-center transition-colors cursor-pointer"
          >
            <X className="size-4" />
          </button>
        </div>

        {/* Document Body (Printable Paper Look) */}
        <div className="p-6 sm:p-8 overflow-y-auto flex-1 bg-[#F7F9FB] space-y-6">
          <div className="bg-white p-6 sm:p-8 rounded-xl border border-[#E4EAF0] shadow-xs space-y-6 max-w-3xl mx-auto">
            {/* Letterhead */}
            <div className="text-center pb-4 border-b border-[#E4EAF0] space-y-1">
              <span className="text-[11px] font-bold text-[#667482] uppercase tracking-widest block">
                COMMISSIONERATE OF ANIMAL HUSBANDRY, PUNE
              </span>
              <h1 className="text-lg font-bold text-[#12304A]">
                STATE ANIMAL DISEASE SURVEILLANCE & EPIDEMIOLOGY UNIT
              </h1>
              <p className="text-xs text-[#667482]">
                Weekly Intelligence Dossier | Classification: OFFICIAL USE ONLY | Ref: CAH/EPI/2026-W37
              </p>
            </div>

            {/* Meta Row */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 p-4 rounded-lg bg-[#F7F9FB] border border-[#E4EAF0] text-xs">
              <div>
                <span className="text-[#667482] block text-[11px]">Period Covered</span>
                <strong className="text-[#18232B]">05 – 12 Sept 2026</strong>
              </div>
              <div>
                <span className="text-[#667482] block text-[11px]">Reporting Districts</span>
                <strong className="text-[#18232B]">36 of 36 Compliant</strong>
              </div>
              <div>
                <span className="text-[#667482] block text-[11px]">Active Outbreak Zones</span>
                <strong className="text-[#C94343]">Nagpur, Pune, Amravati</strong>
              </div>
              <div>
                <span className="text-[#667482] block text-[11px]">State Coverage Status</span>
                <strong className="text-[#16845B]">68.5% (Target: 85%)</strong>
              </div>
            </div>

            {/* Executive Summary */}
            <div className="space-y-2 text-xs text-[#18232B] leading-relaxed">
              <h3 className="font-bold text-sm text-[#12304A] border-b border-[#E4EAF0] pb-1">
                Executive Epidemiological Assessment
              </h3>
              <p>
                During the 37th epidemiological surveillance cycle of 2026, Maharashtra recorded <strong>1,284 cumulative syndromic livestock cases</strong> across all divisions. Primary clinical pressure remains localized in two acute Foot-and-Mouth Disease (FMD) epicenters: the peri-urban dairy belt of <strong>Nagpur (81% risk)</strong> and the cooperative dairy holdings of <strong>Pune (78% risk)</strong>.
              </p>
              <p>
                Veterinary containment taskforces have completed ring vaccination in 19 priority villages, achieving 68.5% average coverage across high-risk corridors. Prophylactic antibiotics and alum-precipitated HS vaccines have been pre-positioned across the Tapi and Wainganga floodplains.
              </p>
            </div>

            {/* Table of Flagged Districts */}
            <div className="space-y-2">
              <h3 className="font-bold text-xs text-[#12304A] uppercase tracking-wider">
                Priority District Surveillance Log (Top Focus Zones)
              </h3>
              <div className="border border-[#E4EAF0] rounded-lg overflow-hidden">
                <table className="w-full text-left text-xs border-collapse">
                  <thead className="bg-[#F7F9FB] text-[#667482] border-b border-[#E4EAF0] font-semibold text-[11px]">
                    <tr>
                      <th className="p-2.5">District</th>
                      <th className="p-2.5">Primary Syndrome</th>
                      <th className="p-2.5">Active Cases</th>
                      <th className="p-2.5">Mortality</th>
                      <th className="p-2.5">Coverage</th>
                      <th className="p-2.5">Assigned Unit</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-[#E4EAF0] text-[#18232B]">
                    {TABLE_REPORT_RECORDS.slice(0, 7).map((rec) => (
                      <tr key={rec.id} className="hover:bg-[#F7F9FB]/60">
                        <td className="p-2.5 font-bold">{rec.district}</td>
                        <td className="p-2.5">{rec.primaryDisease}</td>
                        <td className="p-2.5 font-semibold">{rec.activeCases}</td>
                        <td className="p-2.5 text-[#C94343] font-semibold">{rec.mortality}</td>
                        <td className="p-2.5">{rec.coverage}</td>
                        <td className="p-2.5 text-[#667482] text-[11px]">{rec.responseUnit}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Signoff */}
            <div className="pt-6 border-t border-[#E4EAF0] flex items-center justify-between text-xs text-[#667482]">
              <div>
                <span>Approved by: <strong>Dr. Rajesh Patil</strong></span>
                <span className="block text-[11px]">Joint Director (Health Surveillance), Pune HQ</span>
              </div>
              <div className="flex items-center gap-1 text-[#16845B] font-semibold text-xs">
                <CheckCircle2 className="size-4" />
                <span>Digitally Authenticated</span>
              </div>
            </div>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="px-6 py-4 border-t border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
          <span className="text-xs text-[#667482]">
            Category: <strong>{reportCategory}</strong> | Records: 36
          </span>
          <div className="flex items-center gap-2">
            <Button variant="secondary" size="sm" onClick={handleExportCSV} className="gap-1.5">
              <Download className="size-4" />
              Export CSV
            </Button>
            <Button variant="default" size="sm" onClick={handlePrint} className="gap-1.5 bg-[#12304A]">
              <Printer className="size-4" />
              Print Bulletin
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};
