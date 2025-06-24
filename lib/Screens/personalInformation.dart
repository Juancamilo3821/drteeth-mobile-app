import 'package:flutter/material.dart';
import 'package:front_end/Screens/editInformation.dart';
import 'package:front_end/Services/userService.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  final List<String> _avatars = [
    '', // default
    'Assets/1.png',
    'Assets/2.png',
    'Assets/3.png',
    'Assets/4.png',
    'Assets/5.png',
  ];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await UserService().getUserProfile();
    setState(() {
      user = data;
      isLoading = false;
    });
  }

  Widget _buildInfoBox(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int avatarIndex = (user?['avatar'] ?? 0);
    final bool hasValidAvatar = avatarIndex > 0 && avatarIndex < _avatars.length;

    final Widget avatarWidget = hasValidAvatar
        ? CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(_avatars[avatarIndex]),
          )
        : const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Información personal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 24),
                  _buildInfoBox(Icons.person, 'Nombre completo',
                      '${user?['nombre'] ?? ''} ${user?['apellidos'] ?? ''}'),
                  _buildInfoBox(Icons.email, 'Correo electrónico',
                      user?['correo'] ?? 'No disponible'),
                  _buildInfoBox(Icons.phone, 'Teléfono',
                      '+57 ${user?['telefono'] ?? 'No disponible'}'),
                  _buildInfoBox(
                    Icons.badge,
                    'Documento de identidad',
                    '${user?['tipoDocumento'] ?? 'N/A'} - ${user?['numeroDocumento'] ?? ''}',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (user != null) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditInformationScreen(user: user!),
                          ),
                        );

                        if (result == true) {
                          final updated = await UserService().getUserProfile();
                          setState(() {
                            user = updated;
                          });
                          // Notifica al AccountScreen que hubo cambio
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Editar información',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
