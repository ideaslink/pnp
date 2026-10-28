import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  int _expandedIndex = 0;

  final List<Map<String, dynamic>> _sections = [
    {
      'icon': Icons.info_outline,
      'title': 'Information We Collect',
      'content':
          'We do not collect any personal data. All of your scanned data and images are kept exclusively within the app on your local device.',
    },
    {
      'icon': Icons.visibility_outlined,
      'title': 'How We Use Your Information',
      'content':
          'Since no personal data is collected, we do not use your information. Your data remains strictly on your device for your own use.',
    },
    {
      'icon': Icons.share_outlined,
      'title': 'Data Sharing and Disclosure',
      'content':
          'We do not collect or share any of your personal information with third parties. Everything stays securely on your device.',
    },
    {
      'icon': Icons.security_outlined,
      'title': 'Data Security',
      'content':
          'Your data is secured locally by your device\'s operating system. We do not transmit it to any external servers.',
    },
    {
      'icon': Icons.gavel_outlined,
      'title': 'Your Rights and Choices',
      'content':
          'You have full control over your data. You can delete all your scans and information at any time directly from the application.',
    },
    {
      'icon': Icons.mail_outline,
      'title': 'Contact Us',
      'content':
          'If you have questions about this privacy policy, please contact us at pnpclould@gmail.com.',
    },
  ];

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
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Privacy Statement',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Shield Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: AppColors.primaryGreen,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Your Privacy, Our Priority',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We're committed to protecting your data.\nHere's a clear, simple breakdown of our\nprivacy practices.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: September 22, 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Expandable Sections
                    ..._sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      final isExpanded = _expandedIndex == index;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedIndex = isExpanded ? -1 : index;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      section['icon'] as IconData,
                                      color: AppColors.primaryGreen,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        section['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 16),
                                child: Text(
                                  section['content'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

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
}
