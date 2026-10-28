import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/ocr_result.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Service that processes images using Google ML Kit text recognition
/// and extracts structured data (phones, emails, websites, addresses).
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  /// Process an image file and return structured OCR results.
  Future<OcrResult> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      final String rawText = recognizedText.text;

      // Extract structured data from the recognized text
      final phones = _extractPhoneNumbers(rawText);
      final emails = _extractEmails(rawText);
      final websites = _extractWebsites(rawText);
      final addresses = _extractAddresses(rawText);

      return OcrResult(
        phoneNumbers: phones,
        emails: emails,
        websites: websites,
        addresses: addresses,
        rawText: rawText,
      );
    } finally {
      textRecognizer.close();
    }
  }

  /// Extract phone numbers from text using phone_numbers_parser for global detection.
  List<String> _extractPhoneNumbers(String text) {
    final potentialRegex = RegExp(r'\+?[\d\(\)\-\s]{7,30}');
    final matches = potentialRegex.allMatches(text);
    final phones = <String>{};
    for (final match in matches) {
      final str = match.group(0)!.trim();
      if (str.replaceAll(RegExp(r'\D'), '').length < 7) continue;
      try {
        var pn = PhoneNumber.parse(str);
        if (!pn.isValid()) {
          pn = PhoneNumber.parse(str, callerCountry: IsoCode.US);
        }
        if (pn.isValid()) {
          phones.add(pn.international);
        }
      } catch (e) {
        // Ignore invalid parses
      }
    }
    return phones.toList();
  }

  /// Extract email addresses from text.
  List<String> _extractEmails(String text) {
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
    );
    final matches = emailRegex.allMatches(text);
    return matches.map((m) => m.group(0)!.trim()).toSet().toList();
  }

  /// Extract websites/URLs from text.
  List<String> _extractWebsites(String text) {
    final urlRegex = RegExp(
      r"(?:https?://|www\.)[a-zA-Z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+",
      caseSensitive: false,
    );

    // Also match bare domains like "example.com"
    final domainRegex = RegExp(
      r'\b[a-zA-Z0-9\-]+\.(?:com|org|net|edu|gov|io|co|us|info|biz|me)\b',
      caseSensitive: false,
    );

    final urls = <String>{};

    for (final match in urlRegex.allMatches(text)) {
      var url = match.group(0)!.trim();
      while (url.isNotEmpty && (url.endsWith('.') || url.endsWith(','))) {
        url = url.substring(0, url.length - 1);
      }
      if (url.toLowerCase().startsWith('www.')) {
        if (!url.substring(4).contains('.')) continue;
      }
      urls.add(url);
    }
    for (final match in domainRegex.allMatches(text)) {
      final domain = match.group(0)!.trim();
      // Avoid matching email domains
      final startIndex = match.start;
      if (startIndex > 0 && text[startIndex - 1] == '@') continue;
      
      // Do not add if it's a substring of an already detected URL
      bool isSub = false;
      for (final existing in urls) {
        if (existing.toLowerCase().contains(domain.toLowerCase())) {
          isSub = true;
          break;
        }
      }
      if (!isSub) {
        urls.add(domain);
      }
    }

    return urls.toList();
  }

  /// Extract addresses from text.
  /// Looks for common address patterns like "123 Main Street" or "456 Oak Ave".
  List<String> _extractAddresses(String text) {
    final addressRegex = RegExp(
      r'\b\d{1,5}\s+[A-Za-z0-9][A-Za-z0-9\s.-]{0,30}\b(?:Street|St|Avenue|Ave|Boulevard|Blvd|Drive|Dr|Road|Rd|Lane|Ln|Way|Court|Ct|Place|Pl|Circle|Cir|Trail|Trl|Parkway|Pkwy|Highway|Hwy)\b\.?'
      r'(?:[\s,]+(?:Suite|Ste|Apt|Unit|Room|Rm|#)\s*[A-Za-z0-9\-]+)?'
      r'(?:,\s*[A-Za-z.\-\s]{2,20}\b)?'
      r'(?:,\s*[A-Z]{2}\b|\s+[A-Z]{2}\b)?'
      r'(?:[\s,]+(?:\d{5}(?:-\d{4})?|[A-Z]\d[A-Z]\s?\d[A-Z]\d))?',
      caseSensitive: false,
    );

    final matches = addressRegex.allMatches(text);
    return matches.map((m) => m.group(0)!.trim()).toSet().toList();
  }
}
