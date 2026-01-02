class ParticipationEvent {
  final int eventId;
  final String title;
  final DateTime participationDate;
  final bool confirmed;

  ParticipationEvent({
    required this.eventId,
    required this.title,
    required this.participationDate,
    required this.confirmed,
  });

  factory ParticipationEvent.fromJson(Map<String, dynamic> json) {
    return ParticipationEvent(
      eventId: json['eventId'],
      title: json['title'],
      participationDate: DateTime.parse(json['participationDate']),
      confirmed: json['confirmed'],
    );
  }
}
