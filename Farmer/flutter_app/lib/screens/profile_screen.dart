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
    LocalizationService.instance.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    LocalizationService.instance.removeListener(_onDataChanged);
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
                  Text(
                    context.tr('edit_farmer_details'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                decoration: InputDecoration(
                  labelText: context.tr('full_name'),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: context.tr('mobile_number'),
                  prefixIcon: const Icon(Icons.phone_rounded),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.tr('email_optional'),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: ['English', 'हिन्दी', 'मराठी'].contains(selectedLang)
                    ? selectedLang
                    : (selectedLang.toLowerCase().contains('hi')
                        ? 'हिन्दी'
                        : (selectedLang.toLowerCase().contains('mr') ? 'मराठी' : 'English')),
                decoration: InputDecoration(
                  labelText: context.tr('preferred_language'),
                  prefixIcon: const Icon(Icons.language_rounded),
                ),
                items: ['English', 'हिन्दी', 'मराठी']
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
                  child: Text(context.tr('save_changes'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    Text(
                      context.tr('edit_farm_details'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  decoration: InputDecoration(
                    labelText: context.tr('farm_name_optional'),
                    prefixIcon: const Icon(Icons.agriculture_rounded),
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
                        decoration: InputDecoration(labelText: context.tr('farm_size')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: sizeUnit,
                        decoration: InputDecoration(labelText: context.tr('unit')),
                        items: ['Acres', 'Hectares', 'Cent']
                            .map((u) => DropdownMenuItem(value: u, child: Text(context.translateText(u))))
                            .toList(),
                        onChanged: (v) => setModalState(() => sizeUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stateCtrl,
                  decoration: InputDecoration(labelText: context.tr('state'), prefixIcon: const Icon(Icons.map_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: districtCtrl,
                  decoration: InputDecoration(labelText: context.tr('district'), prefixIcon: const Icon(Icons.location_city_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: blockCtrl,
                  decoration: InputDecoration(labelText: context.tr('block_taluk'), prefixIcon: const Icon(Icons.apartment_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: villageCtrl,
                  decoration: InputDecoration(labelText: context.tr('village'), prefixIcon: const Icon(Icons.villa_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: livestockCtrl,
                  decoration: InputDecoration(labelText: context.tr('livestock_type'), prefixIcon: const Icon(Icons.pets_rounded)),
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
                    child: Text(context.tr('save_farm_details'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
        title: Text(context.tr('logout')),
        content: Text(context.tr('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LanguageSelectionScreen(dataService: widget.dataService)),
                (route) => false,
              );
            },
            child: Text(context.tr('logout'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.dataService.profile;
    final visits = widget.dataService.getFarmerVisits();
    final localizedFullName = context.translateText(profile.fullName);
    final localizedFarmName = profile.farmName != null ? context.translateText(profile.farmName!) : null;
    final initialLetter = localizedFullName.isNotEmpty ? localizedFullName.characters.first : 'F';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('farmer_profile'),
          style: const TextStyle(
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
                      initialLetter,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedFullName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '📱 ${profile.mobileNumber}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                        if (localizedFarmName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '🏡 $localizedFarmName',
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
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('section_farmer_details'),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit_rounded, size: 15, color: AppColors.primary),
                          label: Text(context.tr('edit'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          onPressed: _editFarmerDetails,
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildRow(context.tr('full_name'), localizedFullName),
                    _buildRow(context.tr('mobile_number'), profile.mobileNumber),
                    _buildRow(context.tr('email_optional'), profile.email ?? '—'),
                    _buildRow(context.tr('preferred_language'), LocalizationService.instance.currentLanguage.label),
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
                        Row(
                          children: [
                            const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('section_farm_details'),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit_rounded, size: 15, color: AppColors.primary),
                          label: Text(context.tr('edit'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          onPressed: _editFarmDetails,
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildRow(context.tr('farm_name_optional'), localizedFarmName ?? '—'),
                    _buildRow(context.tr('farm_size'), '${profile.farmSize ?? "—"} ${context.translateText(profile.farmSizeUnit ?? context.tr('acres'))}'),
                    _buildRow(context.tr('location_mode'), context.translateText(profile.farmLocationMode ?? '📍 Current Location')),
                    _buildRow(context.tr('state'), context.translateText(profile.state)),
                    _buildRow(context.tr('district'), context.translateText(profile.district)),
                    _buildRow(context.tr('taluk'), context.translateText(profile.block)),
                    _buildRow(context.tr('village'), context.translateText(profile.village)),
                    _buildRow(context.tr('livestock_type'), context.translateText(profile.livestockType)),
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
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('section_vet_visits'),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5, color: AppColors.textPrimary),
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
                            '${visits.length} ${context.tr(visits.length == 1 ? "vet_visit" : "vet_visits")}',
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
                        child: Column(
                          children: [
                            const Icon(Icons.event_available_outlined, size: 36, color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('no_vet_visits'),
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('no_vet_visits_desc'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                    title: Text(context.tr('load_demo_records'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text(context.tr('load_demo_records_desc'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    onTap: () {
                      widget.dataService.seedDemoData(force: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('demo_data_loaded')), backgroundColor: AppColors.success),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.errorLight,
                      child: Icon(Icons.logout_rounded, color: AppColors.error),
                    ),
                    title: Text(context.tr('logout'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14)),
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
                    '📅 $dateStr ${context.tr('at')} $timeStr',
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
                  isUpcoming ? context.tr('status_confirmed') : context.tr('status_completed'),
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
                '${context.tr('doctor')}: ${context.translateText(v.vetName)}',
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
                  '${context.tr('location')}: ${context.translateText(v.farmLocation)}',
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
                      '${context.tr('notes')}: ${context.translateText(v.observations!)}',
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
                      '${context.tr('prescribed')}: ${context.translateText(v.treatmentGiven!)}',
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
