// Alerts & Advisories Screen — official communication center with multilingual support

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/advisory.dart';
import 'govt_theme.dart';
import 'widgets/govt_widgets.dart';

class GovtAdvisoryScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtAdvisoryScreen({super.key, required this.dataService});

  @override
  State<GovtAdvisoryScreen> createState() => _GovtAdvisoryScreenState();
}

class _GovtAdvisoryScreenState extends State<GovtAdvisoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        final all = widget.dataService.getAllAdvisories();
        final active = all.where((a) => a.status == AdvisoryStatus.published).toList();
        final drafts = all.where((a) => a.status == AdvisoryStatus.draft).toList();

        return Scaffold(
          backgroundColor: GovtColors.pageBackground,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: GovtColors.brandDark,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alerts & Advisories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    Text('Official animal health communications', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showCreateAdvisory(context)),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'Active (${active.length})'),
                    Tab(text: 'Drafts (${drafts.length})'),
                    const Tab(text: 'Scheduled'),
                    const Tab(text: 'Sent'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _advisoryList(context, active, showSend: false),
                _advisoryList(context, drafts, showSend: true),
                _scheduledList(),
                _sentList(active),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: GovtColors.brand,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.campaign_rounded),
            label: const Text('New Advisory', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            onPressed: () => _showCreateAdvisory(context),
          ),
        );
      },
    );
  }

  Widget _advisoryList(BuildContext context, List<Advisory> advisories, {required bool showSend}) {
    if (advisories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.campaign_outlined, size: 52, color: GovtColors.textDisabled),
            const SizedBox(height: 12),
            Text(showSend ? 'No drafts saved' : 'No active advisories', style: const TextStyle(color: GovtColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            GovtButton(label: 'Create Advisory', icon: Icons.add_rounded, onPressed: () => _showCreateAdvisory(context)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: advisories.length,
      itemBuilder: (ctx, i) => _advisoryCard(ctx, advisories[i], showSend: showSend),
    );
  }

  Widget _advisoryCard(BuildContext context, Advisory adv, {required bool showSend}) {
    final isPublished = adv.status == AdvisoryStatus.published;
    final severityColor = _severityColor(adv.target);

    return GestureDetector(
      onTap: () => _showAdvisoryDetail(context, adv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: GovtColors.surface,
          borderRadius: GovtRadius.lgRadius,
          border: Border.all(color: GovtColors.border),
          boxShadow: const [BoxShadow(color: GovtColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: severityColor.withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign_rounded, size: 18, color: severityColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(adv.title, style: GovtTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  StatusChip(
                    label: isPublished ? 'Published' : 'Draft',
                    color: isPublished ? GovtColors.success : GovtColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusChip(label: adv.target.displayName, color: severityColor),
                      if (adv.targetLocation != null) ...[
                        const SizedBox(width: 8),
                        StatusChip(label: adv.targetLocation!, color: GovtColors.textSecondary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(adv.message, style: GovtTypography.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: GovtColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(adv.createdBy, style: GovtTypography.caption),
                      const Spacer(),
                      if (showSend) ...[
                        GovtButton(
                          label: 'Publish',
                          icon: Icons.send_rounded,
                          compact: true,
                          onPressed: () => _confirmPublish(context, adv),
                        ),
                      ] else
                        Text(
                          adv.publishedAt != null ? 'Published ${_timeAgo(adv.publishedAt!)}' : '',
                          style: GovtTypography.caption,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduledList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule_rounded, size: 52, color: GovtColors.textDisabled),
          const SizedBox(height: 12),
          const Text('No scheduled advisories', style: TextStyle(color: GovtColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _sentList(List<Advisory> published) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: published.length,
      itemBuilder: (ctx, i) {
        final adv = published[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GovtColors.surface,
            borderRadius: GovtRadius.lgRadius,
            border: Border.all(color: GovtColors.border),
          ),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: GovtColors.successLight, borderRadius: GovtRadius.smRadius), child: const Icon(Icons.done_all_rounded, color: GovtColors.success, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(adv.title, style: GovtTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Sent to ${adv.target.displayName}', style: GovtTypography.caption),
                  ],
                ),
              ),
              Text(adv.publishedAt != null ? _timeAgo(adv.publishedAt!) : '', style: GovtTypography.caption),
            ],
          ),
        );
      },
    );
  }

  void _showAdvisoryDetail(BuildContext context, Advisory adv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: Text(adv.title, style: GovtTypography.sectionTitle)),
                StatusChip(label: adv.status == AdvisoryStatus.published ? 'Published' : 'Draft', color: adv.status == AdvisoryStatus.published ? GovtColors.success : GovtColors.textSecondary),
              ],
            ),
            const SizedBox(height: 8),
            Text('Target: ${adv.target.displayName}${adv.targetLocation != null ? ' · ${adv.targetLocation}' : ''}', style: GovtTypography.caption),
            const SizedBox(height: 12),
            const Divider(color: GovtColors.border),
            const SizedBox(height: 12),
            const Text('Message', style: GovtTypography.sectionTitle),
            const SizedBox(height: 8),
            Text(adv.message, style: GovtTypography.body),
            const SizedBox(height: 16),
            // Advisory preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GovtColors.surfaceSubtle,
                borderRadius: GovtRadius.mdRadius,
                border: Border.all(color: GovtColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.preview_rounded, size: 14, color: GovtColors.textSecondary),
                      SizedBox(width: 6),
                      Text('FARMER / VET PREVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GovtColors.textSecondary, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('📢 ${adv.title}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(adv.message, style: GovtTypography.body),
                  const SizedBox(height: 4),
                  Text('— ${adv.createdBy}', style: GovtTypography.caption),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (adv.status != AdvisoryStatus.published)
              GovtButton(
                label: 'PUBLISH ADVISORY',
                icon: Icons.send_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmPublish(context, adv);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmPublish(BuildContext context, Advisory adv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovtColors.surface,
        shape: RoundedRectangleBorder(borderRadius: GovtRadius.lgRadius),
        title: const Text('Publish Advisory', style: GovtTypography.sectionTitle),
        content: Text(
          'This will publish the advisory to all ${adv.target.displayName.toLowerCase()}s in ${adv.targetLocation ?? 'the selected area'}.\n\nThey will receive an in-app notification. Proceed?',
          style: GovtTypography.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: GovtColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.brand, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              widget.dataService.publishAdvisory(adv.advisoryId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Advisory published — all recipients notified'), backgroundColor: GovtColors.success),
              );
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _showCreateAdvisory(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Urgent: FMD Quarantine Advisory');
    final messageCtrl = TextEditingController(
      text: 'Foot-and-Mouth disease detected in sector. Restrict livestock transit within 5km radius. Report high fever and oral vesicles immediately.',
    );
    final locationCtrl = TextEditingController(text: 'Perundurai Block');
    AdvisoryTarget target = AdvisoryTarget.block;
    String language = 'English';
    String alertType = 'Outbreak Alert';
    String animalCategory = 'Cattle & Buffalo';
    String priority = 'High';
    String validity = '48 Hours';
    int previewTab = 0; // 0: SMS, 1: Mobile App, 2: Field Worker

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: GovtColors.brandLight, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.campaign_rounded, color: GovtColors.brand, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Government Advisory Creator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GovtColors.textPrimary)),
                            Text('Multi-channel emergency broadcast docket', style: TextStyle(fontSize: 11, color: GovtColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded, color: GovtColors.textSecondary), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(height: 20),

                  // Alert Type & Priority
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alert Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: alertType,
                              decoration: _dropdownDecor(),
                              items: ['Outbreak Alert', 'Vaccination Drive', 'Weather Warning', 'Containment Order']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => setModal(() => alertType = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: priority,
                              decoration: _dropdownDecor(),
                              items: ['Normal', 'High', 'Critical']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => setModal(() => priority = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _formField(titleCtrl, 'Advisory Title *', Icons.title_rounded),
                  const SizedBox(height: 12),

                  // Animal Category & Validity
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Animal Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: animalCategory,
                              decoration: _dropdownDecor(),
                              items: ['Cattle & Buffalo', 'Sheep & Goat', 'Poultry', 'Equine', 'All Species']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => setModal(() => animalCategory = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Validity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: validity,
                              decoration: _dropdownDecor(),
                              items: ['24 Hours', '48 Hours', '7 Days', 'Until Revoked']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => setModal(() => validity = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _formField(locationCtrl, 'Target Region (Village / Block / District)', Icons.place_rounded),
                  const SizedBox(height: 12),

                  // Language Choice
                  const Text('Broadcast Language', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['English', 'Tamil (தமிழ்)', 'Hindi (हिन्दी)'].map((l) => ChoiceChip(
                      label: Text(l, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: language == l ? Colors.white : GovtColors.textPrimary)),
                      selected: language == l,
                      selectedColor: GovtColors.brand,
                      backgroundColor: GovtColors.surfaceSubtle,
                      showCheckmark: false,
                      onSelected: (_) => setModal(() => language = l),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),

                  _formFieldMulti(messageCtrl, 'Advisory Message *', 'Enter institutional instruction for farmers and veterinarians...'),
                  const SizedBox(height: 14),

                  // ── Live Multi-channel Preview Tabs ─────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: GovtColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GovtColors.border),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('LIVE MULTI-CHANNEL PREVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: GovtColors.textSecondary)),
                            const Spacer(),
                            _previewTabBtn('SMS', 0, previewTab, (i) => setModal(() => previewTab = i)),
                            const SizedBox(width: 4),
                            _previewTabBtn('Mobile App', 1, previewTab, (i) => setModal(() => previewTab = i)),
                            const SizedBox(width: 4),
                            _previewTabBtn('Field Worker', 2, previewTab, (i) => setModal(() => previewTab = i)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Preview Content
                        if (previewTab == 0) ...[
                          // SMS Preview
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCFD8DC)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.sms_rounded, size: 14, color: GovtColors.textSecondary),
                                    SizedBox(width: 6),
                                    Text('SMS to 4,820 registered farmers', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GovtColors.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '[GOVT ADVISORY] ${titleCtrl.text.trim()}\n${messageCtrl.text.trim()}\n- Animal Husbandry Dept',
                                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: GovtColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ] else if (previewTab == 1) ...[
                          // Mobile App Push Notification Preview
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GovtColors.brand.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: GovtColors.brand, borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(titleCtrl.text.trim(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text(messageCtrl.text.trim(), style: const TextStyle(fontSize: 11, color: GovtColors.textPrimary)),
                                      const SizedBox(height: 4),
                                      Text('Target: ${locationCtrl.text.trim()} • Priority: $priority', style: const TextStyle(fontSize: 9, color: GovtColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Field Worker Broadcast Docket
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GovtColors.riskHigh.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('OPERATIONAL DIRECTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GovtColors.riskHigh)),
                                    Text('VALID: $validity', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GovtColors.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('DIRECTIVE: ${titleCtrl.text.trim()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(messageCtrl.text.trim(), style: const TextStyle(fontSize: 11)),
                                const SizedBox(height: 4),
                                Text('Field Teams: Initiate door-to-door temperature check in $animalCategory herds.', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: GovtColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons: SAVE DRAFT, PUBLISH ADVISORY
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: GovtColors.brand),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.save_outlined, size: 16, color: GovtColors.brand),
                          label: const Text('SAVE DRAFT', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: GovtColors.brand)),
                          onPressed: () => _saveAdvisory(ctx, titleCtrl, messageCtrl, locationCtrl, target, publishNow: false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GovtColors.brand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('PUBLISH ADVISORY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          onPressed: () => _saveAdvisory(ctx, titleCtrl, messageCtrl, locationCtrl, target, publishNow: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewTabBtn(String label, int index, int current, ValueChanged<int> onSelect) {
    final isSelected = index == current;
    return InkWell(
      onTap: () => onSelect(index),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? GovtColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? GovtColors.brandDark : GovtColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : GovtColors.textSecondary),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecor() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: GovtColors.surfaceSubtle,
      border: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.brand, width: 1.5)),
    );
  }

  void _saveAdvisory(BuildContext ctx, TextEditingController titleCtrl, TextEditingController messageCtrl, TextEditingController locationCtrl, AdvisoryTarget target, {required bool publishNow}) {
    if (titleCtrl.text.trim().isEmpty || messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Title and message are required'), backgroundColor: GovtColors.critical));
      return;
    }
    final adv = Advisory(
      advisoryId: widget.dataService.generateAdvisoryId(),
      title: titleCtrl.text.trim(),
      message: messageCtrl.text.trim(),
      target: target,
      targetLocation: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
      createdBy: 'District Animal Husbandry Officer',
      status: AdvisoryStatus.draft,
    );
    widget.dataService.addAdvisory(adv);
    if (publishNow) widget.dataService.publishAdvisory(adv.advisoryId);
    Navigator.pop(ctx);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(publishNow ? '✓ Advisory published successfully' : '✓ Advisory saved as draft'), backgroundColor: GovtColors.success),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: GovtTypography.body,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: GovtColors.textSecondary),
        filled: true,
        fillColor: GovtColors.surfaceSubtle,
        border: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.brand, width: 1.5)),
      ),
    );
  }

  Widget _formFieldMulti(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      maxLines: 4,
      style: GovtTypography.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: GovtColors.textDisabled, fontSize: 12),
        filled: true,
        fillColor: GovtColors.surfaceSubtle,
        border: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: GovtRadius.smRadius, borderSide: const BorderSide(color: GovtColors.brand, width: 1.5)),
      ),
    );
  }

  Color _severityColor(AdvisoryTarget target) {
    switch (target) {
      case AdvisoryTarget.block:
        return GovtColors.warning;
      case AdvisoryTarget.district:
        return GovtColors.riskHigh;
      case AdvisoryTarget.village:
        return GovtColors.brand;
      case AdvisoryTarget.all:
        return GovtColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
