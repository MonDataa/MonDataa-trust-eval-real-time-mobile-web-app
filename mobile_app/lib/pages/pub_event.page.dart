import 'package:flutter/material.dart';
import '../widgets/event_form.widget.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/gradient_background.widget.dart';

class PubEventPage extends StatelessWidget {
  const PubEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Publier un événement"),
      body: Stack(
        children: [
          // 🔹 Fond avec dégradé
          const GradientBackgroundWidget(),
          // 🔹 Formulaire avec effet flottant
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child:
                  const EventFormWidget(), // ✅ Utilisation du widget du formulaire
            ),
          ),
        ],
      ),
    );
  }
}
