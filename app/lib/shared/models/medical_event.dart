class MedicalEvent {
  final String id;
  final String title;
  final String eventType;
  final DateTime eventDate;
  final String severity;
  final String? summary;
  final List<String> attachmentUrls; // <-- New Field Added

  MedicalEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.severity,
    this.summary,
    required this.attachmentUrls,
  });

  factory MedicalEvent.fromJson(Map<String, dynamic> json) {
    return MedicalEvent(
      id: json['id'],
      title: json['title'],
      eventType: json['event_type'],
      eventDate: DateTime.parse(json['event_date']),
      severity: json['severity'] ?? 'LOW',
      summary: json['summary'],
      // JSON List -> Dart List conversion
      attachmentUrls: json['attachment_urls'] != null
          ? List<String>.from(json['attachment_urls'])
          : [],
    );
  }
}