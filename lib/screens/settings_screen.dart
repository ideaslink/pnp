import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoSaveScans = true;
  bool ocrModeAccurate = true;
  bool autoCopyClipboard = false;
  bool defaultFlash = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // STORAGE & EXPORT
                    _buildSectionHeader('STORAGE & EXPORT'),
                    _buildSettingsTile(
                      icon: Icons.folder_outlined,
                      title: 'Default save location',
                      trailing: _buildValueChevron('App-only'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.save_outlined,
                      title: 'Auto-save scans',
                      trailing: _buildSwitch(autoSaveScans, (val) {
                        setState(() => autoSaveScans = val);
                      }),
                    ),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Default export format',
                      trailing: _buildValueChevron('TXT'),
                    ),

                    // OCR PREFERENCES
                    _buildSectionHeader('OCR PREFERENCES'),
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Default language',
                      trailing: _buildValueChevron('English'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.text_fields,
                      title: 'OCR Mode',
                      trailing: _buildToggleButtons(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.copy,
                      title: 'Auto-copy to clipboard',
                      trailing: _buildSwitch(autoCopyClipboard, (val) {
                        setState(() => autoCopyClipboard = val);
                      }),
                    ),

                    // CAMERA & SCANNING
                    _buildSectionHeader('CAMERA & SCANNING'),
                    _buildSettingsTile(
                      icon: Icons.high_quality_outlined,
                      title: 'Scan quality',
                      trailing: _buildValueChevron('High'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.flash_on_outlined,
                      title: 'Default flash',
                      trailing: _buildSwitch(defaultFlash, (val) {
                        setState(() => defaultFlash = val);
                      }),
                    ),

                    // GENERAL
                    _buildSectionHeader('GENERAL'),
                    _buildSettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.primaryGreen),
                    ),
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.primaryGreen),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildValueChevron(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right,
            color: AppColors.primaryGreen, size: 20),
      ],
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryGreen,
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => ocrModeAccurate = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !ocrModeAccurate
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Fast',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      !ocrModeAccurate ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => ocrModeAccurate = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ocrModeAccurate
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Accurate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      ocrModeAccurate ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
