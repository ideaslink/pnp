import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._internal();
  factory SettingsService() => instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auto-save scans (Default: true)
  bool get autoSaveScans => _prefs?.getBool('autoSaveScans') ?? true;
  Future<void> setAutoSaveScans(bool value) async {
    await _prefs?.setBool('autoSaveScans', value);
  }

  // Default language (English or Auto, Default: English)
  String get defaultLanguage => _prefs?.getString('defaultLanguage') ?? 'English';
  Future<void> setDefaultLanguage(String value) async {
    await _prefs?.setString('defaultLanguage', value);
  }

  // Default export format (TXT or JSON, Default: TXT)
  String get exportFormat => _prefs?.getString('exportFormat') ?? 'TXT';
  Future<void> setExportFormat(String value) async {
    await _prefs?.setString('exportFormat', value);
  }
}
