/// Data model representing the results of OCR text recognition.
class OcrResult {
  final List<String> phoneNumbers;
  final List<String> emails;
  final List<String> websites;
  final List<String> addresses;
  final String rawText;

  const OcrResult({
    this.phoneNumbers = const [],
    this.emails = const [],
    this.websites = const [],
    this.addresses = const [],
    this.rawText = '',
  });

  /// Whether any items were detected.
  bool get isEmpty =>
      phoneNumbers.isEmpty &&
      emails.isEmpty &&
      websites.isEmpty &&
      addresses.isEmpty;

  /// Total number of detected items.
  int get totalItems =>
      phoneNumbers.length + emails.length + websites.length + addresses.length;
}
