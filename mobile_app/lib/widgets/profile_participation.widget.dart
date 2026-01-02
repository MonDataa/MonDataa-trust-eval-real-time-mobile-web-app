import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_states.dart';

class ProfileParticipationWidget extends StatelessWidget {
  const ProfileParticipationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfileLoaded) {
          return _buildCard(
            title: "Historique de Participation",
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.profile.participationHistory.length,
              itemBuilder: (context, index) {
                final event = state.profile.participationHistory[index];
                return ListTile(
                  leading: const Icon(Icons.event, color: Colors.blue),
                  title: Text(event.title, style: _textStyleBold),
                  subtitle: Text(
                    "Participé le ${DateFormat('dd/MM/yyyy HH:mm').format(event.participationDate)}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: event.confirmed
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red),
                );
              },
            ),
          );
        }
        if (state is ProfileError) {
          return _buildErrorText("Erreur (participation): ${state.message}");
        }
        return const SizedBox.shrink();
      },
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

  Widget _buildErrorText(String message) {
    return Center(
      child: Text(message,
          style: const TextStyle(color: Colors.red, fontSize: 16)),
    );
  }
}
