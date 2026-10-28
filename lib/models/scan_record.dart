import 'dart:convert';
import 'ocr_result.dart';

class ScanRecord {
  final int? id;
  final String imagePath;
  final DateTime timestamp;
  final OcrResult ocrResult;

  ScanRecord({
    this.id,
    required this.imagePath,
    required this.timestamp,
    required this.ocrResult,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'phone_numbers': jsonEncode(ocrResult.phoneNumbers),
      'emails': jsonEncode(ocrResult.emails),
      'websites': jsonEncode(ocrResult.websites),
      'addresses': jsonEncode(ocrResult.addresses),
      'raw_text': ocrResult.rawText,
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      ocrResult: OcrResult(
        phoneNumbers: List<String>.from(jsonDecode(map['phone_numbers'] as String)),
        emails: List<String>.from(jsonDecode(map['emails'] as String)),
        websites: List<String>.from(jsonDecode(map['websites'] as String)),
        addresses: List<String>.from(jsonDecode(map['addresses'] as String)),
        rawText: map['raw_text'] as String,
      ),
    );
  }
}
