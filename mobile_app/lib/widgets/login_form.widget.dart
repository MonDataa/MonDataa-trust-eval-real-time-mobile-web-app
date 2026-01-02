import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_events.dart';
import '../blocs/auth/auth_states.dart';
import '../repository/AppConfig.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController ipController =
      TextEditingController(text: AppConfig.baseIp);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

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

              // ✅ Champ Email
              _buildTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // ✅ Champ Mot de passe
              _buildPasswordField(),
              const SizedBox(height: 20),

              // ✅ Bouton de connexion
              BlocBuilder<AuthBloc, AuthState>(
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
                    onPressed:
                        state is AuthLoadingState ? null : _onLoginPressed,
                    child: state is AuthLoadingState
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Se connecter",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  );
                },
              ),

              const SizedBox(height: 10),

              // ✅ Lien pour inscription
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/register"),
                child: const Text("Créer un compte",
                    style: TextStyle(color: Colors.blue, fontSize: 16)),
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Champ requis";
        }
        return null;
      },
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Champ requis";
        } else if (value.contains(" ")) {
          return "Le mot de passe ne doit pas contenir d'espaces";
        }
        return null;
      },
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      if (ipController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Veuillez entrer une adresse IP valide")),
        );
        return;
      }

      setState(() {
        AppConfig.baseIp = ipController.text.trim();
      });

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      context.read<AuthBloc>().add(LoginEvent(email, password));
    }
  }
}
