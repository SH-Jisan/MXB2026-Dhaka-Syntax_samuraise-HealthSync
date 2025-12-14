class MedicalEvent {
  final String id;
  final String title;
  final String eventType; // REPORT, PRESCRIPTION
  final DateTime eventDate;
  final String severity; // HIGH, MEDIUM, LOW
  final String? summary;
  final List<String> attachmentUrls;
  final DateTime createdAt;

  MedicalEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.severity,
    this.summary,
    required this.attachmentUrls,
    required this.createdAt,
  });

  // Supabase JSON থেকে অবজেক্ট বানানোর ফ্যাক্টরি মেথড
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
    );
  }
}