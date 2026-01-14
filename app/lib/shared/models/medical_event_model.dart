class MedicalEvent {
  final String id;
  final String title;
  final String eventType;
  final DateTime eventDate;
  final String severity;
  final String? summary;
  final List<String> attachmentUrls;
  final DateTime createdAt;

  final List<String> keyFindings;
  final Map<String, dynamic>? aiDetails;
  final List<dynamic>? medicines;
  final Map<String, dynamic>? vitals;

  MedicalEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.severity,
    this.summary,
    required this.attachmentUrls,
    required this.createdAt,
    required this.keyFindings,
    this.aiDetails,
    this.medicines,
    this.vitals,
  });

  factory MedicalEvent.fromJson(Map<String, dynamic> json) {
    return MedicalEvent(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      eventType: json['event_type'] ?? 'REPORT',
      eventDate: DateTime.parse(json['event_date']),
      severity: json['severity'] ?? 'LOW',
      summary: json['summary'],
      attachmentUrls: List<String>.from(json['attachment_urls'] ?? []),
      createdAt: DateTime.parse(json['created_at']),

      keyFindings: List<String>.from(json['key_findings'] ?? []),
      aiDetails: json['ai_details'],
      medicines: json['medicines'] as List<dynamic>?,
      vitals: json['vitals'] as Map<String, dynamic>?,
    );
  }
}
