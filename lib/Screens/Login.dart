import 'package:flutter/material.dart';
import 'package:front_end/Services/loginService.dart';
import '../Animations/splash_Animation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00ACC1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Volver",
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF00ACC1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Iniciar Sesión",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Ingresa tus credenciales para acceder",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "correo@ejemplo.com",
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.visibility_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (val) {
                          setState(() {
                            rememberMe = val!;
                          });
                        },
                      ),
                      const Text("Recordarme"),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Color(0xFF00ACC1)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final result = await LoginService().login(
                      correo: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ResultSplashScreen(success: result['ok']),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF00ACC1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFF00ACC1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Registrarse",
                  style: TextStyle(color: Color(0xFF00ACC1)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("¿No tienes una cuenta? Regístrate"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
