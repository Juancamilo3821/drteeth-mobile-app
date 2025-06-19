import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Screens/Urgency.dart';
import '../Screens/homePage.dart';
import '../Screens/AccountScreen.dart';
import '../Services/paymentService.dart';
import '../Screens/register_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedTab = 'Pendientes';

  final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

  List<Map<String, dynamic>> pendingPayments = [];
  List<Map<String, dynamic>> paidPayments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    final result = await PaymentService().fetchPayments();
    final dateFormatter = DateFormat("d 'de' MMMM 'de' y", 'es_CO');

    List<Map<String, dynamic>> mapPagos(List<Map<String, dynamic>> pagos, bool esPagado) {
      return pagos.map((p) {
        String formattedDate = '';
        try {
          final parsedDate = DateTime.parse(p['fecha_pago']);
          formattedDate = dateFormatter.format(parsedDate);
        } catch (e) {
          formattedDate = 'Fecha inválida';
        }

        return {
          'title': p['titulo'] ?? '',
          'desc': p['descripcion'] ?? '',
          'amount': double.tryParse(p['monto'].toString()) ?? 0.0,
          'dueDate': formattedDate,
          'paidDate': formattedDate,
        };
      }).toList();
    }

    setState(() {
      pendingPayments = mapPagos(result['pending']!, false);
      paidPayments = mapPagos(result['paid']!, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final payments = selectedTab == 'Pendientes' ? pendingPayments : paidPayments;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Pagos',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildResumenCard(),
          ),
          const SizedBox(height: 12),
          _buildTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => selectedTab == 'Pendientes'
                  ? _buildPendingCard(payments[i])
                  : _buildPaidCard(payments[i]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
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
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar pagos...',
        prefixIcon: const Icon(Icons.search),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _resumenItem(
            'Pendiente',
            currencyFormatter.format(
              pendingPayments.fold<double>(0, (sum, p) => sum + (p['amount'] as double? ?? 0.0)),
            ),
            const Color(0xFFE3FBF9),
          ),
          const SizedBox(width: 12),
          _resumenItem(
            'Pagado',
            currencyFormatter.format(
              paidPayments.fold<double>(0, (sum, p) => sum + (p['amount'] as double? ?? 0.0)),
            ),
            const Color(0xFFE7FBE7),
          ),
        ],
      ),
    );
  }

  Widget _resumenItem(String label, String value, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['Pendientes', 'Pagados'].map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = tab),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: Colors.teal) : null,
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.teal : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> pago) {
    return _buildCard(
      title: pago['title'],
      desc: pago['desc'],
      amount: pago['amount'],
      dateLabel: 'Vence: ${pago['dueDate']}',
      showButton: true,
    );
  }

  Widget _buildPaidCard(Map<String, dynamic> pago) {
    return _buildCard(
      title: pago['title'],
      desc: pago['desc'],
      amount: pago['amount'],
      dateLabel: 'Pagado el: ${pago['paidDate']}',
      showButton: false,
    );
  }

    Widget _buildCard({
    required String title,
    required String desc,
    required double amount,
    required String dateLabel,
    required bool showButton,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event, color: Colors.teal, size: 18),
                const SizedBox(width: 6),
                Text(dateLabel, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormatter.format(amount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (showButton)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterPaymentScreen(
                            serviceTitle: title,
                            amount: amount,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B7E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Pagar ahora', style: TextStyle(color: Colors.white)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}