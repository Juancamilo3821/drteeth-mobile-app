// register.dart
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/Services/registerService.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../Animations/splash_Animation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController docNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedDocType;

  bool acceptedTerms = false;
  bool passwordVisible = false;

  Future<void> _openTermsPDF() async {
    final byteData = await rootBundle.load('assets/Terminos y Condiciones DrteethMobile.pdf');
    final buffer = byteData.buffer;
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/terminos.pdf';
    final file = await File(filePath).writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    await OpenFile.open(file.path);
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Volver", style: TextStyle(color: Color(0xFF00ACC1))),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text("Crear Cuenta", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text("Regístrate para acceder a todos los servicios", style: TextStyle(fontSize: 14, color: Colors.black54)),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration("Nombre", "Juan"),
                      validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: _inputDecoration("Apellido", "Perez"),
                      validator: (value) => value!.isEmpty ? 'Ingrese su apellido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Documento de Identidad", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: selectedDocType,
                      hint: const Text("CC"),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'CC', child: Text('CC')),
                        DropdownMenuItem(value: 'CE', child: Text('CE')),
                        DropdownMenuItem(value: 'PA', child: Text('PA')),
                        DropdownMenuItem(value: 'OT', child: Text('OT')),
                      ],
                      onChanged: (value) => setState(() => selectedDocType = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: docNumberController,
                      decoration: _inputDecoration("", "1097910694"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value!.isEmpty ? 'Ingrese número de documento' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: _inputDecoration("Correo electrónico", "correo@ejemplo.com"),
                validator: (value) => value!.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: _inputDecoration("Teléfono", "+57 300 123 4567"),
                validator: (value) => value!.isEmpty ? 'Ingrese su número' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: !passwordVisible,
                decoration: _inputDecoration("Contraseña", "").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: (value) => setState(() => acceptedTerms = value!),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Acepto los ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Términos y Condiciones",
                            style: const TextStyle(color: Color(0xFF00ACC1), decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = _openTermsPDF,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && acceptedTerms) {
                    final result = await RegisterService().register(
                      nombre: nameController.text.trim(),
                      apellidos: lastNameController.text.trim(),
                      tipoDocumento: selectedDocType ?? 'CC',
                      numeroDocumento: docNumberController.text.trim(),
                      correo: emailController.text.trim(),
                      telefono: phoneController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultSplashScreen(success: result['ok']),
                      ),
                    );
                  } else if (!acceptedTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes aceptar los términos')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF00ACC1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Registrarse", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: '¿Ya tienes una cuenta? ',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: const TextStyle(color: Color(0xFF00ACC1), fontWeight: FontWeight.w500),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
