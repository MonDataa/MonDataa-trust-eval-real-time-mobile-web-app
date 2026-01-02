import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/auth_states.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_events.dart';
import 'drawer_item.widget.dart';
import 'drawer_header.widget.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeaderWidget(),
          // Afficher le nom d'utilisateur connecté uniquement si ce n'est pas un admin
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccessState && state.user.userType != "ADMIN") {
                return ListTile(
                  leading:
                      Icon(Icons.person, color: Theme.of(context).primaryColor),
                  title: Text("Bonjour, ${state.user.username}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/profile",
                        arguments: state.user.id);
                  },
                );
              }
              if (state is AuthSuccessState && state.user.userType == "ADMIN") {
                return ListTile(
                  leading:
                      Icon(Icons.person, color: Theme.of(context).primaryColor),
                  title: Text("Bonjour, ${state.user.username}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/profile");
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Divider(height: 1, color: Theme.of(context).primaryColor),
          // Item "Home"
          drawer_item(
            title: "Home",
            itemIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
            handler: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, "/home");
            },
          ),
          // Afficher "Profil" uniquement si l'utilisateur n'est pas admin
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccessState &&
                  state.user.userType.toUpperCase() != "ADMIN") {
                return drawer_item(
                  title: "Profil",
                  itemIcon: Icon(Icons.account_circle,
                      color: Theme.of(context).primaryColor),
                  handler: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/profile",
                        arguments: state.user.id);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Afficher "Publier un événement" uniquement si l'utilisateur n'est pas admin
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccessState &&
                  state.user.userType.toUpperCase() != "ADMIN") {
                return drawer_item(
                  title: "Publier un événement",
                  itemIcon: Icon(Icons.add_task,
                      color: Theme.of(context).primaryColor),
                  handler: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/pubevent");
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccessState &&
                  state.user.userType.toUpperCase() != "ADMIN") {
                return drawer_item(
                  title: "add type",
                  itemIcon: Icon(Icons.category,
                      color: Theme.of(context).primaryColor),
                  handler: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/add_type");
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Pour l'admin, on peut afficher une autre option, par exemple "List utilisateurs"
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccessState &&
                  state.user.userType.toUpperCase() == "ADMIN") {
                return drawer_item(
                  title: "List utilisateurs",
                  itemIcon: Icon(Icons.query_stats,
                      color: Theme.of(context).primaryColor),
                  handler: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/ListUsers");
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Item "Déconnexion"
          drawer_item(
            title: "Déconnexion",
            itemIcon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
            handler: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.of(context).pushNamedAndRemoveUntil(
                  "/login", (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
