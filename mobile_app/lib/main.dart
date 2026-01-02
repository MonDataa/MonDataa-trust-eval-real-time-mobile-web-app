import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/pub_event/event_bloc.dart';
import 'package:mobile_app/blocs/statistics_user/statistics_user_bloc.dart';
import 'package:mobile_app/blocs/notification/notification_bloc.dart';

import 'package:mobile_app/pages/create_category_page.dart';
import 'package:mobile_app/repository/AuthRepository.dart';
import 'package:mobile_app/repository/CategoryRepository.dart';
import 'package:mobile_app/repository/EventsRepository.dart';
import 'package:mobile_app/repository/ProfileRepository.dart';
import 'package:mobile_app/repository/StatisticsRepository.dart';
import 'package:mobile_app/repository/UsersRepository.dart';
import 'package:mobile_app/repository/confirmation_repository.dart';
import 'package:mobile_app/repository/event_positions_repository.dart';
import 'package:mobile_app/repository/location_repository.dart';

import 'package:mobile_app/pages/home.page.dart';
import 'package:mobile_app/pages/login.page.dart';
import 'package:mobile_app/pages/register.page.dart';
import 'package:mobile_app/pages/profile.page.dart';
import 'package:mobile_app/pages/pub_event.page.dart';
import 'package:mobile_app/pages/ListUsers.page.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_events.dart';
import 'blocs/category/CategoryBloc.dart';
import 'blocs/home/app_blocs.dart';
import 'blocs/list_users/users_bloc.dart';
import 'blocs/notification/notification_events.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        // Repositories
        RepositoryProvider(create: (context) => EventsRepository()),
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => LocationRepository()),
        RepositoryProvider(create: (context) => EventPositionsRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
        RepositoryProvider(create: (context) => StatisticsRepository()),
        RepositoryProvider(create: (context) => UsersRepository()),
        RepositoryProvider(create: (context) => CategoryRepository()),
        RepositoryProvider(create: (context) => ConfirmationRepository()),

        // Blocs
        BlocProvider(
          create: (context) =>
              AuthBloc(RepositoryProvider.of<AuthRepository>(context))
                ..add(AppStarted()),
        ),
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(context.read<EventsRepository>()),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(
            authBloc: context.read<AuthBloc>(), // ✅ Correction ici
            confirmationRepository: context.read<ConfirmationRepository>(),
          )..add(LoadNotificationsEvent()),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(
              RepositoryProvider.of<UsersRepository>(context, listen: false)),
        ),
        RepositoryProvider<EventPositionsRepository>(
          create: (context) => EventPositionsRepository(),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(context.read<CategoryRepository>()),
        ),
        BlocProvider(
          create: (context) => PubEventBloc(context.read<EventsRepository>()),
        ),
        // Notez : Nous ne fournissons pas globalement ProfileBloc, car il dépend de l'ID de l'utilisateur.
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      onGenerateRoute: (settings) {
        if (settings.name == "/profile" && settings.arguments is int) {
          return MaterialPageRoute(
            builder: (context) =>
                ProfilePage(userId: settings.arguments as int),
          );
        }
        return null;
      },
      routes: {
        "/login": (context) => LoginPage(),
        "/register": (context) => RegisterPage(),
        "/home": (context) => HomePage(),
        "/ListUsers": (context) => ListUsersPage(),
        "/pubevent": (context) => PubEventPage(),
        "/add_type": (context) => CreateCategoryPage(),
      },
    );
  }
}
