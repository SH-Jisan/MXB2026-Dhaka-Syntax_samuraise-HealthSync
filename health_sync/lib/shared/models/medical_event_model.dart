class MedicalEvent {
  final String id;
  final String title;
  final String eventType; // REPORT, PRESCRIPTION
  final DateTime eventDate;
  final String severity; // HIGH, MEDIUM, LOW
  final String? summary;
  final List<String> attachmentUrls;
  final DateTime createdAt;

  // 🔥 নতুন ফিল্ড: টেস্ট বা ফাইন্ডিংস লিস্ট
  final List<String> keyFindings;

  MedicalEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.severity,
    this.summary,
    required this.attachmentUrls,
    required this.createdAt,
    required this.keyFindings, // Constructor এ যোগ করা হলো
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

      // 🔥 ডাটাবেস থেকে key_findings লিস্ট পড়া হচ্ছে
      keyFindings: List<String>.from(json['key_findings'] ?? []),
    );
  }
}