// Government Profile & Settings Screen

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'widgets/govt_widgets.dart';

class GovtSettingsScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtSettingsScreen({super.key, required this.dataService});

  @override
  State<GovtSettingsScreen> createState() => _GovtSettingsScreenState();
}

class _GovtSettingsScreenState extends State<GovtSettingsScreen> {
  bool _notifOutbreaks = true;
  bool _notifLab = true;
  bool _notifAdvisories = false;
  bool _notifFieldTeams = false;
  bool _twoFactor = false;
  String _language = 'English';
  String _dashboardLayout = 'Default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: GovtColors.brand,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: GovtColors.brand,
                padding: const EdgeInsets.fromLTRB(16, 36, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: GovtRadius.lgRadius,
                      ),
                      child: const Center(
                        child: Text('KM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Dr. K. Murugan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2),
                          Text('District Animal Husbandry Officer', style: TextStyle(fontSize: 12, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2),
                          Text('Dept. of Animal Husbandry · Erode', style: TextStyle(fontSize: 11, color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                      onPressed: () => _editProfile(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Official Profile ──────────────────────────────────────
                _sectionPad(
                  GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Official Profile'),
                        _profileRow(Icons.badge_rounded, 'Employee ID', 'DAHO-2018-0347'),
                        _profileRow(Icons.account_balance_rounded, 'Department', 'Animal Husbandry & Veterinary Services'),
                        _profileRow(Icons.location_on_rounded, 'Jurisdiction', 'Erode District, Tamil Nadu'),
                        _profileRow(Icons.email_rounded, 'Email', 'daho.erode@tn.gov.in'),
                        _profileRow(Icons.phone_rounded, 'Contact', '+91 94XXX XXXXX'),
                      ],
                    ),
                  ),
                ),

                // ── Security ──────────────────────────────────────────────
                _sectionPad(
                  GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Security'),
                        _securityTile(
                          icon: Icons.lock_rounded,
                          title: 'Change Password',
                          subtitle: 'Last changed 45 days ago',
                          onTap: () => _showChangePassword(context),
                        ),
                        const Divider(height: 1, color: GovtColors.divider),
                        _securityTile(
                          icon: Icons.devices_rounded,
                          title: 'Active Sessions',
                          subtitle: '2 sessions active',
                          onTap: () => _showSessions(context),
                        ),
                        const Divider(height: 1, color: GovtColors.divider),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: GovtColors.brandLight, borderRadius: GovtRadius.smRadius),
                            child: const Icon(Icons.security_rounded, size: 18, color: GovtColors.brand),
                          ),
                          title: const Text('Two-Factor Authentication', style: GovtTypography.bodyMedium),
                          subtitle: const Text('Verify identity on every login', style: GovtTypography.caption),
                          value: _twoFactor,
                          activeThumbColor: GovtColors.brand,
                          onChanged: (v) => setState(() => _twoFactor = v),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Notification Preferences ──────────────────────────────
                _sectionPad(
                  GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Notification Preferences'),
                        _notifSwitch('Outbreak Alerts', 'Critical and high-risk outbreak notifications', _notifOutbreaks, (v) => setState(() => _notifOutbreaks = v)),
                        _notifSwitch('Laboratory Results', 'Sample result updates and positive findings', _notifLab, (v) => setState(() => _notifLab = v)),
                        _notifSwitch('Advisory Publications', 'When advisories are published district-wide', _notifAdvisories, (v) => setState(() => _notifAdvisories = v)),
                        _notifSwitch('Field Team Updates', 'Team status and dispatch notifications', _notifFieldTeams, (v) => setState(() => _notifFieldTeams = v)),
                      ],
                    ),
                  ),
                ),

                // ── Preferences ───────────────────────────────────────────
                _sectionPad(
                  GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'App Preferences'),
                        _prefSelector('Language', _language, ['English', 'Tamil', 'Hindi'], (v) => setState(() => _language = v)),
                        const Divider(height: 1, color: GovtColors.divider),
                        _prefSelector('Dashboard Layout', _dashboardLayout, ['Default', 'Compact', 'Extended'], (v) => setState(() => _dashboardLayout = v)),
                      ],
                    ),
                  ),
                ),

                // ── System Info ───────────────────────────────────────────
                _sectionPad(
                  GovtSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'System Information'),
                        _profileRow(Icons.info_rounded, 'App Version', 'v1.0.0 (Demo)'),
                        _profileRow(Icons.cloud_rounded, 'Data Mode', 'In-Memory Demo'),
                        _profileRow(Icons.privacy_tip_rounded, 'Data Classification', 'Government — Restricted'),
                      ],
                    ),
                  ),
                ),

                // ── Sign Out ──────────────────────────────────────────────
                Padding(
                  padding: GovtSpacing.pagePadding,
                  child: GovtButton(
                    label: 'SIGN OUT',
                    icon: Icons.logout_rounded,
                    outlined: true,
                    color: GovtColors.critical,
                    onPressed: () => _confirmSignOut(context),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionPad(Widget child) {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: child);
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: GovtColors.brandLight, borderRadius: GovtRadius.smRadius),
            child: Icon(icon, size: 14, color: GovtColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GovtTypography.caption),
                Text(value, style: GovtTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: GovtColors.brandLight, borderRadius: GovtRadius.smRadius),
        child: Icon(icon, size: 18, color: GovtColors.brand),
      ),
      title: Text(title, style: GovtTypography.bodyMedium),
      subtitle: Text(subtitle, style: GovtTypography.caption),
      trailing: const Icon(Icons.chevron_right_rounded, color: GovtColors.textDisabled),
      onTap: onTap,
    );
  }

  Widget _notifSwitch(String title, String subtitle, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GovtTypography.bodyMedium),
      subtitle: Text(subtitle, style: GovtTypography.caption),
      value: value,
      activeThumbColor: GovtColors.brand,
      onChanged: onChanged,
    );
  }

  Widget _prefSelector(String title, String value, List<String> options, void Function(String) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GovtTypography.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontSize: 13, color: GovtColors.brand, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: GovtColors.textDisabled),
        ],
      ),
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text('Select $title', style: GovtTypography.sectionTitle)),
            ...options.map((o) => ListTile(
              title: Text(o),
              trailing: o == value ? const Icon(Icons.check_rounded, color: GovtColors.brand) : null,
              onTap: () { onChanged(o); Navigator.pop(ctx); },
            )),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile — connect to backend'), backgroundColor: GovtColors.brand),
    );
  }

  void _showChangePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password — connect to auth service')),
    );
  }

  void _showSessions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Sessions', style: GovtTypography.sectionTitle),
            const SizedBox(height: 12),
            _sessionTile('Android · Current Device', 'Erode, Tamil Nadu · Active now', true),
            _sessionTile('Chrome · Web', 'Chennai, Tamil Nadu · 2h ago', false),
          ],
        ),
      ),
    );
  }

  Widget _sessionTile(String device, String info, bool isCurrent) {
    return ListTile(
      leading: Icon(isCurrent ? Icons.phone_android_rounded : Icons.computer_rounded, color: GovtColors.brand),
      title: Text(device, style: GovtTypography.bodyMedium),
      subtitle: Text(info, style: GovtTypography.caption),
      trailing: isCurrent
          ? StatusChip(label: 'Current', color: GovtColors.success)
          : TextButton(
              style: TextButton.styleFrom(foregroundColor: GovtColors.critical),
              onPressed: () => Navigator.pop(context),
              child: const Text('Revoke'),
            ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovtColors.surface,
        shape: RoundedRectangleBorder(borderRadius: GovtRadius.lgRadius),
        title: const Text('Sign Out', style: GovtTypography.sectionTitle),
        content: const Text('Are you sure you want to sign out of the Government Surveillance Platform?', style: GovtTypography.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: GovtColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovtColors.critical, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
