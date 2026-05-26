import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/ocr_result.dart';
import '../services/ocr_service.dart';

class DetectedTasksScreen extends StatefulWidget {
  const DetectedTasksScreen({super.key});

  @override
  State<DetectedTasksScreen> createState() => _DetectedTasksScreenState();
}

class _DetectedTasksScreenState extends State<DetectedTasksScreen> {
  OcrResult? _ocrResult;
  String? _imagePath;
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments passed from dashboard
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _ocrResult == null) {
      _ocrResult = args['ocrResult'] as OcrResult?;
      _imagePath = args['imagePath'] as String?;
    }
  }

  Future<void> _retakePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await OcrService().processImage(File(photo.path));
      if (mounted) {
        setState(() {
          _ocrResult = result;
          _imagePath = photo.path;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Detected Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_ocrResult != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_ocrResult!.totalItems} found',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Captured image
                        _buildImagePreview(),
                        const SizedBox(height: 16),

                        // Task List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ocrResult == null || _ocrResult!.isEmpty
                              ? _buildEmptyState()
                              : _buildDetectedItems(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Retake Photo Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text(
                        'Retake Photo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing image...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Detecting text content',
                        style: TextStyle(
                          fontSize: 13,
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

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _imagePath != null
          ? Image.file(
              File(_imagePath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items detected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try taking a clearer photo of text\ncontaining phone numbers, emails,\nwebsites, or addresses.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedItems() {
    final result = _ocrResult!;
    final List<Widget> cards = [];

    // Phone numbers
    for (final phone in result.phoneNumbers) {
      cards.add(_buildTaskCard(
        icon: Icons.phone,
        title: 'Call $phone',
        subtitle: 'Phone number detected',
        actionLabel: 'Call',
        onTap: () => Navigator.pushNamed(
          context,
          '/task-detail-call',
          arguments: {'phoneNumber': phone},
        ),
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Addresses
    for (final address in result.addresses) {
      cards.add(_buildTaskCard(
        icon: Icons.location_on,
        title: 'Navigate to $address',
        subtitle: 'Address detected',
        actionLabel: 'Navigate',
        onTap: () => Navigator.pushNamed(
          context,
          '/task-detail-navigate',
          arguments: {'address': address},
        ),
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Websites
    for (final website in result.websites) {
      cards.add(_buildTaskCard(
        icon: Icons.language,
        title: 'Visit $website',
        subtitle: 'Website detected',
        actionLabel: 'Open',
        onTap: () {} // Logic will be handle inside a detail screen if created, or directly here
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Emails
    for (final email in result.emails) {
      cards.add(_buildTaskCard(
        icon: Icons.email,
        title: 'Email $email',
        subtitle: 'Email address detected',
        actionLabel: 'Email',
        onTap: () {},
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Raw text section
    if (result.rawText.isNotEmpty) {
      cards.add(const SizedBox(height: 8));
      cards.add(_buildRawTextCard(result.rawText));
      cards.add(const SizedBox(height: 24));
    }

    return Column(children: cards);
  }

  Widget _buildRawTextCard(String rawText) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.text_snippet_outlined,
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ),
      title: const Text(
        'Raw Detected Text',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            rawText,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
