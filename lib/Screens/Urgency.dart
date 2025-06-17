import 'package:flutter/material.dart';
import 'package:front_end/Screens/AccountScreen.dart';
import '../Screens/homePage.dart';

class Urgency extends StatefulWidget {
  const Urgency({super.key});

  @override
  State<Urgency> createState() => _UrgencyState();
}

class _UrgencyState extends State<Urgency> {
  void _mostrarDialogoEmergencia(String titulo, String descripcion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Primeros auxilios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(descripcion),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urgencias'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.red[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Atención',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'En caso de emergencia grave, llama inmediatamente a nuestro número de emergencias o acude al centro médico más cercano.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Aquí puedes implementar llamada con url_launcher
                        },
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text(
                          'Llamar ahora',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Selecciona tu emergencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _UrgencyOption(
                  title: 'Trauma dental',
                  subtitle: 'Golpes o fracturas en los dientes',
                  imagePath: 'Assets/TraumaDental.jpg',
                  onTap: () => _mostrarDialogoEmergencia(
                    'Trauma dental',
                    'Enjuaga suavemente con agua tibia, aplica una compresa fría en la zona afectada y acude al odontólogo.',
                  ),
                ),
                _UrgencyOption(
                  title: 'Dolor intenso',
                  subtitle: 'Dolor dental severo y persistente',
                  imagePath: 'Assets/DolorIntenso.jpg',
                  onTap: () => _mostrarDialogoEmergencia(
                    'Dolor intenso',
                    'Toma analgésicos de venta libre, evita alimentos muy fríos o calientes y acude cuanto antes a revisión.',
                  ),
                ),
                _UrgencyOption(
                  title: 'Inflamación',
                  subtitle: 'Hinchazón en encías o cara',
                  imagePath: 'Assets/Inflamacion.jpg',
                  onTap: () => _mostrarDialogoEmergencia(
                    'Inflamación',
                    'Aplica hielo externamente en intervalos de 10 minutos, no te automediques y consulta al odontólogo.',
                  ),
                ),
                _UrgencyOption(
                  title: 'Sangrado',
                  subtitle: 'Sangrado excesivo de encías',
                  imagePath: 'Assets/Sangrado.jpg',
                  onTap: () => _mostrarDialogoEmergencia(
                    'Sangrado',
                    'Presiona con una gasa limpia por al menos 10 minutos. Si el sangrado persiste, acude a urgencias.',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Preguntas frecuentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _FaqTile(
              question: '¿Cuándo debo considerar una emergencia dental?',
              answer: 'Cuando hay sangrado abundante, dolor severo, dientes fracturados o inflamación con fiebre.',
            ),
            const _FaqTile(
              question: '¿Qué hago si se me cae un empaste?',
              answer: 'Evita masticar en esa zona, mantén el área limpia y agenda cita lo antes posible con tu odontólogo.',
            ),
            const _FaqTile(
              question: '¿Cómo aliviar el dolor dental mientras espero mi cita?',
              answer: 'Puedes usar analgésicos de venta libre y aplicar compresas frías en la zona afectada. No apliques calor ni automediques antibióticos.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Urgencias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi Cuenta'),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
          }
          else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
          }
        },
        
      ),
    );
  }
}

class _UrgencyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _UrgencyOption({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(imagePath),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer),
        )
      ],
    );
  }
}
