import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_end/Screens/Disabilities.dart';
import 'package:intl/intl.dart';
import 'package:front_end/Screens/Appointments.dart';
import '../Services/appointmentService.dart';
import '../Services/carruselService.dart';
import 'package:front_end/Screens/Treatment.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _carouselTimer;

  List<Map<String, String>> healthTips = [];
  List<Appointment> _nextAppointments = [];
  bool _loadAppointments = true;

  @override
  void initState() {
    super.initState();
    _cargarImagenesRemotas();
    _startAutoScroll();
    _fetchNextAppointments();
  }

  Future<void> _cargarImagenesRemotas() async {
    final imagenes = await CarruselService.fetchImagenes();
    if (imagenes.isNotEmpty) {
      setState(() {
        healthTips = imagenes.map((url) => {
              'image': url,
              'title': 'Consejo de salud',
              'subtitle': 'Descripción del consejo',
            }).toList();
      });
    } else {
      setState(() {
        healthTips = [
          {
            'image': 'Assets/IMGLimpieza.png',
            'title': 'Cepillado correcto',
            'subtitle': 'Aprende la técnica adecuada para un cepillado efectivo',
          },
          {
            'image': 'Assets/IMGHilo.png',
            'title': 'Uso del hilo dental',
            'subtitle': 'Complementa tu higiene bucal diaria con hilo dental',
          },
          {
            'image': 'Assets/IMGVisita.png',
            'title': 'Visita al dentista',
            'subtitle': 'Realiza controles periódicos cada 6 meses',
          },
        ];
      });
    }
  }

  Future<void> _fetchNextAppointments() async {
    try {
      final citasMap = await AppointmentService().getCitas();
      print('Respuesta cruda de getCitas(): $citasMap');
      final upcomingRaw = citasMap['upcoming'] ?? [];

      final confirmed = upcomingRaw
          .where((item) => item['estado']?.toLowerCase() == 'confirmada')
          .toList();

      confirmed.sort((a, b) =>
          DateTime.parse(a['fecha_hora']).compareTo(DateTime.parse(b['fecha_hora'])));

      setState(() {
        _nextAppointments = confirmed.take(2).map((item) {
          return Appointment(
            title: item['titulo'] is String
                ? item['titulo']
                : (item['titulo']?['nombre'] ?? 'Cita médica'),
            number: item['number'] ?? '',
            fecha_hora: item['fecha_hora'],
            location: item['location'] ?? '',
            doctor: item['doctor'] is String
                ? item['doctor']
                : (item['doctor']?['nombre'] ?? 'Dr. Desconocido'),
            specialty: item['specialty'] ?? '',
            duration: item['duration'] ?? '',
            confirmed: item['confirmed'] ?? false,
            reminder: item['reminder'] ?? false,
          );
        }).toList();
        _loadAppointments = false;
      });
    } catch (e) {
      print('Error obteniendo citas: $e');
      setState(() {
        _loadAppointments = false;
      });
    }
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (healthTips.isEmpty) return;
      int nextPage = (_currentPage + 1) % healthTips.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
    });
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('DrTeeth Mobile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido, Juan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _HomeButton(
                  icon: Icons.calendar_today,
                  label: 'Citas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                    );
                  },
                ),
                _HomeButton(
                  icon: Icons.assignment,
                  label: 'Incapacidades',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DisabilitiesScreen()),
                    );
                  },
                ),
                _HomeButton(icon: Icons.payment, label: 'Pagos'),
                _HomeButton(
                  icon: Icons.healing,
                  label: 'Tratamientos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TreatmentsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Consejos de Salud Bucal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 180,
              child: healthTips.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: healthTips.length,
                      itemBuilder: (context, index) {
                        final tip = healthTips[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                tip['image']!.startsWith('http')
                                    ? Image.network(tip['image']!, fit: BoxFit.cover)
                                    : Image.asset(tip['image']!, fit: BoxFit.cover),
                                Container(
                                  alignment: index == 1 ? Alignment.bottomRight : Alignment.bottomLeft,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black54, Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: index == 1
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tip['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tip['subtitle']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        textAlign: index == 1 ? TextAlign.right : TextAlign.left,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Text(
                  'Próximas citas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                    );
                  },
                  child: const Text('Ver todo'),
                )
              ],
            ),

            if (_loadAppointments)
              const Center(child: CircularProgressIndicator())
            else if (_nextAppointments.isEmpty)
              const Text('No hay próximas citas.')
            else
              Column(
                children: _nextAppointments.map((a) {
                  final fecha = DateTime.tryParse(a.fecha_hora);
                  final fechaFormateada = fecha != null
                      ? DateFormat("d 'de' MMMM, yyyy - h:mm a", 'es').format(fecha)
                      : 'Fecha inválida';
                  return _AppointmentTile(
                    title: a.title,
                    date: fechaFormateada,
                    doctor: a.doctor,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_outlined), label: 'Urgencias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          // TODO: manejar navegación real
        },
      ),
    );
  }
}

// ------------------------ COMPONENTES AUXILIARES ------------------------

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HomeButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.teal),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final String title;
  final String date;
  final String doctor;

  const _AppointmentTile({
    required this.title,
    required this.date,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.teal),
        title: Text(title),
        subtitle: Text('$date\nCon: $doctor'),
        isThreeLine: true,
      ),
    );
  }
}

class Appointment {
  final String title;
  final String number;
  final String fecha_hora;
  final String location;
  final String doctor;
  final String specialty;
  final String duration;
  final bool confirmed;
  bool reminder;

  Appointment({
    required this.title,
    required this.number,
    required this.fecha_hora,
    required this.location,
    required this.doctor,
    required this.specialty,
    required this.duration,
    required this.confirmed,
    required this.reminder,
  });
}
