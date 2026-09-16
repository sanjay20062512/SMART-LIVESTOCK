import React, { useState } from 'react';
import { REPORTS_CATALOG, TABLE_REPORT_RECORDS } from '@/data/reports';
import { ReportPreviewModal } from '@/components/modals/ReportPreviewModal';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { RiskBadge } from '@/components/common/RiskBadge';
import {
  Download,
  Printer,
  Search,
  ChevronLeft,
  ChevronRight,
  Eye
} from 'lucide-react';

export const ReportsView: React.FC = () => {
  const [activeCategory, setActiveCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDistrict, setSelectedDistrict] = useState('All');
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 8;

  const [previewModalOpen, setPreviewModalOpen] = useState(false);
  const [activeReportTitle, setActiveReportTitle] = useState(
    'Maharashtra Weekly Epidemiological Surveillance Bulletin'
  );

  const categories = [
    'All',
    'Disease Trends',
    'District Risk Summary',
    'Vaccination Coverage',
    'Mortality Reports',
    'Response Performance',
    'Campaign Performance'
  ];

  const filteredReports = REPORTS_CATALOG.filter((rep) => {
    if (activeCategory === 'All') return true;
    return rep.category === activeCategory;
  });

  const filteredRecords = TABLE_REPORT_RECORDS.filter((rec) => {
    const matchesSearch =
      rec.district.toLowerCase().includes(searchQuery.toLowerCase()) ||
      rec.primaryDisease.toLowerCase().includes(searchQuery.toLowerCase()) ||
      rec.responseUnit.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesDistrict =
      selectedDistrict === 'All' || rec.district === selectedDistrict;

    return matchesSearch && matchesDistrict;
  });

  const totalPages = Math.ceil(filteredRecords.length / pageSize) || 1;
  const paginatedRecords = filteredRecords.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  const handleOpenPreview = (title: string) => {
    setActiveReportTitle(title);
    setPreviewModalOpen(true);
  };

  const handleExportCSV = () => {
    const headers = [
      'Record ID',
      'District',
      'Primary Disease',
      'Active Cases',
      'Mortality',
      'Coverage',
      'Risk Level',
      'Response Unit',
      'Audit Status'
    ];
    const rows = filteredRecords.map((r) => [
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
    const csvContent =
      'data:text/csv;charset=utf-8,' +
      [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    const timestamp = '2026_09_13';
    link.setAttribute('download', `Maharashtra_Animal_Health_Report_${timestamp}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#087F73] uppercase tracking-wider">
              State Statistical Records
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Epidemiological Intelligence</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight">
            Reports & Analytical Bulletins
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Generate printable government epidemiological dossiers, download validated surveillance logs, and audit district veterinary performance.
          </p>
        </div>

        <div className="flex items-center gap-2 self-start md:self-auto">
          <Button
            variant="secondary"
            size="sm"
            onClick={handleExportCSV}
            className="gap-1.5 text-xs"
          >
            <Download className="size-4" />
            Export CSV
          </Button>

          <Button
            variant="default"
            size="sm"
            onClick={() => handleOpenPreview('Maharashtra Weekly Epidemiological Surveillance Bulletin')}
            className="gap-1.5 bg-[#12304A] hover:bg-[#0d2336] text-xs"
          >
            <Printer className="size-4" />
            Print Official Bulletin
          </Button>
        </div>
      </div>

      {/* Category Filter Pills */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition-colors cursor-pointer ${
              activeCategory === cat
                ? 'bg-[#12304A] text-white shadow-xs'
                : 'bg-white border border-[#E4EAF0] text-[#667482] hover:text-[#18232B] hover:bg-[#F7F9FB]'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Report Dossiers Catalog Cards */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="text-base font-bold text-[#18232B] tracking-tight">
            Official Government Publication Catalog
          </h2>
          <span className="text-xs text-[#667482]">Certified state bulletins</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredReports.map((rep) => (
            <Card
              key={rep.id}
              className="border-[#E4EAF0] shadow-xs hover:border-[#CBD5E1] transition-all flex flex-col justify-between"
            >
              <CardContent className="p-5 space-y-3">
                <div className="space-y-1">
                  <div className="flex items-center justify-between">
                    <Badge variant="secondary" className="text-[10px] py-0 px-1.5">
                      {rep.category}
                    </Badge>
                    <span className="text-[11px] text-[#667482]">{rep.fileSize}</span>
                  </div>
                  <h3 className="font-bold text-sm text-[#18232B] line-clamp-2 leading-snug">
                    {rep.title}
                  </h3>
                  <span className="text-[11px] text-[#667482] block">{rep.period}</span>
                </div>

                <div className="pt-2 border-t border-[#E4EAF0] flex items-center justify-between text-xs">
                  <span className="text-[#667482]">
                    Generated: <strong>{rep.generatedDate}</strong>
                  </span>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleOpenPreview(rep.title)}
                    className="h-8 text-xs text-[#1769AA] gap-1 px-2"
                  >
                    <Eye className="size-3.5" />
                    Preview
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Detailed Surveillance Data Table Section */}
      <Card className="border-[#E4EAF0] shadow-xs">
        <CardHeader className="pb-4 border-b border-[#E4EAF0]">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <CardTitle className="text-base font-bold text-[#18232B]">
                District Epidemiological Audit Registry
              </CardTitle>
              <CardDescription className="text-xs text-[#667482]">
                Granular field surveillance logs across Maharashtra veterinary administrative blocks.
              </CardDescription>
            </div>

            {/* Table Search & Filter */}
            <div className="flex flex-wrap items-center gap-2">
              <select
                value={selectedDistrict}
                onChange={(e) => {
                  setSelectedDistrict(e.target.value);
                  setCurrentPage(1);
                }}
                className="h-8 px-2.5 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
              >
                <option value="All">All Districts</option>
                <option value="Nagpur">Nagpur</option>
                <option value="Pune">Pune</option>
                <option value="Amravati">Amravati</option>
                <option value="Nashik">Nashik</option>
                <option value="Chandrapur">Chandrapur</option>
                <option value="Jalgaon">Jalgaon</option>
                <option value="Solapur">Solapur</option>
                <option value="Satara">Satara</option>
                <option value="Thane">Thane</option>
              </select>

              <div className="relative">
                <Search className="size-3.5 text-[#667482] absolute left-2.5 top-2.5" />
                <Input
                  value={searchQuery}
                  onChange={(e) => {
                    setSearchQuery(e.target.value);
                    setCurrentPage(1);
                  }}
                  placeholder="Search disease or unit..."
                  className="pl-8 h-8 text-xs w-44 sm:w-56"
                />
              </div>
            </div>
          </div>
        </CardHeader>

        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead className="bg-[#F7F9FB] text-[#667482] border-b border-[#E4EAF0] font-semibold sticky top-0">
                <tr>
                  <th className="py-3 px-4">District</th>
                  <th className="py-3 px-4">Suspected Disease</th>
                  <th className="py-3 px-4 text-center">Active Cases</th>
                  <th className="py-3 px-4 text-center">Mortality</th>
                  <th className="py-3 px-4">Vaccination</th>
                  <th className="py-3 px-4">Risk Tier</th>
                  <th className="py-3 px-4">Assigned Veterinary Unit</th>
                  <th className="py-3 px-4">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#E4EAF0] text-[#18232B]">
                {paginatedRecords.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="text-center py-8 text-[#667482]">
                      No audit records found matching your query.
                    </td>
                  </tr>
                ) : (
                  paginatedRecords.map((rec) => (
                    <tr
                      key={rec.id}
                      className="hover:bg-[#F7F9FB]/80 transition-colors"
                    >
                      <td className="py-3 px-4 font-bold">{rec.district}</td>
                      <td className="py-3 px-4 font-medium text-[#1769AA]">{rec.primaryDisease}</td>
                      <td className="py-3 px-4 text-center font-bold">{rec.activeCases}</td>
                      <td className="py-3 px-4 text-center text-[#C94343] font-bold">{rec.mortality}</td>
                      <td className="py-3 px-4 font-semibold text-[#087F73]">{rec.coverage}</td>
                      <td className="py-3 px-4">
                        <RiskBadge level={rec.riskLevel} />
                      </td>
                      <td className="py-3 px-4 text-[#667482]">{rec.responseUnit}</td>
                      <td className="py-3 px-4">
                        <Badge variant="outline" className="text-[10px] py-0">
                          {rec.auditStatus}
                        </Badge>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Table Pagination */}
          <div className="p-4 border-t border-[#E4EAF0] flex items-center justify-between text-xs text-[#667482] bg-[#F7F9FB]">
            <span>
              Showing <strong>{(currentPage - 1) * pageSize + 1}</strong> to{' '}
              <strong>{Math.min(currentPage * pageSize, filteredRecords.length)}</strong> of{' '}
              <strong>{filteredRecords.length}</strong> records
            </span>

            <div className="flex items-center gap-1.5">
              <Button
                variant="outline"
                size="sm"
                disabled={currentPage <= 1}
                onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
                className="h-8 px-2.5 text-xs"
              >
                <ChevronLeft className="size-3.5" />
                Previous
              </Button>
              <span className="px-2 font-semibold text-[#18232B]">
                {currentPage} / {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                disabled={currentPage >= totalPages}
                onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
                className="h-8 px-2.5 text-xs"
              >
                Next
                <ChevronRight className="size-3.5" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Printable Report Modal */}
      <ReportPreviewModal
        isOpen={previewModalOpen}
        onClose={() => setPreviewModalOpen(false)}
        reportTitle={activeReportTitle}
        reportCategory={activeCategory === 'All' ? 'Disease Trends' : activeCategory}
      />
    </div>
  );
};
