class ConfirmationModel {
  final int id;
  final DateTime confirmationTime;
  final bool status;
  final int clientId;
  final int eventId;

  ConfirmationModel({
    required this.id,
    required this.confirmationTime,
    required this.status,
    required this.clientId,
    required this.eventId,
  });

  factory ConfirmationModel.fromJson(Map<String, dynamic> json) {
    return ConfirmationModel(
      id: json['id'],
      confirmationTime: DateTime.parse(json['confirmationTime']),
      status: json['status'],
      clientId: json['clientId'],
      eventId: json['eventId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "confirmationTime": confirmationTime.toIso8601String(),
      "status": status,
      "clientId": clientId,
      "eventId": eventId,
    };
  }
}
