import 'package:flutter/material.dart';
import '../widgets/category_form.widget.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/gradient_background.widget.dart';

class CreateCategoryPage extends StatelessWidget {
  const CreateCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Ajouter une catégorie"),
      body: Stack(
        children: [
          // 🔹 Fond avec dégradé
          const GradientBackgroundWidget(),
          // 🔹 Formulaire avec effet flottant
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child:
                    const CategoryFormWidget(), // ✅ Utilisation du widget de formulaire
              ),
            ),
          ),
        ],
      ),
    );
  }
}
