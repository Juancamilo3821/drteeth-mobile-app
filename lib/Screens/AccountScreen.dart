import 'package:flutter/material.dart';
import 'package:front_end/Screens/Urgency.dart';
import 'package:front_end/Screens/homePage.dart';
import 'package:front_end/Screens/SplashScreen.dart';
import 'package:front_end/Services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final data = await UserService().getUserProfile();
    setState(() {
      user = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    shadowColor: Colors.teal.shade100.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                      '${user?['nombre'] ?? ''} ${user?['apellidos'] ?? ''}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                Text(user?['correo'] ?? 'correo@ejemplo.com', style: const TextStyle(color: Colors.grey)),
                                Text('+57 ${user?['telefono'] ?? '000 000 0000'}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Editar'),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Configuración'),

                  _SettingTile(icon: Icons.person, title: 'Información personal', onTap: () {}),
                  _SettingTile(icon: Icons.settings, title: 'Configuración general', onTap: () {}),
                  _SettingSwitch(title: 'Inicio de sesión biométrico', value: true, onChanged: (v) {}),

                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Ayuda y soporte'),

                  _SettingTile(icon: Icons.help_outline, title: 'Preguntas frecuentes', onTap: () {}),
                  _SettingTile(icon: Icons.privacy_tip_outlined, title: 'Políticas de privacidad', onTap: () {}),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sesión cerrada correctamente'), backgroundColor: Colors.teal),
                      );

                      await Future.delayed(const Duration(seconds: 1));

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      backgroundColor: Colors.red.shade50,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Urgencias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Urgency()));
          }
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 12),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.teal.shade50,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.teal.shade50,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.teal,
        secondary: const Icon(Icons.fingerprint, color: Colors.teal),
      ),
    );
  }
}
