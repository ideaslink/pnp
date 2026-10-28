import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/database_helper.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _categoryType = '';
  List<String> _items = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _categoryType.isEmpty) {
      _categoryType = args['type'] as String? ?? '';
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    final scans = await DatabaseHelper.instance.getScans();
    final Set<String> uniqueItems = {};

    for (var scan in scans) {
      switch (_categoryType) {
        case 'phones':
          uniqueItems.addAll(scan.ocrResult.phoneNumbers);
          break;
        case 'addresses':
          uniqueItems.addAll(scan.ocrResult.addresses);
          break;
        case 'websites':
          uniqueItems.addAll(scan.ocrResult.websites);
          break;
        case 'emails':
          uniqueItems.addAll(scan.ocrResult.emails);
          break;
      }
    }

    if (mounted) {
      setState(() {
        _items = uniqueItems.toList();
        _isLoading = false;
      });
    }
  }

  String _getTitle() {
    switch (_categoryType) {
      case 'phones':
        return 'Phone Numbers';
      case 'addresses':
        return 'Addresses';
      case 'websites':
        return 'Websites';
      case 'emails':
        return 'Emails';
      default:
        return 'Items';
    }
  }

  IconData _getIcon() {
    switch (_categoryType) {
      case 'phones':
        return Icons.phone;
      case 'addresses':
        return Icons.location_on;
      case 'websites':
        return Icons.language;
      case 'emails':
        return Icons.email;
      default:
        return Icons.list;
    }
  }

  String _getActionLabel() {
    switch (_categoryType) {
      case 'phones':
        return 'Call';
      case 'addresses':
        return 'Navigate';
      case 'websites':
        return 'Open';
      case 'emails':
        return 'Email';
      default:
        return 'Action';
    }
  }

  Future<void> _performAction(String item) async {
    Uri? uri;
    switch (_categoryType) {
      case 'phones':
        uri = Uri.parse('tel:$item');
        break;
      case 'addresses':
        uri = Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(item)}');
        break;
      case 'websites':
        String url = item;
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        uri = Uri.parse(url);
        break;
      case 'emails':
        uri = Uri.parse('mailto:$item');
        break;
    }

    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: _categoryType == 'websites' || _categoryType == 'addresses'
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not perform action')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _buildTaskCard(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items found',
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

  Widget _buildTaskCard(String item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            child: Icon(_getIcon(), color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () => _performAction(item),
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
              child: Text(_getActionLabel()),
            ),
          ),
        ],
      ),
    );
  }
}
