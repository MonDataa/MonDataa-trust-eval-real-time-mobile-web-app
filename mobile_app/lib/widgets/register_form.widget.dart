import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_events.dart';
import '../models/location_model.dart';
import '../repository/AppConfig.dart';
import '../repository/location_repository.dart';

class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  _RegisterFormWidgetState createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final TextEditingController ipController =
      TextEditingController(text: AppConfig.baseIp);
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  int? selectedLocationId;
  late Future<List<LocationModel>> _locationsFuture;

  double? latitude;
  double? longitude;
  bool _isFetchingLocation = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<LocationModel> _locations = []; // ✅ Liste des locations

  @override
  void initState() {
    super.initState();
    _locationsFuture =
        RepositoryProvider.of<LocationRepository>(context).getZones();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);

    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _isFetchingLocation = false);
      return;
    }
    try {
      List<LocationModel> fetchedLocations =
          await RepositoryProvider.of<LocationRepository>(context).getZones();

      setState(() {
        _locations = fetchedLocations;
      });
    } catch (e) {
      print("❌ Erreur de chargement des locations : $e");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isFetchingLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isFetchingLocation = false);
      return;
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

  /// 🔍 **Détermine la zone correspondant à une position GPS**
  int? _getZoneForCurrentPosition(
      double? lat, double? lon, List<LocationModel> locations) {
    if (lat == null || lon == null) return null;

    for (var location in _locations) {
      // 🔹 Extraire min/max des intervalles latitude et longitude stockés en String
      var lonRange = _parseInterval(location.latitude);
      var latRange = _parseInterval(location.longitude);
      if (latRange != null && lonRange != null) {
        if (lat >= latRange[0] &&
            lat <= latRange[1] &&
            lon >= lonRange[0] &&
            lon <= lonRange[1]) {
          print("✅ Position dans la zone : ${location.nom} - ${location.zone}");
          return location.id;
        }
      }
    }

    print("❌ Aucune zone correspondante trouvée.");
    return null;
  }

  /// 📌 **Convertit une chaîne d'intervalle en deux valeurs numériques [min, max]**
  List<double>? _parseInterval(String interval) {
    try {
      List<String> parts = interval.split(",");
      if (parts.length == 2) {
        double min = double.parse(parts[0].trim());
        double max = double.parse(parts[1].trim());
        return [min, max];
      }
    } catch (e) {
      print("⚠️ Erreur de parsing de l'intervalle : $interval");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Logo
              Image.asset("images/insa_hdf.png", height: 100),
              const SizedBox(height: 20),

              // ✅ Champ Adresse IP
              _buildTextField(
                controller: ipController,
                label: "Adresse IP",
                icon: Icons.wifi,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    AppConfig.baseIp = value.trim();
                  });
                },
              ),
              const SizedBox(height: 12),

              // ✅ Champ Nom d'utilisateur
              _buildTextField(
                controller: usernameController,
                label: "Nom d'utilisateur",
                icon: Icons.person,
              ),
              const SizedBox(height: 12),

              // ✅ Champ Email
              _buildTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              _buildPasswordField(),
              const SizedBox(height: 12),

              const SizedBox(height: 12),

              // ✅ Sélection de la zone
              FutureBuilder<List<LocationModel>>(
                future: _locationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Erreur: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    // 🔹 Liste des zones disponibles
                    List<LocationModel> locations = snapshot.data!;

                    // 🔹 Vérifier si la position actuelle correspond à une zone
                    int? autoSelectedZone = _getZoneForCurrentPosition(
                        latitude, longitude, locations);

                    if (autoSelectedZone != null &&
                        selectedLocationId == null) {
                      selectedLocationId = autoSelectedZone;
                    }

                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: "Sélectionnez votre zone"),
                      value: selectedLocationId,
                      items: locations.map((loc) {
                        return DropdownMenuItem<int>(
                          value: loc.id,
                          child: Text("${loc.nom} - ${loc.zone}"),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedLocationId = value),
                      validator: (value) =>
                          value == null ? "Champ requis" : null,
                    );
                  } else {
                    return const Text("Aucune zone disponible");
                  }
                },
              ),
              const SizedBox(height: 20),

              // ✅ Bouton d'inscription
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                  elevation: 5,
                ),
                onPressed: _onRegisterPressed,
                child: const Text("S'inscrire",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Champ requis" : null,
      onChanged: onChanged,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Mot de passe",
        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Champ requis" : null,
    );
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterEvent(usernameController.text,
          emailController.text, passwordController.text,
          locationId: selectedLocationId!,
          latitude: latitude!,
          longitude: longitude!));
    }
  }
}
