import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/list_users/users_bloc.dart';
import '../blocs/list_users/users_event.dart';
import '../blocs/list_users/users_state.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/gradient_background.widget.dart';
import '../widgets/search_bar.widget.dart';
import '../widgets/pagination_controls.widget.dart';
import '../widgets/user_card.widget.dart';

class ListUsersPage extends StatefulWidget {
  const ListUsersPage({Key? key}) : super(key: key);

  @override
  _ListUsersPageState createState() => _ListUsersPageState();
}

class _ListUsersPageState extends State<ListUsersPage> {
  late UsersBloc usersBloc;

  @override
  void initState() {
    super.initState();
    usersBloc = context.read<UsersBloc>();
    usersBloc.add(LoadClientsEvent(0)); // Charger la première page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Fond dégradé sous l'AppBar
      appBar: const CustomAppBar(title: "Liste des clients"),
      body: Stack(
        children: [
          const GradientBackgroundWidget(), // ✅ Ajout du fond dégradé
          Column(
            children: [
              const SearchBarWidget(), // ✅ Barre de recherche stylisée
              Expanded(
                child: BlocBuilder<UsersBloc, UsersState>(
                  builder: (context, state) {
                    if (state is ClientsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientsLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: state.clients.length,
                              itemBuilder: (context, index) {
                                return UserCard(
                                    client: state.clients[
                                        index]); // ✅ Utilisation du widget `UserCard`
                              },
                            ),
                          ),
                          PaginationControls(state), // ✅ Pagination en bas
                        ],
                      );
                    } else if (state is ClientsError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
