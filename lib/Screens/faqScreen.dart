import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> _faqItems = [
    {
      'question': '¿Cómo puedo cambiar mi contraseña?',
      'answer':
          'Puedes cambiar tu contraseña desde la sección de Configuración general > Seguridad > Cambiar contraseña. '
              'También puedes usar la opción \'Olvidé mi contraseña\' en la pantalla de inicio de sesión.',
    },
    {
      'question': '¿Cómo activo las notificaciones?',
      'answer':
          'Ve a Configuración general > Notificaciones y activa las opciones que desees. Asegúrate de que tu dispositivo también tenga habilitadas las notificaciones para esta aplicación.',
    },
    {
      'question': '¿Puedo usar la aplicación sin conexión a internet?',
      'answer':
          'Algunas funciones básicas están disponibles sin conexión, pero necesitarás internet para sincronizar tus datos.',
    },
    {
      'question': '¿Cómo contacto al soporte técnico?',
      'answer':
          'Puedes escribirnos desde la sección de soporte o usar el botón "Contactar soporte" al final de esta pantalla.',
    },
    {
      'question': '¿Es segura mi información personal?',
      'answer':
          'Sí. Usamos cifrado y estándares de seguridad para proteger tus datos.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas frecuentes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F9FC),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          ..._faqItems.map(
            (item) => _FAQItem(
              question: item['question']!,
              answer: item['answer']!,
            ),
          ),
          const SizedBox(height: 24),
          const _SupportBox(),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          iconColor: Colors.teal,
          collapsedIconColor: Colors.teal,
          children: [
            Text(
              widget.answer,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
          onExpansionChanged: (value) => setState(() => isExpanded = value),
        ),
      ),
    );
  }
}

class _SupportBox extends StatelessWidget {
  const _SupportBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿No encontraste lo que buscabas?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contáctanos directamente y te ayudaremos a resolver tu consulta.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'jmgduran@gmail.com',
                  query: Uri.encodeFull(
                    'subject=Consulta desde la app DrTeeth&body=Hola equipo de soporte, necesito ayuda con...',
                  ),
                );

                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir la app de correo')),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Contactar soporte', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
