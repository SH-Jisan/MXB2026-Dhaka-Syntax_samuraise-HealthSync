class MedicalEvent {
  final String id;
  final String title;
  final String eventType;
  final DateTime eventDate;
  final String severity;
  final String? summary;
  final List<String> attachmentUrls;

  // ✨ New Fields
  final String? extractedText;
  final List<String> keyFindings;

  MedicalEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.severity,
    this.summary,
    required this.attachmentUrls,
    this.extractedText,
    this.keyFindings = const [],
  });

  factory MedicalEvent.fromJson(Map<String, dynamic> json) {
    return MedicalEvent(
      id: json['id'] ?? '', // Safety check
      title: json['title'] ?? 'Unknown',
      eventType: json['event_type'] ?? 'REPORT',
      eventDate: DateTime.parse(json['event_date'] ?? DateTime.now().toIso8601String()),
      severity: json['severity'] ?? 'LOW',
      summary: json['summary'],
      attachmentUrls: json['attachment_urls'] != null
          ? List<String>.from(json['attachment_urls'])
          : [],

      // ✨ Mapping New Fields
      extractedText: json['extracted_text'], // ডাটাবেস কলামের নাম অনুযায়ী
      // details JSON বা আলাদা কলাম থেকে আসতে পারে, আমরা ধরে নিচ্ছি details JSON এ আছে
      keyFindings: json['details'] != null && json['details']['key_findings'] != null
          ? List<String>.from(json['details']['key_findings'])
          : [],
    );
  }
}