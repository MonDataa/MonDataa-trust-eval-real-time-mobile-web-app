import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
}

class LoadEventEvent extends EventEvent {
  final int page;
  final int size;
  final bool
      usePagination; // ✅ Ajout d'un paramètre pour différencier les deux méthodes

  const LoadEventEvent(
      {this.page = 0, this.size = 8, this.usePagination = true});

  @override
  List<Object?> get props =>
      [page, size, usePagination]; // ✅ Ajout dans les props
}
