import 'package:equatable/equatable.dart';

abstract class PubEventEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadEventsEvent extends PubEventEvent {}

class CreateEventEvent extends PubEventEvent {
  final String title;
  final String description;
  final int creatorId;
  final int locationId;
  final int categoryId;
  final double latitude;
  final double longitude;
  final DateTime expirationTime; // ✅ Ajout du champ expirationTime
  final String imageName;

  CreateEventEvent(
    this.title,
    this.description,
    this.creatorId,
    this.locationId,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.expirationTime,
    this.imageName,
  );

  @override
  List<Object> get props => [
        title,
        description,
        creatorId,
        locationId,
        categoryId,
        latitude,
        longitude,
        expirationTime,
        imageName, // ✅ Ajout pour comparaison d'état
      ];
}
