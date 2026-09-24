// Smart Livestock — NEW Government Reports Screen
// Ports React ReportsView: report catalog, district data table, search/filter.

import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';

class GovtNewReports extends StatefulWidget {
  const GovtNewReports({super.key});

  @override
  State<GovtNewReports> createState() => _GovtNewReportsState();
}

class _GovtNewReportsState extends State<GovtNewReports> {
  String _activeCategory = 'All';
  String _searchQuery = '';

  List<ReportSummary> get _filteredReports {
    if (_activeCategory == 'All') return reportsCatalog;
    return reportsCatalog.where((r) => r.category == _activeCategory).toList();
  }

  List<DistrictRecord> get _filteredRecords {
    if (_searchQuery.isEmpty) return districtRecords;
    final q = _searchQuery.toLowerCase();
    return districtRecords.where((r) =>
      r.district.toLowerCase().contains(q) ||
      r.primaryDisease.toLowerCase().contains(q) ||
      r.responseUnit.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFE6F4F1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('State Statistical Records', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF087F73), letterSpacing: 0.5)),
                          ),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: Color(0xFF667482), fontSize: 11)),
                          const SizedBox(width: 6),
                          const Text('Epidemiological Intelligence', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Reports & Analytical Bulletins', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF18232B), letterSpacing: -0.4)),
                      const SizedBox(height: 4),
                      const Text('Government epidemiological dossiers, validated surveillance logs, and district veterinary performance.', style: TextStyle(fontSize: 11.5, color: Color(0xFF667482), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Report Catalog Section ────────────────────────────────────
            const Text('Report Catalog', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
            const SizedBox(height: 10),
            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Disease Trends', 'District Risk Summary', 'Vaccination Coverage', 'Mortality Reports', 'Response Performance', 'Campaign Performance']
                    .map((cat) {
                  final isActive = _activeCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF12304A) : GovtColors.surface,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: isActive ? const Color(0xFF12304A) : const Color(0xFFE4EAF0)),
                        ),
                        child: Text(cat, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFF667482))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Report cards
            ..._filteredReports.map((rep) => _reportCard(rep, context)),

            const SizedBox(height: 24),

            // ── District Data Table ──────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('District Surveillance Data Table', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF18232B))),
                      SizedBox(height: 2),
                      Text('Live district-level epidemiological records.', style: TextStyle(fontSize: 11, color: Color(0xFF667482))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV export ready — in a production build this would download the file.'), backgroundColor: Color(0xFF12304A))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: const Color(0xFF12304A), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.download_outlined, size: 14, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Export CSV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13, color: Color(0xFF18232B)),
              decoration: InputDecoration(
                hintText: 'Search by district, disease, or response unit…',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF667482)),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF667482)),
                filled: true,
                fillColor: GovtColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4EAF0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4EAF0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF087F73), width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            // Data table
            _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(ReportSummary rep, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFEAF3FB), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF1769AA)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rep.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF18232B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${rep.period}  •  ${rep.recordsCount.toLocaleString()} records  •  ${rep.fileSize}', style: const TextStyle(fontSize: 10, color: Color(0xFF667482))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFE6F4EF), borderRadius: BorderRadius.circular(4)),
                child: Text(rep.status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF087F73))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE4EAF0)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFEAF3FB), borderRadius: BorderRadius.circular(4)),
                child: Text(rep.category, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1769AA))),
              ),
              const SizedBox(width: 8),
              Text('Generated: ${rep.generatedDate}', style: const TextStyle(fontSize: 10, color: Color(0xFF667482))),
              const Spacer(),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening preview: ${rep.title}'), backgroundColor: const Color(0xFF12304A))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 12, color: Color(0xFF667482)),
                      SizedBox(width: 4),
                      Text('Preview', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF667482))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download initiated.'), backgroundColor: Color(0xFF12304A))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF12304A), borderRadius: BorderRadius.circular(6)),
                  child: const Row(
                    children: [
                      Icon(Icons.download_outlined, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Download', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    final records = _filteredRecords;
    return Container(
      decoration: BoxDecoration(
        color: GovtColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF7F9FB)),
          dividerThickness: 0.5,
          horizontalMargin: 14,
          columnSpacing: 16,
          dataRowMinHeight: 44,
          dataRowMaxHeight: 50,
          columns: const [
            DataColumn(label: Text('District', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)))),
            DataColumn(label: Text('Disease', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)))),
            DataColumn(label: Text('Cases', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482))), numeric: true),
            DataColumn(label: Text('Mortality', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482))), numeric: true),
            DataColumn(label: Text('Coverage', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)))),
            DataColumn(label: Text('Risk', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)))),
            DataColumn(label: Text('Audit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF667482)))),
          ],
          rows: records.map((r) {
            final rColor = r.riskLevel == 'Critical'
                ? const Color(0xFFC94343)
                : r.riskLevel == 'High'
                    ? const Color(0xFFE65100)
                    : r.riskLevel == 'Moderate'
                        ? const Color(0xFFD99A18)
                        : const Color(0xFF16845B);
            final rBg = r.riskLevel == 'Critical'
                ? const Color(0xFFFDECEC)
                : r.riskLevel == 'High'
                    ? const Color(0xFFFFEDD5)
                    : r.riskLevel == 'Moderate'
                        ? const Color(0xFFFFF5D6)
                        : const Color(0xFFE6F4EF);
            return DataRow(cells: [
              DataCell(Text(r.district, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF18232B)))),
              DataCell(Text(r.primaryDisease, style: const TextStyle(fontSize: 11, color: Color(0xFF18232B)))),
              DataCell(Text('${r.activeCases}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFC94343)))),
              DataCell(Text('${r.mortality}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF667482)))),
              DataCell(Text(r.coverage, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: int.tryParse(r.coverage.replaceAll('%', '')) != null && int.parse(r.coverage.replaceAll('%', '')) >= 85 ? const Color(0xFF087F73) : const Color(0xFFC94343)))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: rBg, borderRadius: BorderRadius.circular(4)),
                child: Text(r.riskLevel, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: rColor)),
              )),
              DataCell(Text(r.auditStatus, style: const TextStyle(fontSize: 10.5, color: Color(0xFF667482)))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

extension _LocaleInt on int {
  String toLocaleString() {
    final s = toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
