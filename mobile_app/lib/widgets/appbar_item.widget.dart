import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/notification/notification_bloc.dart';
import 'package:mobile_app/blocs/notification/notification_events.dart';
import 'package:mobile_app/blocs/notification/notification_states.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).indicatorColor),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            int notificationCount = 0;
            if (state is NotificationLoadedState) {
              notificationCount = state.notifications.length;
            }

            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications,
                      color: Theme.of(context).indicatorColor),
                  onPressed: () {
                    _showNotificationsBottomSheet(context);
                  },
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        "$notificationCount",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 🔥 **Afficher la liste des notifications avec filtrage**
  void _showNotificationsBottomSheet(BuildContext context) {
    final notificationBloc = context.read<NotificationBloc>();
    final int? currentUserId = notificationBloc.currentUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            List<Map<String, dynamic>> filteredNotifications = [];
            if (state is NotificationLoadedState) {
              // ✅ Filtrer les notifications pour exclure celles du client connecté
              filteredNotifications = state.notifications
                  .where((notif) => notif["creatorId"] != currentUserId)
                  .toList();
            }

            return Container(
              height: 400,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Notifications",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context
                              .read<NotificationBloc>()
                              .add(ClearNotificationsEvent());
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: filteredNotifications.isNotEmpty
                        ? ListView.builder(
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = filteredNotifications[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  title: Text(
                                      "📢 Événement: ${notification["eventId"]} - ${notification["title"]}"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "🎯 Score de l'événement: ${notification["confianceScore"]}"),
                                    ],
                                  ),
                                  trailing:
                                      _buildConfirmationButtons(context, index),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text("Aucune notification disponible"),
                          ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Fermer",
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ **Boutons de confirmation et suppression**
  Widget _buildConfirmationButtons(BuildContext context, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () {
            context
                .read<NotificationBloc>()
                .add(UpdateNotificationStatusEvent(index, true));
          },
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () {
            context
                .read<NotificationBloc>()
                .add(RejectNotificationEvent(index, true));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
