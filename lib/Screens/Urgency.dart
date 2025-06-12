import 'package:flutter/material.dart';

class Urgency extends StatelessWidget {
  const Urgency({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergencias Dentales'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.red[100],
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text(
                  'Atención',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                subtitle: const Text(
                  'En caso de emergencia grave, llama inmediatamente a nuestro número de emergencias o acude al centro médico más cercano.',
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    // Aquí puedes agregar el código para llamar
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Llamar ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
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
              children: const [
                _UrgencyOption(
                  title: 'Trauma dental',
                  subtitle: 'Golpes o fracturas en los dientes',
                ),
                _UrgencyOption(
                  title: 'Dolor intenso',
                  subtitle: 'Dolor dental severo y persistente',
                ),
                _UrgencyOption(
                  title: 'Inflamación',
                  subtitle: 'Hinchazón en encías o cara',
                ),
                _UrgencyOption(
                  title: 'Sangrado',
                  subtitle: 'Sangrado excesivo de encías',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Preguntas frecuentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _FaqTile(question: '¿Cuándo debo considerar una emergencia dental?'),
            const _FaqTile(question: '¿Qué hago si se me cae un empaste?'),
            const _FaqTile(question: '¿Cómo aliviar el dolor dental mientras espero mi cita?'),
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
          // Navegación según el índice
        },
      ),
    );
  }
}

class _UrgencyOption extends StatelessWidget {
  final String title;
  final String subtitle;

  const _UrgencyOption({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Acción al tocar la opción
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;

  const _FaqTile({required this.question});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Respuesta de ejemplo.'),
        )
      ],
    );
  }
}
