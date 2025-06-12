import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../Services/disabilitiesService.dart';
import '../Screens/Urgency.dart';
import '../Screens/homePage.dart';

class Disabilities {
  final String title;
  final String fromDate;
  final String toDate;
  final int durationDays;
  final String diagnosis;
  final String estado;
  final String doctor;
  final String archivoPdf;

  Disabilities({
    required this.title,
    required this.fromDate,
    required this.toDate,
    required this.durationDays,
    required this.diagnosis,
    required this.estado,
    required this.doctor,
    required this.archivoPdf,
  });

  factory Disabilities.fromMap(Map<String, dynamic> map) {
    return Disabilities(
      title: map['titulo'] ?? '',
      fromDate: map['fecha_inicio'] ?? '',
      toDate: map['fecha_fin'] ?? '',
      durationDays: map['duracion_dias'] ?? 0,
      diagnosis: map['motivo'] ?? '',
      estado: map['estado'] ?? '',
      doctor: map['doctor'] != null && map['doctor']['nombre'] != null
          ? map['doctor']['nombre']
          : 'Desconocido',
      archivoPdf: map['archivo_pdf'] ?? '',
    );
  }
}

class DisabilitiesScreen extends StatefulWidget {
  const DisabilitiesScreen({super.key});

  @override
  State<DisabilitiesScreen> createState() => _DisabilitiesScreenState();
}

class _DisabilitiesScreenState extends State<DisabilitiesScreen> {
  String _selectedFilter = 'Todos';
  late Future<List<Disabilities>> _futureDisabilities;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _futureDisabilities = fetchDisabilities();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _openPdf(String pdfUrl) async {
    final Uri url = Uri.parse(pdfUrl);

    try {
      if (await canLaunchUrl(url)) {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          print('No se pudo lanzar la URL');
        }
      } else {
        print('No se puede lanzar la URL');
      }
    } catch (e) {
      print('Error al intentar abrir el PDF: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'disabilities_channel',
      'Incapacidades',
      channelDescription: 'Canal para notificaciones de incapacidades',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 2)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<List<Disabilities>> fetchDisabilities() async {
    final service = DisabilitiesService();
    final List<dynamic> data = await service.getDisabilities();
    return data.map((map) => Disabilities.fromMap(map)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: FutureBuilder<List<Disabilities>>(
                future: _futureDisabilities,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];
                  final filtered = _selectedFilter == 'Todos'
                      ? data
                      : data.where((d) => d.estado == _selectedFilter).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No hay incapacidades disponibles.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) =>
                        _buildDisabilitieCard(filtered[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.grey.shade600,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined), label: 'Urgencias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Urgency()),
            );
          }
          // Aquí puedes agregar más navegación si tienes otras vistas
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.arrow_back, color: Colors.teal.shade700, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Incapacidades',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            color: Colors.teal.shade700,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: _buildFilterSheet,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisabilitieCard(Disabilities d) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    d.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.teal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: d.estado == "VIGENTE"
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    d.estado,
                    style: TextStyle(
                      color: d.estado == "VIGENTE"
                          ? Colors.green.shade800
                          : Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.calendar_month,
                    '${formatDate(d.fromDate)} al ${formatDate(d.toDate)}'),
                const SizedBox(height: 6),
                _infoRow(Icons.timer_outlined, 'Días: ${d.durationDays}'),
                const SizedBox(height: 6),
                _infoRow(Icons.person, '${d.doctor}'),
                const SizedBox(height: 6),
                _infoRow(Icons.medical_services_outlined,
                    'Diagnóstico: ${d.diagnosis}'),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'Ver',
                  onPressed: () {
                    _showNotification(d.title,
                        'Incapacidad de ${d.durationDays} días con estado ${d.estado}');
                    _showDetailsBottomSheet(d);
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Descargar',
                  onPressed: () {
                    if (d.archivoPdf.isNotEmpty) {
                      _openPdf(d.archivoPdf);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archivo PDF no disponible')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.teal.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.teal),
      label: Text(label, style: const TextStyle(color: Colors.teal)),
      style: TextButton.styleFrom(
        backgroundColor: Colors.teal.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filtrar incapacidades',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.teal),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Todos'),
            onTap: () {
              setState(() => _selectedFilter = 'Todos');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('VIGENTE'),
            onTap: () {
              setState(() => _selectedFilter = 'VIGENTE');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.grey),
            title: const Text('VENCIDA'),
            onTap: () {
              setState(() => _selectedFilter = 'VENCIDA');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsBottomSheet(Disabilities d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)),
                    const SizedBox(height: 12),
                    _infoRow(Icons.calendar_today,
                        'Desde: ${formatDate(d.fromDate)}'),
                    _infoRow(Icons.calendar_today_outlined,
                        'Hasta: ${formatDate(d.toDate)}'),
                    _infoRow(Icons.timer_outlined,
                        'Duración: ${d.durationDays} días'),
                    _infoRow(Icons.info_outline,
                        'Diagnóstico: ${d.diagnosis}'),
                    _infoRow(Icons.check_circle_outline,
                        'Estado: ${d.estado}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
