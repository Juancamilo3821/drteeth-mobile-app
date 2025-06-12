import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/appointmentService.dart';
import 'package:front_end/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/homePage.dart';
import '../Screens/Urgency.dart';




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

  factory Appointment.fromJson(Map<String, dynamic> json) {
  final doctor = json['doctor'] ?? {};

  return Appointment(
    title: json['titulo'] ?? '',
    number: json['id']?.toString() ?? '0', 
    fecha_hora: json['fecha_hora'] ?? '',
    location: doctor['direccion_consultorio'] ?? '',
    doctor: doctor['nombre'] ?? '',
    specialty: doctor['especialidad'] ?? '',
    duration: '${json['duracion_estimada'] ?? 30} minutos',
    confirmed: (json['estado'] == 'confirmada'),
    reminder: false,
  );
}
}

class HistoryAppointment {
  final String title;
  final String fecha_hora;
  final String doctor;
  final String location;

  HistoryAppointment({
    required this.title,
    required this.fecha_hora,
    required this.doctor,
    required this.location,
  });

  factory HistoryAppointment.fromJson(Map<String, dynamic> json) {
  final doctor = json['doctor'] ?? {};

  return HistoryAppointment(
    title: json['titulo'] ?? '',
    fecha_hora: json['fecha_hora'] ?? '',
    doctor: doctor['nombre'] ?? '',
    location: doctor['direccion_consultorio'] ?? '',
  );
}

}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  int _selectedBottomIndex = 0;

  List<Appointment> upcomingAppointments = [];
  List<HistoryAppointment> historyAppointments = [];

  bool isLoading = true;

  Future<void> _toggleReminder(bool value, Appointment appointment) async {
  final prefs = await SharedPreferences.getInstance();

  final int notificationId = int.tryParse(
        appointment.number.replaceAll(RegExp(r'\D'), ''),
      ) ??
      appointment.number.hashCode.abs();

  if (value) {
    DateTime? appointmentTime = DateTime.tryParse(appointment.fecha_hora);

    if (appointmentTime == null) {
      print('Fecha inválida para la cita: ${appointment.fecha_hora}');
      return;
    }

    final DateTime now = DateTime.now();

    if (appointmentTime.isBefore(now)) {
      print('No se puede programar recordatorio para una cita pasada.');
      return;
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      appointmentTime.subtract(const Duration(minutes: 30)),
      tz.local,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print('El tiempo de recordatorio ya pasó.');
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Recordatorio de cita: ${appointment.title}',
      'Tienes una cita con ${appointment.doctor} el ${DateFormat("d 'de' MMMM - h:mm a", 'es').format(appointmentTime)}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'drteeth_channel',
          'Recordatorios de citas',
          channelDescription: 'Notificaciones para recordar tus citas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    await prefs.setBool('reminder_${appointment.number}', true);

    if (mounted) {
      setState(() {
        appointment.reminder = true;
      });
    }
  } else {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    await prefs.setBool('reminder_${appointment.number}', false);

    if (mounted) {
      setState(() {
        appointment.reminder = false;
      });
    }
  }

  print('Notification ID: $notificationId'); 

  if (value) {
    DateTime? appointmentTime = DateTime.tryParse(appointment.fecha_hora);
    if (appointmentTime != null) {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        appointmentTime.subtract(const Duration(minutes: 30)),
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Recordatorio de cita: ${appointment.title}',
        'Tienes una cita con ${appointment.doctor} el ${DateFormat("d 'de' MMMM - h:mm a", 'es').format(appointmentTime)}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'drteeth_channel',
            'Recordatorios de citas',
            channelDescription: 'Notificaciones para recordar tus citas',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  } else {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });

    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => isLoading = true);

    try {
  final response = await AppointmentService().getCitas(); 
  setState(() {
    final List<dynamic> upcomingData = response['upcoming'] ?? [];
    final List<dynamic> historyData = response['history'] ?? [];

    upcomingAppointments = List<Appointment>.from(
      upcomingData.map((item) => Appointment.fromJson(item as Map<String, dynamic>)),
    );

    historyAppointments = List<HistoryAppointment>.from(
      historyData.map((item) => HistoryAppointment.fromJson(item as Map<String, dynamic>)),
    );

    isLoading = false;
  });
} catch (e) {
      print('Error al cargar citas: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
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
                      child: Icon(Icons.arrow_back, color: Colors.teal.shade700, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mis Citas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs personalizados
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal.shade100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton("Próximas", 0),
                  _buildTabButton("Historial", 1),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenido de pestañas
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUpcomingTab(),
                        _buildHistoryTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        selectedItemColor: Colors.grey.shade600,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });

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
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_outlined), label: 'Urgencias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],         // Aquí puedes agregar navegación para otros índices si deseas
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _tabController.index = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.teal.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (upcomingAppointments.isEmpty) {
      return Center(
        child: Text(
          'No hay próximas citas',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        return Column(
          children: [
            _buildAppointmentCard(
              title: appointment.title,
              number: appointment.number,
              fecha_hora: appointment.fecha_hora,
              location: appointment.location,
              doctor: appointment.doctor,
              specialty: appointment.specialty,
              duration: appointment.duration,
              confirmed: appointment.confirmed,
              reminder: appointment.reminder,
              onReminderChanged: (value) => _toggleReminder(value, appointment),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (historyAppointments.isEmpty) {
      return Center(
        child: Text(
          'No hay citas en historial',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: historyAppointments.length,
      itemBuilder: (context, index) {
        final history = historyAppointments[index];
        return Column(
          children: [
            _buildHistoryCard(
              title: history.title,
              fecha_hora: history.fecha_hora,
              doctor: history.doctor,
              location: history.location,
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard({
    required String title,
    required String number,
    required String fecha_hora,
    required String location,
    required String doctor,
    required String specialty,
    required String duration,
    required bool confirmed,  
    required bool reminder,
    required ValueChanged<bool> onReminderChanged,


  }) {
  DateTime? fecha = DateTime.tryParse(fecha_hora);
  String fechaFormateada = fecha != null
      ? DateFormat("d 'de' MMMM 'de' yyyy - h:mm a", 'es').format(fecha)
      : 'Fecha inválida';

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
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.teal,
                    ),
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    color: Colors.teal.shade700.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Info de la cita
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.calendar_today_outlined, fechaFormateada),
                const SizedBox(height: 6),
                _infoRow(Icons.location_on_outlined, location),
                const SizedBox(height: 6),
                _infoRow(Icons.medical_services_outlined, '$doctor - $specialty'),
                const SizedBox(height: 6),
                _infoRow(Icons.timer_outlined, duration),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          confirmed ? Icons.check_circle : Icons.cancel,
                          color: confirmed ? Colors.green : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          confirmed ? 'Confirmada' : 'No confirmada',
                          style: TextStyle(
                            color: confirmed ? Colors.green : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, color: Colors.teal),
                        const SizedBox(width: 6),
                        Text(
                          'Recordatorio',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        Switch(
                          value: reminder,
                          activeColor: Colors.teal.shade600,
                          onChanged: onReminderChanged,
                        ),
                      ],
                    ),
                  ],
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

  Widget _buildHistoryCard({
    required String title,
    required String fecha_hora,
    required String doctor,
    required String location,
  }) {
  DateTime? fecha = DateTime.tryParse(fecha_hora);
  String fechaFormateada = fecha != null
      ? DateFormat("d 'de' MMMM 'de' yyyy - h:mm a", 'es').format(fecha)
      : 'Fecha inválida';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today_outlined, fechaFormateada),
          const SizedBox(height: 4),
          _infoRow(Icons.person_outline, doctor),
          const SizedBox(height: 4),
          _infoRow(Icons.location_on_outlined, location),
        ],
      ),
    );
  }
}