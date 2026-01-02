import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/list_users/users_event.dart';
import 'package:mobile_app/blocs/list_users/users_state.dart';
import 'package:mobile_app/models/UserModel.dart';
import '../../repository/UsersRepository.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository usersRepository;
  int currentPage = 0;
  int totalPages = 1;
  List<UserModel> clients = [];
  String currentSearch = "";

  UsersBloc(this.usersRepository) : super(ClientsInitial()) {
    on<LoadClientsEvent>((event, emit) async {
      emit(ClientsLoading());
      try {
        final result = await usersRepository.getClients(
          page: event.page,
          username: currentSearch, // Utilise la valeur de recherche actuelle
        );
        clients = result["clients"];
        totalPages = result["totalPages"];
        currentPage = event.page;

        emit(ClientsLoaded(clients, currentPage, totalPages));
      } catch (e) {
        emit(ClientsError("Erreur de chargement : $e"));
      }
    });

    // ✅ Ajout du gestionnaire pour la recherche
    on<SearchClientsEvent>((event, emit) async {
      emit(ClientsLoading());
      try {
        currentSearch = event.username;
        final result =
            await usersRepository.getClients(page: 0, username: currentSearch);
        clients = result["clients"];
        totalPages = result["totalPages"];
        currentPage = 0;

        emit(ClientsLoaded(clients, currentPage, totalPages));
      } catch (e) {
        emit(ClientsError("Erreur de recherche : $e"));
      }
    });
  }
}
