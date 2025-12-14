class MedicalEvent {
  final String id;
  final String title;
  final String eventType; // SURGERY, REPORT, VACCINE
  final DateTime eventDate;
  final String severity; // HIGH, MEDIUM, LOW
  final String? summary;

  MedicalEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.severity,
    this.summary,
  });

  // Supabase JSON থেকে Dart Object বানানোর ফ্যাক্টরি মেথড
  factory MedicalEvent.fromJson(Map<String, dynamic> json) {
    return MedicalEvent(
      id: json['id'],
      title: json['title'],
      eventType: json['event_type'],
      eventDate: DateTime.parse(json['event_date']),
      severity: json['severity'] ?? 'LOW',
      summary: json['summary'],
    );
  }
}