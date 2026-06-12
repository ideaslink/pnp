import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/database_helper.dart';
import '../models/scan_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanRecord> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    final scans = await DatabaseHelper.instance.getScans();
    if (mounted) {
      setState(() {
        _scans = scans;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    String period = 'AM';
    int hour = dt.hour;
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search,
                        color: AppColors.primaryGreen, size: 22),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : _scans.isEmpty
                      ? _buildEmptyState()
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/detected-tasks'),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _scans.length,
      itemBuilder: (context, index) {
        final scan = _scans[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detected-tasks',
              arguments: {
                'ocrResult': scan.ocrResult,
                'imagePath': scan.imagePath,
              },
            );
          },
          child: _buildHistoryItem(
            scan: scan,
            title: '${scan.ocrResult.totalItems} items detected',
            date: _formatDate(scan.timestamp),
            time: _formatTime(scan.timestamp),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem({
    required ScanRecord scan,
    required String title,
    required String date,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(scan.imagePath)),
                fit: BoxFit.cover,
                // Handle missing image gracefully
                onError: (exception, stackTrace) {},
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
