import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/cluster.dart';
import '../../theme/app_theme.dart';

class VetClusterScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const VetClusterScreen({super.key, required this.dataService});

  @override
  State<VetClusterScreen> createState() => _VetClusterScreenState();
}

class _VetClusterScreenState extends State<VetClusterScreen> {
  ClusterRisk? _selectedRiskFilter;
  String _selectedSpeciesFilter = 'All';
  String _selectedStatusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _speciesOptions = [
    'All',
    'Cattle',
    'Buffalo',
    'Goat',
    'Sheep',
    'Poultry',
    'Other'
  ];

  final List<String> _statusOptions = [
    'All',
    'New',
    'Investigation',
    'Monitoring',
    'Resolved',
    'Escalated',
    'Contained'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        final allClusters = widget.dataService.getAllClusters();

        // Calculate summary counts
        final totalCount = allClusters.length;
        final highCount = allClusters.where((c) => c.riskLevel == ClusterRisk.high).length;
        final mediumCount = allClusters.where((c) => c.riskLevel == ClusterRisk.medium).length;
        final lowCount = allClusters.where((c) => c.riskLevel == ClusterRisk.low).length;

        // Apply filters
        final filteredClusters = widget.dataService.getAllClusters(
          risk: _selectedRiskFilter,
          searchQuery: _searchController.text,
          species: _selectedSpeciesFilter,
          status: _selectedStatusFilter == 'All'
              ? null
              : ClusterStatus.values.firstWhere(
                  (s) => s.displayName.toLowerCase() == _selectedStatusFilter.toLowerCase(),
                  orElse: () => ClusterStatus.monitoring,
                ),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Possible Clusters',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                  icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                  label: const Text('Create Cluster', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  onPressed: () => _openCreateClusterModal(context),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Top KPI Summary Cards & Filters Container
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  children: [
                    // Summary KPI Cards Row
                    Row(
                      children: [
                        _summaryKpiCard('Total Clusters', totalCount.toString(), AppColors.primary, AppColors.surfaceSubtle),
                        const SizedBox(width: 8),
                        _summaryKpiCard('High Risk', highCount.toString(), AppColors.riskCritical, AppColors.errorLight),
                        const SizedBox(width: 8),
                        _summaryKpiCard('Medium Risk', mediumCount.toString(), AppColors.riskMedium, AppColors.warningLight),
                        const SizedBox(width: 8),
                        _summaryKpiCard('Low Risk', lowCount.toString(), AppColors.riskLow, AppColors.successLight),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Risk Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _riskChip('All', null, totalCount),
                          const SizedBox(width: 8),
                          _riskChip('High Risk', ClusterRisk.high, highCount),
                          const SizedBox(width: 8),
                          _riskChip('Medium Risk', ClusterRisk.medium, mediumCount),
                          const SizedBox(width: 8),
                          _riskChip('Low Risk', ClusterRisk.low, lowCount),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Search & Secondary Filter Dropdowns Row
                    Row(
                      children: [
                        // Search Box
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search location / name...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Species Filter Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSpeciesFilter,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, size: 18),
                                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
                                items: _speciesOptions.map((s) => DropdownMenuItem(value: s, child: Text('Sp: $s'))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedSpeciesFilter = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Status Filter Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedStatusFilter,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, size: 18),
                                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
                                items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text('St: $s'))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedStatusFilter = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Clusters List
              Expanded(
                child: filteredClusters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                            const SizedBox(height: 16),
                            const Text('No matching clusters found', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Try clearing filters or search criteria', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredClusters.length,
                        itemBuilder: (ctx, i) => _clusterCard(ctx, filteredClusters[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryKpiCard(String title, String count, Color accentColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor)),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accentColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _riskChip(String label, ClusterRisk? risk, int count) {
    final isSelected = _selectedRiskFilter == risk;
    final chipColor = risk?.color ?? Colors.blueGrey;

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedRiskFilter = risk),
      selectedColor: chipColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? chipColor : Colors.grey.shade700,
      ),
      side: BorderSide(color: isSelected ? chipColor : Colors.grey.shade300),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _clusterCard(BuildContext context, OutbreakCluster cluster) {
    final riskColor = cluster.riskLevel.color;
    final isEscalated = cluster.status == ClusterStatus.escalated;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Banner
          Container(
            color: riskColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cluster.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${cluster.location} · ${cluster.district}, ${cluster.state}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Text(
                    cluster.status.displayName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    _stat('Reports', cluster.reportCount.toString(), Icons.description),
                    _stat('Animals', cluster.animalCount.toString(), Icons.pets),
                    _stat('Mortality', cluster.mortality.toString(), Icons.warning_rounded),
                    _stat('Species', cluster.species.split(' ').first, Icons.agriculture),
                  ],
                ),

                const SizedBox(height: 12),

                // Suspected Disease & Description
                if (cluster.suspectedDisease.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.coronavirus_outlined, size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      Text(
                        'Suspected: ${cluster.suspectedDisease}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                if (cluster.description.isNotEmpty) ...[
                  Text(
                    cluster.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                ],

                // Symptoms Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: cluster.symptoms.map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    backgroundColor: cluster.riskLevel.bgColor,
                    side: BorderSide(color: riskColor.withValues(alpha: 0.3)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('View Details'),
                        onPressed: () => _viewClusterDetails(context, cluster),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEscalated ? Colors.grey : Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(isEscalated ? Icons.check_circle : Icons.upload, size: 16),
                        label: Text(isEscalated ? 'Escalated' : 'Escalate'),
                        onPressed: () => _handleEscalate(context, cluster),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  void _handleEscalate(BuildContext context, OutbreakCluster cluster) {
    if (cluster.status == ClusterStatus.escalated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This cluster has already been escalated.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escalate Cluster to Government'),
        content: Text(
          'Escalating "${cluster.name}" will automatically set its priority to HIGH RISK and dispatch an alert to the Government Surveillance Portal.\n\nProceed?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.dataService.escalateCluster(cluster.clusterId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('High-risk cluster escalated to Government authorities.'),
                  backgroundColor: Colors.deepOrange,
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Escalate Now'),
          ),
        ],
      ),
    );
  }

  void _viewClusterDetails(BuildContext context, OutbreakCluster cluster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cluster.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cluster.riskLevel.bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cluster.riskLevel.color),
                  ),
                  child: Text(
                    cluster.riskLevel.displayName,
                    style: TextStyle(color: cluster.riskLevel.color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${cluster.location}, ${cluster.district}, ${cluster.state}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            if (cluster.latitude != null && cluster.longitude != null)
              Text(
                'Coordinates: ${cluster.latitude}, ${cluster.longitude}',
                style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),

            const Divider(height: 24),

            const Text('Cluster Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            ListTile(
              dense: true,
              leading: const Icon(Icons.pets, color: Colors.deepOrange),
              title: const Text('Species & Affected Animals'),
              subtitle: Text('${cluster.species} · ${cluster.animalCount} animals affected · ${cluster.mortality} mortality'),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.assessment, color: Colors.deepOrange),
              title: const Text('Reports & Status'),
              subtitle: Text('${cluster.reportCount} reports · Status: ${cluster.status.displayName}'),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.coronavirus, color: Colors.deepOrange),
              title: const Text('Suspected Disease'),
              subtitle: Text(cluster.suspectedDisease),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.notes, color: Colors.deepOrange),
              title: const Text('Description'),
              subtitle: Text(cluster.description),
            ),

            const SizedBox(height: 12),
            const Text('Symptoms Reported:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: cluster.symptoms.map((s) => Chip(
                label: Text(s, style: const TextStyle(fontSize: 11)),
                backgroundColor: Colors.orange.shade50,
              )).toList(),
            ),

            const Divider(height: 24),

            // Edit Risk Level Option
            const Text('Update Risk Level:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: ClusterRisk.values.map((r) {
                final isCurrent = cluster.riskLevel == r;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isCurrent ? r.color : Colors.white,
                        foregroundColor: isCurrent ? Colors.white : r.color,
                        side: BorderSide(color: r.color),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        widget.dataService.updateClusterRisk(cluster.clusterId, r);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Updated cluster risk to ${r.displayName}'),
                            backgroundColor: r.color,
                          ),
                        );
                      },
                      child: Text(r.shortName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateClusterModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final districtCtrl = TextEditingController(text: 'Pune');
    final stateCtrl = TextEditingController(text: 'Maharashtra');
    final reportCountCtrl = TextEditingController(text: '3');
    final animalCountCtrl = TextEditingController(text: '8');
    final mortalityCtrl = TextEditingController(text: '0');
    final symptomsCtrl = TextEditingController(text: 'Fever, Diarrhea, Lethargy');
    final diseaseCtrl = TextEditingController(text: 'Suspected HS');
    final descCtrl = TextEditingController(text: 'High temperature and diarrhoea observed in multiple animals.');
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();

    ClusterRisk selectedRisk = ClusterRisk.medium;
    ClusterStatus selectedStatus = ClusterStatus.investigation;
    String selectedSpecies = 'Cattle';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Create New Cluster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Cluster Name
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Cluster Name *', hintText: 'e.g. Shirur Livestock Cluster'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter cluster name' : null,
                  ),
                  const SizedBox(height: 10),

                  // Location, District, State Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: locationCtrl,
                          decoration: const InputDecoration(labelText: 'Location / Village *', hintText: 'Uruli Kanchan'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: districtCtrl,
                          decoration: const InputDecoration(labelText: 'District *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: stateCtrl,
                    decoration: const InputDecoration(labelText: 'State *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  // Risk Level Dropdown
                  DropdownButtonFormField<ClusterRisk>(
                    initialValue: selectedRisk,
                    decoration: const InputDecoration(labelText: 'Risk Level *'),
                    items: ClusterRisk.values.map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.displayName, style: TextStyle(color: r.color, fontWeight: FontWeight.bold)),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRisk = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Species Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpecies,
                    decoration: const InputDecoration(labelText: 'Species *'),
                    items: ['Cattle', 'Buffalo', 'Goat', 'Sheep', 'Poultry', 'Other'].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSpecies = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Report count, Animal count, Mortality Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: reportCountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Reports *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          controller: animalCountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Animals *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          controller: mortalityCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Mortality *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Symptoms & Disease
                  TextFormField(
                    controller: symptomsCtrl,
                    decoration: const InputDecoration(labelText: 'Symptoms (comma separated) *', hintText: 'Fever, Diarrhea, Anorexia'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: diseaseCtrl,
                    decoration: const InputDecoration(labelText: 'Disease Suspected *', hintText: 'e.g. Haemorrhagic Septicaemia'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Cluster Description'),
                  ),
                  const SizedBox(height: 10),

                  // Investigation Status
                  DropdownButtonFormField<ClusterStatus>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Investigation Status *'),
                    items: [
                      ClusterStatus.newStatus,
                      ClusterStatus.investigation,
                      ClusterStatus.monitoring,
                      ClusterStatus.resolved
                    ].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Lat/Long (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Latitude (Optional)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Longitude (Optional)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final symptomsList = symptomsCtrl.text
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();

                          final newCluster = OutbreakCluster(
                            clusterId: widget.dataService.generateClusterId(),
                            name: nameCtrl.text.trim(),
                            location: locationCtrl.text.trim(),
                            village: locationCtrl.text.trim().split(',').first,
                            block: 'Haveli',
                            district: districtCtrl.text.trim(),
                            state: stateCtrl.text.trim(),
                            riskLevel: selectedRisk,
                            species: selectedSpecies,
                            reportCount: int.tryParse(reportCountCtrl.text) ?? 1,
                            animalCount: int.tryParse(animalCountCtrl.text) ?? 1,
                            mortality: int.tryParse(mortalityCtrl.text) ?? 0,
                            symptoms: symptomsList,
                            suspectedDisease: diseaseCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            status: selectedStatus,
                            latitude: double.tryParse(latCtrl.text),
                            longitude: double.tryParse(lngCtrl.text),
                            detectedAt: selectedDate,
                          );

                          widget.dataService.addCluster(newCluster);
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                selectedRisk == ClusterRisk.high
                                    ? 'High-risk cluster created & synced to Government Portal!'
                                    : 'Cluster created successfully',
                              ),
                              backgroundColor: selectedRisk.color,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      child: const Text('CREATE CLUSTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
