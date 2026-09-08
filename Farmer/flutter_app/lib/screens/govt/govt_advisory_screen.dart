// Government Advisory Screen — create and publish livestock health advisories

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import '../../models/advisory.dart';

class GovtAdvisoryScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtAdvisoryScreen({super.key, required this.dataService});

  @override
  State<GovtAdvisoryScreen> createState() => _GovtAdvisoryScreenState();
}

class _GovtAdvisoryScreenState extends State<GovtAdvisoryScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataService,
      builder: (context, _) {
        final advisories = widget.dataService.getAllAdvisories();

        return Scaffold(
          backgroundColor: const Color(0xFFECF0F8),
          appBar: AppBar(
            title: const Text('Advisories', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF4A148C),
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF4A148C),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Advisory'),
            onPressed: () => _createAdvisory(context),
          ),
          body: advisories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, color: Colors.grey, size: 64),
                      SizedBox(height: 16),
                      Text('No advisories yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Tap + to create a health advisory',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: advisories.length,
                  itemBuilder: (ctx, i) => _advisoryCard(ctx, advisories[i]),
                ),
        );
      },
    );
  }

  Widget _advisoryCard(BuildContext context, Advisory adv) {
    final isPublished = adv.status == AdvisoryStatus.published;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign, color: Color(0xFF4A148C), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(adv.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPublished ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    adv.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPublished ? Colors.green.shade800 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${adv.target.displayName}${adv.targetLocation != null ? ': ${adv.targetLocation}' : ''}',
                style: TextStyle(fontSize: 11, color: Colors.purple.shade700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              adv.message,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (adv.publishedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Published: ${adv.publishedAt!.day}/${adv.publishedAt!.month}/${adv.publishedAt!.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            if (!isPublished) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A148C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Publish Now'),
                      onPressed: () => _publish(context, adv),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _publish(BuildContext context, Advisory adv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Advisory'),
        content: const Text(
            'This will publish the advisory to all affected farmers and veterinarians. '
            'They will receive an in-app alert.\n\nProceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A148C), foregroundColor: Colors.white),
            onPressed: () {
              widget.dataService.publishAdvisory(adv.advisoryId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Advisory published — Farmers & Vets notified'),
                  backgroundColor: Color(0xFF4A148C),
                ),
              );
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _createAdvisory(BuildContext context) {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    AdvisoryTarget target = AdvisoryTarget.block;
    bool publishNow = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Advisory',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 16),

                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Advisory Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: messageCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message *',
                    hintText: 'Write advisory message in simple language...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Target:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: AdvisoryTarget.values.map((t) => ChoiceChip(
                    label: Text(t.displayName),
                    selected: target == t,
                    onSelected: (_) => setModalState(() => target = t),
                    selectedColor: Colors.purple.shade100,
                  )).toList(),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location (village/block/district name)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publish immediately'),
                  value: publishNow,
                  onChanged: (v) => setModalState(() => publishNow = v),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A148C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty || messageCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Please fill in title and message'), backgroundColor: Colors.red),
                        );
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
                      if (publishNow) {
                        widget.dataService.publishAdvisory(adv.advisoryId);
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(publishNow
                              ? '✅ Advisory published successfully'
                              : '✅ Advisory saved as draft'),
                          backgroundColor: const Color(0xFF4A148C),
                        ),
                      );
                    },
                    child: Text(
                      publishNow ? 'CREATE & PUBLISH' : 'SAVE AS DRAFT',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
