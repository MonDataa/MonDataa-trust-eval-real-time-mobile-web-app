import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_states.dart';
import '../blocs/pub_event/event_bloc.dart';
import '../blocs/pub_event/event_events.dart';
import '../blocs/pub_event/event_states.dart';
import '../models/CategoryModel.dart';
import '../models/location_model.dart';
import '../repository/CategoryRepository.dart';
import '../repository/location_repository.dart';
import '../widgets//map_picker_screen.dart';
import 'dart:io';

class EventFormWidget extends StatefulWidget {
  const EventFormWidget({Key? key}) : super(key: key);

  @override
  _EventFormWidgetState createState() => _EventFormWidgetState();
}

class _EventFormWidgetState extends State<EventFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();

  int? selectedLocationId;
  int? selectedCategoryId;
  double? latitude;
  double? longitude;
  DateTime? _selectedExpirationDate;
  bool _isFetchingLocation = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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

  late Future<List<LocationModel>> _locationsFuture;
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _locationsFuture =
        RepositoryProvider.of<LocationRepository>(context).getZones();
    _categoriesFuture =
        RepositoryProvider.of<CategoryRepository>(context).getCategories();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);

    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _isFetchingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isFetchingLocation = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        _isFetchingLocation = false;
      });
    } catch (e) {
      setState(() => _isFetchingLocation = false);
    }
  }

  /// 📅 **Affiche un sélecteur de date**
  Future<void> _selectExpirationDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 5), // ✅ Limite à 5 ans
    );

    if (pickedDate != null) {
      setState(() {
        _selectedExpirationDate = pickedDate;
        expirationDateController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // ✅ Format "YYYY-MM-DD"
      });
    }
  }

  /// 📍 Open Map Picker
  Future<void> _selectLocationOnMap() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerScreen()),
    );

    if (selectedLocation != null) {
      setState(() {
        latitude = selectedLocation.latitude;
        longitude = selectedLocation.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PubEventBloc, PubEventState>(
      listener: (context, state) {
        if (state is EventSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Événement créé avec succès"),
                backgroundColor: Colors.green),
          );
          Navigator.pushNamed(context, "/home");
        } else if (state is EventErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                  "Publier un événement",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // 🔹 Champ Titre
                _buildTextField(titleController, "Titre", Icons.title),
                const SizedBox(height: 12),

                // 🔹 Champ Description
                _buildTextField(
                    descriptionController, "Description", Icons.description,
                    maxLines: 3),
                const SizedBox(height: 12),

                // 🔹 Sélection de la Location
                _buildDropdown(_locationsFuture, "Sélectionnez une location",
                    Icons.location_on, (value) {
                  setState(() {
                    selectedLocationId = value;
                  });
                }),

                const SizedBox(height: 12),

                // 🔹 Sélection de la Catégorie
                _buildDropdown(_categoriesFuture, "Sélectionnez une catégorie",
                    Icons.category, (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                }),

                const SizedBox(height: 12),
                //add button image
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

                TextFormField(
                  controller: expirationDateController,
                  decoration: InputDecoration(
                    labelText: "Date d'expiration",
                    prefixIcon:
                        const Icon(Icons.date_range, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true, // ✅ Empêche la saisie manuelle
                  onTap: () =>
                      _selectExpirationDate(context), // ✅ Ouvre le calendrier
                  validator: (value) =>
                      value == null || value.isEmpty ? "Champ requis" : null,
                ),
                const SizedBox(height: 12),

                // 🔹 Coordonnées GPS
                const SizedBox(height: 12),

                // 📍 Bouton pour ouvrir la carte et choisir un emplacement
                ElevatedButton(
                  onPressed: _selectLocationOnMap,
                  child: const Text("Sélectionner un emplacement sur la carte"),
                ),
                const SizedBox(height: 20),

                // 🔹 Bouton de soumission
                BlocBuilder<PubEventBloc, PubEventState>(
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
                      onPressed: state is EventLoadingState
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final authState =
                                    context.read<AuthBloc>().state;
                                if (authState is! AuthSuccessState) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Utilisateur non connecté"),
                                        backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                context.read<PubEventBloc>().add(
                                      CreateEventEvent(
                                        titleController.text,
                                        descriptionController.text,
                                        authState.user.id,
                                        selectedLocationId!,
                                        selectedCategoryId!,
                                        latitude!,
                                        longitude!,
                                        _selectedExpirationDate!,
                                        _imageFile != null
                                            ? _imageFile!.path.split('/').last
                                            : "",
                                      ),
                                    );
                              }
                            },
                      child: state is EventLoadingState
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Créer l'événement",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
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

  Widget _buildDropdown(Future<List<dynamic>> future, String label,
      IconData icon, Function(int?) onChanged) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Erreur: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.blueAccent)),
            items: snapshot.data!.map((item) {
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(item is CategoryModel
                    ? item.name
                    : "${item.nom} - ${item.zone}"), // ✅ Vérification du type
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) => value == null ? "Champ requis" : null,
          );
        } else {
          return const Text("Aucune donnée disponible");
        }
      },
    );
  }

  /* Widget _buildLocationWidget() {
    if (_isFetchingLocation) {
      return const CircularProgressIndicator();
    } else if (latitude != null && longitude != null) {
      return Column(
        children: [
          Text("📍 Latitude : $latitude"),
          Text("📍 Longitude : $longitude"),
          ElevatedButton(
              onPressed: _fetchLocation,
              child: const Text("Rafraîchir la position")),
        ],
      );
    } else {
      return const Text("⚠️ Impossible de récupérer la localisation.");
    }
  }*/
}
