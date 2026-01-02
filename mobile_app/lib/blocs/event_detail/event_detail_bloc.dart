import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/event_detail/event_detail_state.dart';
import 'package:mobile_app/repository/EventsRepository.dart';

import 'event_detail_event.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  final EventsRepository eventsRepository;

  EventDetailBloc({required this.eventsRepository})
      : super(EventDetailInitial()) {
    on<LoadEventDetail>((event, emit) async {
      emit(EventDetailLoading());
      try {
        final eventDetail =
            await eventsRepository.getEventDetails(event.eventId);
        emit(EventDetailLoaded(eventDetail));
      } catch (e) {
        emit(EventDetailError(e.toString()));
      }
    });
  }
}
