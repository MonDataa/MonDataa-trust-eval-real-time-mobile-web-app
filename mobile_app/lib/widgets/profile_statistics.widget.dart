import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/statistics_user/statistics_user_bloc.dart';
import '../blocs/statistics_user/statistics_user_states.dart';

class ProfileStatisticsWidget extends StatelessWidget {
  const ProfileStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsUserBloc, StatisticsUserStates>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is StatisticsLoaded) {
          return _buildCard(
            title: "Statistiques Utilisateur",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "📊 Total Participations : ${state.statistics.totalParticipations}",
                    style: _textStyleBold),
                Text(
                    "🔹 Score de Confiance Moyen : ${state.statistics.averageTrustScore.toStringAsFixed(2)}%",
                    style: _textStyleBold),
                const SizedBox(height: 20),
                const Text("📈 Évolution du Score de Confiance",
                    style: _textStyleBold),
                const SizedBox(height: 10),
                _buildTrustScoreChart(
                    state.statistics.trustScoreHistory), // ✅ Ajout du graphique
              ],
            ),
          );
        }
        if (state is StatisticsError) {
          return _buildErrorText("Erreur (statistiques): ${state.message}");
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 🔹 Graphique de l'évolution du score de confiance
  Widget _buildTrustScoreChart(List<double> trustScoreHistory) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: trustScoreHistory
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: true,
              gradient:
                  const LinearGradient(colors: [Colors.green, Colors.blue]),
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10, // ✅ Intervalle des scores
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text("J+${value.toInt()}"); // ✅ Jours dynamiques
                },
                reservedSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Carte stylisée
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _textStyleBold),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  static const TextStyle _textStyleBold =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Widget _buildErrorText(String message) {
    return Center(
      child: Text(message,
          style: const TextStyle(color: Colors.red, fontSize: 16)),
    );
  }
}
