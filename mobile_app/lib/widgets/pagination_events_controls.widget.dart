import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home/app_blocs.dart';
import '../blocs/home/app_events.dart';

class PaginationEventsControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationEventsControls(
      {required this.currentPage,
      required this.totalPages,
      required this.onPageChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventBloc = context.read<EventBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed:
                currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            child: const Text("Précédent"),
          ),
          const SizedBox(width: 16),
          Text("Page ${currentPage + 1} / ${totalPages}"),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: (totalPages > 1 && currentPage < totalPages - 1)
                ? () => onPageChanged(currentPage + 1)
                : null,
            child: const Text("Suivant"),
          ),
        ],
      ),
    );
  }
}
