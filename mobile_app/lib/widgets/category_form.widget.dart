import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../blocs/category/CategoryBloc.dart';
import '../blocs/category/category_events.dart';
import '../blocs/category/category_states.dart';

class CategoryFormWidget extends StatefulWidget {
  const CategoryFormWidget({Key? key}) : super(key: key);

  @override
  _CategoryFormWidgetState createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController customLabelController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// Sélectionner une image depuis la galerie et l'enregistrer localement
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final savedPath = await _saveImageToLocalDirectory(File(pickedFile.path));
      setState(() {
        _imageFile = File(savedPath);
      });
    }
  }

  /// Sauvegarder l'image sélectionnée dans le stockage local

  Future<String> _saveImageToLocalDirectory(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String imageName = imageFile.path.split('/').last;
    final String fullPath = '${directory.path}/$imageName';

    // 📌 Copie de l'image dans le stockage local
    await imageFile.copy(fullPath);

    print("✅ Image copiée et enregistrée à : $fullPath");

    return fullPath;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategorySuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Catégorie créée avec succès"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is CategoryErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nouvelle Catégorie",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                    nameController, "Nom de la catégorie", Icons.category),
                const SizedBox(height: 12),

                _buildTextField(
                    descriptionController, "Description", Icons.info,
                    maxLines: 3),
                const SizedBox(height: 12),

                _buildTextField(
                    customLabelController, "Label personnalisé", Icons.label),
                const SizedBox(height: 20),

                // 🔹 Bouton d'ajout d'image
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: _imageFile == null
                        ? const Center(
                            child: Text(
                              "Cliquer pour ajouter une image",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),

                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.blueAccent,
                        elevation: 5,
                      ),
                      onPressed: state is CategoryLoadingState
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<CategoryBloc>().add(
                                      CreateCustomCategoryEvent(
                                        nameController.text,
                                        descriptionController.text,
                                        customLabelController.text,
                                        _imageFile != null
                                            ? _imageFile!.path.split('/').last
                                            : "",
                                      ),
                                    );
                              }
                            },
                      child: state is CategoryLoadingState
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Créer la catégorie",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget réutilisable pour les champs de texte
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Champ requis" : null,
    );
  }
}
