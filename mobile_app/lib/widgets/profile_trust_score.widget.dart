import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_states.dart';

class ProfileTrustScoreWidget extends StatelessWidget {
  const ProfileTrustScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return _buildCard(
            title: "Score de Confiance (Répartition)",
            child: _buildTrustScorePieChart(
              state.profile.trustPositive,
              state.profile.trustNegative,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTrustScorePieChart(double trustPositive, double trustNegative) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: trustPositive,
              title: "${trustPositive.toStringAsFixed(1)}%",
              color: Colors.green,
              radius: 50,
            ),
            PieChartSectionData(
              value: trustNegative,
              title: "${trustNegative.toStringAsFixed(1)}%",
              color: Colors.red,
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }

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
}
