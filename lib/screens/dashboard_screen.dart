import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/ocr_service.dart';
import '../models/ocr_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/database_helper.dart';
import '../models/scan_record.dart';
import '../services/settings_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;

  List<ScanRecord> _recentScans = [];
  int _totalScans = 0;
  int _todayScans = 0;
  int _totalPhones = 0;
  int _totalAddresses = 0;
  int _totalWebsites = 0;
  int _totalEmails = 0;
  int _successScans = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final scans = await DatabaseHelper.instance.getScans();
    final now = DateTime.now();
    
    int today = 0;
    int phones = 0;
    int addresses = 0;
    int websites = 0;
    int emails = 0;
    int success = 0;

    for (var scan in scans) {
      if (scan.timestamp.year == now.year && 
          scan.timestamp.month == now.month && 
          scan.timestamp.day == now.day) {
        today++;
      }
      
      bool hasData = false;
      if (scan.ocrResult.phoneNumbers.isNotEmpty) {
        phones += scan.ocrResult.phoneNumbers.length;
        hasData = true;
      }
      if (scan.ocrResult.addresses.isNotEmpty) {
        addresses += scan.ocrResult.addresses.length;
        hasData = true;
      }
      if (scan.ocrResult.websites.isNotEmpty) {
        websites += scan.ocrResult.websites.length;
        hasData = true;
      }
      if (scan.ocrResult.emails.isNotEmpty) {
        emails += scan.ocrResult.emails.length;
        hasData = true;
      }
      
      if (hasData) {
        success++;
      }
    }

    if (mounted) {
      setState(() {
        _totalScans = scans.length;
        _todayScans = today;
        _totalPhones = phones;
        _totalAddresses = addresses;
        _totalWebsites = websites;
        _totalEmails = emails;
        _successScans = success;
        
        // Sort newest first
        scans.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _recentScans = scans.take(5).toList();
      });
    }
  }

  Future<void> _captureAndProcess() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan content'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo == null) return;

    setState(() => _isProcessing = true);

    try {
      final OcrResult result = await _ocrService.processImage(File(photo.path));
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(photo.path).copy(p.join(appDir.path, fileName));

      final scanRecord = ScanRecord(
        imagePath: savedImage.path,
        timestamp: DateTime.now(),
        ocrResult: result,
      );
      if (SettingsService.instance.autoSaveScans) {
        await DatabaseHelper.instance.insertScan(scanRecord);
      }

      if (mounted) {
        await Navigator.pushNamed(
          context,
          '/detected-tasks',
          arguments: {
            'ocrResult': result,
            'imagePath': savedImage.path,
          },
        );
        _loadData(); // Reload data when coming back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header (Redesigned)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, '/menu');
                          _loadData();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Redesigned Stats Row
                        _buildStatsRow(),
                        const SizedBox(height: 32),

                        // Redesigned Categories Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Data Extracted',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Redesigned Categories Grid
                        _buildCategoriesGrid(),
                        const SizedBox(height: 32),

                        // Redesigned Recent Activity Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Scans',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (_recentScans.isNotEmpty)
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.pushNamed(context, '/history');
                                  _loadData();
                                },
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Redesigned Recent Activity List
                        _buildRecentActivity(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom Nav
                BottomNavBar(
                  currentIndex: 1,
                  onTap: (index) async {
                    if (index == 0) {
                      await Navigator.pushNamed(context, '/history');
                      _loadData();
                    } else if (index == 1) {
                      _captureAndProcess();
                    } else if (index == 2) {
                      await Navigator.pushNamed(context, '/settings');
                      _loadData();
                    }
                  },
                ),
              ],
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Scanning...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Extracting magic from image',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    double successRate = _totalScans > 0 ? (_successScans / _totalScans) * 100 : 0.0;
    
    return Row(
      children: [
        Expanded(child: _buildStatCard('Today', '$_todayScans', true)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Total Scans', '$_totalScans', false)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Success', '${successRate.toStringAsFixed(1)}%', false)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isHighlighted 
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isHighlighted ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? Colors.white.withValues(alpha: 0.9) : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: [
        _buildCategoryCard(Icons.phone_rounded, 'Phones', '$_totalPhones found', Colors.blue, 'phones'),
        _buildCategoryCard(Icons.location_on_rounded, 'Places', '$_totalAddresses found', Colors.orange, 'addresses'),
        _buildCategoryCard(Icons.language_rounded, 'Websites', '$_totalWebsites found', Colors.purple, 'websites'),
        _buildCategoryCard(Icons.email_rounded, 'Emails', '$_totalEmails found', Colors.red, 'emails'),
      ],
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String count, MaterialColor accentColor, String categoryType) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/category-list',
          arguments: {'type': categoryType},
        );
      },
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor.shade400, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildRecentActivity() {
    if (_recentScans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No recent scans yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the scan button to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentScans.map((scan) {
        int itemsFound = scan.ocrResult.phoneNumbers.length + 
            scan.ocrResult.emails.length + 
            scan.ocrResult.websites.length + 
            scan.ocrResult.addresses.length;
            
        String subtitle = itemsFound > 0 ? '$itemsFound items detected' : 'No items detected';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  '/detected-tasks',
                  arguments: {
                    'ocrResult': scan.ocrResult,
                    'imagePath': scan.imagePath,
                  },
                );
                _loadData();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(scan.imagePath),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Result',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: itemsFound > 0 ? AppColors.primaryGreen : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatTimeAgo(scan.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
