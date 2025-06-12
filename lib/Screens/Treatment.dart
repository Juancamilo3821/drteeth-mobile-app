import 'package:flutter/material.dart';
import '../Services/treatmentService.dart'; 
import '../Screens/Urgency.dart';
import '../Screens/homePage.dart';
class Treatment {
  final String title;
  final String description;
  final String status;
  final String? nextAppointment;
  final double? progress;

  final String? medicamento;
  final String? dosis;
  final int? frecuenciaHoras;

  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  Treatment({
    required this.title,
    required this.description,
    required this.status,
    this.nextAppointment,
    this.progress,
    this.medicamento,
    this.dosis,
    this.frecuenciaHoras,
    this.fechaInicio,
    this.fechaFin,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      title: json['descripcion'] ?? '',
      description: json['descripcion'] ?? '',
      status: json['estado'] ?? '',
      nextAppointment: null, // Se puede actualizar si lo agregas en el backend
      progress: json['estado'] == 'En curso' ? 0.5 : null,
      medicamento: json['medicamento']?['nombre'],
      dosis: json['medicamento']?['dosis'],
      frecuenciaHoras: json['medicamento']?['frecuenciaHoras'],
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.tryParse(json['fecha_inicio'])
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.tryParse(json['fecha_fin'])
          : null,
    );
  }

  String get formattedDateRange {
    if (fechaInicio == null || fechaFin == null) return '-';
    return '${_formatDate(fechaInicio!)} - ${_formatDate(fechaFin!)}';
  }

  String _formatDate(DateTime date) {
    // Ej: 15 de mayo, 2025
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }
}


class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({super.key});
  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  final TreatmentService _treatmentService = TreatmentService();

  String selectedFilter = 'Todos';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  List<Treatment> allTreatments = [];
  bool isLoading = true;

  List<Treatment> get filteredTreatments {
    final filtered = selectedFilter == 'Todos'
        ? allTreatments
        : allTreatments.where((t) => t.status == selectedFilter).toList();

    if (searchQuery.isEmpty) return filtered;

    return filtered.where((t) {
      final query = searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadTreatments();
  }

  Future<void> loadTreatments() async {
    final data = await _treatmentService.getTreatments();
    setState(() {
      allTreatments = data.map((json) => Treatment.fromJson(json)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.teal.shade700),
          ),
        ),
        title: const Text(
          'Mis Tratamientos',
          style: TextStyle(
              color: Colors.teal, fontWeight: FontWeight.w700, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _searchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['Todos', 'En curso', 'Finalizado'].map((label) {
                final sel = label == selectedFilter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = label),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: sel
                            ? Border.all(color: Colors.teal, width: 1.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(
                            color: sel ? Colors.teal : Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredTreatments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        _buildTreatmentCard(filteredTreatments[i]),
                  ),
          ),
        ],
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

  Widget _searchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar tratamientos...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

 Widget _buildTreatmentCard(Treatment t) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.teal.shade100),
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
          padding: const EdgeInsets.all(16),
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
                  t.title,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.status == 'En curso'
                      ? Colors.amber.shade200
                      : Colors.green.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.status == 'En curso'
                        ? Colors.black87
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.calendar_today_outlined, t.formattedDateRange),
              const SizedBox(height: 8),
              Text(
                t.title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
              ),
              if (t.progress != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: t.progress,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.teal,
                  minHeight: 6,
                ),
              ],
              if (t.nextAppointment != null) ...[
                const SizedBox(height: 8),
                _infoRow(
                    Icons.event, 'Próxima cita: ${t.nextAppointment!}'),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.medication, color: Colors.teal),
                  label: const Text(
                    'Ver medicamentos',
                    style: TextStyle(color: Colors.teal),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Medicamento Recetado'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Nombre: ${t.medicamento ?? 'N/A'}'),
                            Text('Dosis: ${t.dosis ?? 'N/A'}'),
                            Text(
                                '1 Cada ${t.frecuenciaHoras?.toString() ?? '-'} horas'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cerrar'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
      children: [
        Icon(icon, size: 20, color: Colors.teal.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style:
                  TextStyle(color: Colors.grey.shade800, fontSize: 14)),
        ),
      ],
    );
  }
}
