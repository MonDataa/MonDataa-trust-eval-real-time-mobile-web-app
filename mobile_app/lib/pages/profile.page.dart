import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_events.dart';
import '../blocs/statistics_user/statistics_user_bloc.dart';
import '../blocs/statistics_user/statistics_user_events.dart';
import '../repository/ProfileRepository.dart';
import '../repository/StatisticsRepository.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/gradient_background.widget.dart';
import '../widgets/profile_statistics.widget.dart';
import '../widgets/profile_participation.widget.dart';
import '../widgets/profile_trust_score.widget.dart';

class ProfilePage extends StatelessWidget {
  final int userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            profileRepository:
                RepositoryProvider.of<ProfileRepository>(context),
            currentUserId: userId,
          )..add(LoadUserStatistics(userId)),
        ),
        BlocProvider<StatisticsUserBloc>(
          create: (context) => StatisticsUserBloc(
            statisticsRepository:
                RepositoryProvider.of<StatisticsRepository>(context),
            currentUserId: userId,
          )..add(LoadStatistics(userId)),
        ),
      ],
      child: Scaffold(
        extendBodyBehindAppBar:
            true, // ✅ Permet de faire passer le fond sous l'AppBar
        appBar: const CustomAppBar(title: "Profil Utilisateur"),
        body: Stack(
          children: [
            // 🔹 Ajout d'un fond dégradé
            const GradientBackgroundWidget(),
            // 🔹 Contenu du profil
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(), // ✅ Défilement fluide
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileStatisticsWidget(), // ✅ Statistiques utilisateur
                    _buildDivider(),
                    const ProfileTrustScoreWidget(), // ✅ Graphique du score de confiance
                    _buildDivider(),
                    const ProfileParticipationWidget(), // ✅ Historique des participations
                    _buildDivider(),
                    const SizedBox(
                        height: 30), // ✅ Espace final pour un affichage propre
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget séparateur stylisé
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
    );
  }
}
