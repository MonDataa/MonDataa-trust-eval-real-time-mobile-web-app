import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/list_users/users_bloc.dart';
import '../blocs/list_users/users_event.dart';
import '../blocs/list_users/users_state.dart';

class PaginationControls extends StatelessWidget {
  final ClientsLoaded state;
  const PaginationControls(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usersBloc = context.read<UsersBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: state.currentPage > 0
                ? () => usersBloc.add(LoadClientsEvent(state.currentPage - 1))
                : null,
            child: const Text("Précédent"),
          ),
          const SizedBox(width: 16),
          Text("Page ${state.currentPage + 1} / ${state.totalPages}"),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: state.currentPage < state.totalPages - 1
                ? () => usersBloc.add(LoadClientsEvent(state.currentPage + 1))
                : null,
            child: const Text("Suivant"),
          ),
        ],
      ),
    );
  }
}
