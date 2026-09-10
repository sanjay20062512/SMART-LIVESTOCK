import 'package:flutter/material.dart';
import '../services/farmer_data_service.dart';
import '../services/localization_service.dart';
import '../models/vet_visit.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  final FarmerDataService dataService;

  const ProfileScreen({super.key, required this.dataService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    widget.dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  void _editFarmerDetails() {
    final profile = widget.dataService.profile;
    final nameCtrl = TextEditingController(text: profile.fullName);
    final mobileCtrl = TextEditingController(text: profile.mobileNumber);
    final emailCtrl = TextEditingController(text: profile.email ?? '');
    String selectedLang = profile.preferredLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Farmer Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone_rounded),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedLang,
                decoration: const InputDecoration(
                  labelText: 'Preferred Language',
                  prefixIcon: Icon(Icons.language_rounded),
                ),
                items: ['English', 'Tamil', 'Hindi']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedLang = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final updated = widget.dataService.profile.copyWith(
                      fullName: nameCtrl.text.trim(),
                      mobileNumber: mobileCtrl.text.trim(),
                      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                      preferredLanguage: selectedLang,
                    );
                    widget.dataService.updateProfile(updated);
                    LocalizationService.instance.setLanguageByName(selectedLang);
                    Navigator.pop(ctx);
                  },
                  child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editFarmDetails() {
    final profile = widget.dataService.profile;
    final farmNameCtrl = TextEditingController(text: profile.farmName ?? '');
    final farmSizeCtrl = TextEditingController(text: profile.farmSize ?? '5');
    String sizeUnit = profile.farmSizeUnit ?? 'Acres';
    final stateCtrl = TextEditingController(text: profile.state);
    final districtCtrl = TextEditingController(text: profile.district);
    final blockCtrl = TextEditingController(text: profile.block);
    final villageCtrl = TextEditingController(text: profile.village);
    final livestockCtrl = TextEditingController(text: profile.livestockType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Farm Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: farmNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    prefixIcon: Icon(Icons.agriculture_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: farmSizeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Farm Size'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: sizeUnit,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: ['Acres', 'Hectares', 'Cent']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setModalState(() => sizeUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stateCtrl,
                  decoration: const InputDecoration(labelText: 'State', prefixIcon: Icon(Icons.map_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: districtCtrl,
                  decoration: const InputDecoration(labelText: 'District', prefixIcon: Icon(Icons.location_city_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: blockCtrl,
                  decoration: const InputDecoration(labelText: 'Block / Taluk', prefixIcon: Icon(Icons.apartment_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: villageCtrl,
                  decoration: const InputDecoration(labelText: 'Village', prefixIcon: Icon(Icons.villa_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: livestockCtrl,
                  decoration: const InputDecoration(labelText: 'Livestock Type(s)', prefixIcon: Icon(Icons.pets_rounded)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final updated = widget.dataService.profile.copyWith(
                        farmName: farmNameCtrl.text.trim().isEmpty ? null : farmNameCtrl.text.trim(),
                        farmSize: farmSizeCtrl.text.trim(),
                        farmSizeUnit: sizeUnit,
                        state: stateCtrl.text.trim(),
                        district: districtCtrl.text.trim(),
                        block: blockCtrl.text.trim(),
                        village: villageCtrl.text.trim(),
                        livestockType: livestockCtrl.text.trim(),
                      );
                      widget.dataService.updateProfile(updated);
                      Navigator.pop(ctx);
                    },
                    child: const Text('SAVE FARM DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LanguageSelectionScreen(dataService: widget.dataService)),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.dataService.profile;
    final visits = widget.dataService.getFarmerVisits();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Farmer Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Profile Header Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.banner),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'F',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '📱 ${profile.mobileNumber}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                        if (profile.farmName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '🏡 ${profile.farmName}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==============================================================
            // SECTION 1 — FARMER DETAILS
            // ==============================================================
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SECTION 1 — FARMER DETAILS',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit_rounded, size: 15, color: AppColors.primary),
                          label: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          onPressed: _editFarmerDetails,
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildRow('Name', profile.fullName),
                    _buildRow('Mobile', profile.mobileNumber),
                    _buildRow('Email', profile.email ?? '—'),
                    _buildRow('Preferred Language', profile.preferredLanguage),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ==============================================================
            // SECTION 2 — FARM DETAILS
            // ==============================================================
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SECTION 2 — FARM DETAILS',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit_rounded, size: 15, color: AppColors.primary),
                          label: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          onPressed: _editFarmDetails,
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildRow('Farm Name', profile.farmName ?? '—'),
                    _buildRow('Farm Size', '${profile.farmSize ?? "—"} ${profile.farmSizeUnit ?? "Acres"}'),
                    _buildRow('Location Mode', profile.farmLocationMode ?? '📍 Current Location'),
                    _buildRow('State', profile.state),
                    _buildRow('District', profile.district),
                    _buildRow('Block / Taluk', profile.block),
                    _buildRow('Village', profile.village),
                    _buildRow('Livestock Type', profile.livestockType),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ==============================================================
            // SECTION 3 — SCHEDULED VET VISITS & APPOINTMENTS
            // ==============================================================
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SECTION 3 — SCHEDULED VET VISITS',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: visits.isNotEmpty ? AppColors.primaryLight : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            border: Border.all(color: visits.isNotEmpty ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
                          ),
                          child: Text(
                            '${visits.length} Visit${visits.length == 1 ? "" : "s"}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: visits.isNotEmpty ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.borderLight),
                    if (visits.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        alignment: Alignment.center,
                        child: const Column(
                          children: [
                            Icon(Icons.event_available_outlined, size: 36, color: AppColors.textTertiary),
                            SizedBox(height: 8),
                            Text(
                              'No vet visits scheduled yet',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'When a veterinarian accepts your case and schedules a visit, details and dates will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    else
                      ...visits.map((v) => _buildVisitItem(v, AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Demo Actions & Logout
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              color: AppColors.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.science_rounded, color: AppColors.primary),
                    ),
                    title: const Text('Load Demo Records', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Populate animals and alerts for testing', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    onTap: () {
                      widget.dataService.seedDemoData(force: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Demo data loaded.'), backgroundColor: AppColors.success),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.errorLight,
                      child: Icon(Icons.logout_rounded, color: AppColors.error),
                    ),
                    title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13.5)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitItem(VetVisit v, Color primary) {
    final isUpcoming = !v.isCompleted;
    final dateStr = '${v.scheduledDate.day.toString().padLeft(2, "0")}/${v.scheduledDate.month.toString().padLeft(2, "0")}/${v.scheduledDate.year}';
    final timeStr = '${v.scheduledDate.hour.toString().padLeft(2, "0")}:${v.scheduledDate.minute.toString().padLeft(2, "0")}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUpcoming ? const Color(0xFFF0F7FF) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUpcoming ? Colors.blue.shade200 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isUpcoming ? Icons.schedule_rounded : Icons.check_circle_rounded,
                    color: isUpcoming ? const Color(0xFF1565C0) : Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '📅 $dateStr at $timeStr',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isUpcoming ? const Color(0xFF0D47A1) : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.blue : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUpcoming ? 'CONFIRMED' : 'COMPLETED',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Doctor: ${v.vetName}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Location: ${v.farmLocation}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (v.observations != null && v.observations!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Notes: ${v.observations}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (v.treatmentGiven != null && v.treatmentGiven!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medication_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Prescribed: ${v.treatmentGiven}',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
