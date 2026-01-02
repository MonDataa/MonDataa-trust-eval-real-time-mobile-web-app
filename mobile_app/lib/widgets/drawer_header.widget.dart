import 'package:flutter/material.dart';

class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white, // Fond blanc pour contraste
            child: Icon(
              Icons.person, // ✅ Icône de client
              size: 50,
              color: Theme.of(context)
                  .primaryColor, // Utilisation de la couleur du thème
            ),
          ),
        ],
      ),
    );
  }
}
