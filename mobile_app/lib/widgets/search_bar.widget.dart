import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/list_users/users_bloc.dart';
import '../blocs/list_users/users_event.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _searchUsers() {
    String query = _searchController.text.trim();
    context.read<UsersBloc>().add(SearchClientsEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: "Rechercher un client...",
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchUsers,
          ),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _searchUsers(),
      ),
    );
  }
}
