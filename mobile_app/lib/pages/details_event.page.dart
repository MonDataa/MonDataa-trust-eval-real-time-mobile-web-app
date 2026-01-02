import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/event_detail/event_detail_bloc.dart';
import '../blocs/event_detail/event_detail_event.dart';
import '../blocs/event_detail/event_detail_state.dart';
import '../repository/EventsRepository.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/gradient_background.widget.dart';
import '../widgets/event_detail_card.widget.dart';
import '../widgets/event_location.widget.dart';
import '../widgets/event_stats.widget.dart';
import '../widgets/event_pie_chart.widget.dart';
import '../widgets/event_confidence_score.widget.dart';
import '../widgets/event_description.widget.dart';

class DetailEvent extends StatelessWidget {
  final int eventId;

  const DetailEvent({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventDetailBloc>(
      create: (context) => EventDetailBloc(
        eventsRepository: RepositoryProvider.of<EventsRepository>(context),
      )..add(LoadEventDetail(eventId)),
      child: Scaffold(
        extendBodyBehindAppBar: true, // ✅ Fond sous l'AppBar
        appBar: const CustomAppBar(title: "Détail de l'événement"),
        body: Stack(
          children: [
            const GradientBackgroundWidget(), // ✅ Fond dégradé
            BlocBuilder<EventDetailBloc, EventDetailState>(
              builder: (context, state) {
                if (state is EventDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventDetailLoaded) {
                  final event = state.eventDetail;
                  bool isExpired =
                      event.expirationTime.isBefore(DateTime.now());

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        EventDetailCard(event: event, isExpired: isExpired),
                        const SizedBox(height: 15),
                        EventLocationWidget(event: event),
                        const SizedBox(height: 15),
                        EventConfidenceScoreWidget(
                            event: event), // ✅ Score de confiance
                        const SizedBox(height: 15),
                        EventDescriptionWidget(event: event), // ✅ Description
                        const SizedBox(height: 15),
                        EventStatsWidget(event: event),
                        const SizedBox(height: 15),
                        EventPieChartWidget(event: event),
                      ],
                    ),
                  );
                } else if (state is EventDetailError) {
                  return Center(child: Text("Erreur : ${state.message}"));
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
